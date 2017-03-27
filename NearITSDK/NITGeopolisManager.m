//
//  NITGeopolisManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager.h"
#import "NITNodesManager.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITJSONAPI.h"
#import "NITNode.h"
#import "NITBeaconNode.h"
#import "NITBeaconProximityManager.h"
#import "NITUtils.h"
#import <CoreLocation/CoreLocation.h>

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";

@interface NITGeopolisManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITNodesManager *nodesManager;
@property (nonatomic, strong) NITBeaconProximityManager *beaconProximity;
@property (nonatomic, strong) NITNode *currentNode;
@property (nonatomic, strong) NSMutableArray<NSString*> *enteredRegions;
@property (nonatomic, strong) NSMutableArray<CLRegion*> *monitoredRegions; //For test purpose
@property (nonatomic, strong) NSMutableArray<CLRegion*> *rangedRegions; // For test purpose
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic) BOOL started;

@end

@implementation NITGeopolisManager

- (instancetype)init {
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    return [self initWithNodesManager:nodesManager];
}

- (instancetype)initWithNodesManager:(NITNodesManager*)nodesManager {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.nodesManager = nodesManager;
        self.enteredRegions = [[NSMutableArray alloc] init];
        self.monitoredRegions = [[NSMutableArray alloc] init];
        self.rangedRegions = [[NSMutableArray alloc] init];
        self.pluginName = @"geopolis";
        self.started = NO;
    }
    return self;
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        [self.nodesManager setNodesWithJsonApi:json];
        completionHandler(error);
    }];
}

- (BOOL)start {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse && authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        return false;
    }
    
    [self startMonitoringRoots];
    
    return YES;
}

- (BOOL)startForUnitTest {
    [self startMonitoringRoots];
    return YES;
}

- (void)startMonitoringRoots {
    NSArray<NITNode*> *roots = [self.nodesManager roots];
    for (NITNode *node in roots) {
        CLRegion *region = [node createRegion];
        [self.locationManager startMonitoringForRegion:region];
        if (![self.monitoredRegions containsObject:region]) {
            [self.monitoredRegions addObject:region];
        }
    }
    
    self.started = YES;
}

- (void)stop {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
        [self.monitoredRegions removeObject:region];
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            [self.rangedRegions removeObject:region];
        }
    }
    self.started = NO;
}

- (void)stopMonitoringNodes:(NSArray<NITNode*>*)nodes {
    for (NITNode *node in nodes) {
        CLRegion *region = [node createRegion];
        if (region) {
            [self.locationManager stopMonitoringForRegion:region];
            [self.monitoredRegions removeObject:region];
            
            if([region isKindOfClass:[CLBeaconRegion class]]) {
                CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
                [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
                [self.rangedRegions removeObject:region];
            }
        }
    }
}

- (void)startMonitoringNodes:(NSArray<NITNode*>*)nodes {
    for (NITNode *node in nodes) {
        CLRegion *region = [node createRegion];
        if (region) {
            [self.locationManager startMonitoringForRegion:region];
            if (![self.monitoredRegions containsObject:region]) {
                [self.monitoredRegions addObject:region];
            }
        }
    }
}

- (BOOL)hasCurrentNode {
    if (self.currentNode) {
        return YES;
    }
    return NO;
}

// MARK: - Region step

- (void)stepInRegion:(CLRegion*)region {
    NITNode * newCurrentNode = [self.nodesManager nodeWithID:region.identifier];
    if (newCurrentNode == nil) {
        return;
    }
    
    NITNode *previousNode = self.currentNode;
    self.currentNode = newCurrentNode;
    
    if (previousNode != nil && [previousNode.parent.ID isEqualToString:self.currentNode.parent.ID]) {
        [self stopMonitoringNodes:previousNode.children];
    } else {
        NSArray<NITNode*> *siblings = [self.nodesManager siblingsWithNode:self.currentNode.parent];
        [self stopMonitoringNodes:siblings];
    }
    
    if ([self.enteredRegions containsObject:region.identifier]) {
        //Entered in a region already entered
    } else {
        [self.enteredRegions addObject:region.identifier];
        
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            [self triggerWithEvent:NITRegionEventEnterArea node:self.currentNode];
        } else {
            [self triggerWithEvent:NITRegionEventEnterPlace node:self.currentNode];
        }
    }
    
    NSArray<NITNode*> *children = self.currentNode.children;
    if ([children count] == 0) {
        return;
    }
    
    CLRegion *currentRegion = [self.currentNode createRegion];
    if ([currentRegion isKindOfClass:[CLBeaconRegion class]] && self.currentNode.identifier != nil) {
        [self.beaconProximity addRegionWithIdentifier:currentRegion.identifier];
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)currentRegion];
        if (![self.rangedRegions containsObject:currentRegion]) {
            [self.rangedRegions addObject:currentRegion];
        }
    } else {
        [self startMonitoringNodes:children];
    }
}

- (void)stepOutRegion:(CLRegion*)region {
    NITNode * exitedNode = [self.nodesManager nodeWithID:region.identifier];
    if (exitedNode == nil) {
        return;
    }
    
    if ([self.enteredRegions containsObject:region.identifier]) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            [self triggerWithEvent:NITRegionEventLeaveArea node:exitedNode];
        } else {
            [self triggerWithEvent:NITRegionEventLeavePlace node:exitedNode];
        }
    } else {
        return;
    }
    
    [self.beaconProximity removeRegionWithIdentifier:region.identifier];
    
    if (![exitedNode.parent.ID isEqualToString:self.currentNode.parent.ID]) {
        self.currentNode = exitedNode.parent;
        [self stopMonitoringNodes:self.currentNode.children];
        [self startMonitoringNodes:[self.nodesManager siblingsWithNode:self.currentNode.parent]];
    }
}

// MARK: - Trigger

- (void)triggerWithEvent:(NITRegionEvent)event node:(NITNode*)node { // It's only a stub for now
    if([self.recipesManager respondsToSelector:@selector(gotPulseWithPulsePlugin:pulseAction:pulseBundle:)]) {
        NSString *pulseAction = [NITUtils stringFromRegionEvent:event];
        [self.recipesManager gotPulseWithPulsePlugin:self.pluginName pulseAction:pulseAction pulseBundle:node.identifier];
    }
}

// MARK: - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        [manager requestStateForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    switch (state) {
        case CLRegionStateInside:
            [self stepInRegion:region];
            break;
        case CLRegionStateOutside:
            [self stepOutRegion:region];
            break;
        case CLRegionStateUnknown:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    NITNode *node = [self.nodesManager nodeWithID:region.identifier];
    NITBeaconNode *beaconNode;
    if ([node isKindOfClass:[NITBeaconNode class]]) {
        beaconNode = (NITBeaconNode*)node;
    } else {
        return;
    }
    
    NSMutableArray<NSString*>* appeared = [[NSMutableArray alloc] init];
    
    for(CLBeacon *beacon in beacons) {
        CLProximity proximity = beacon.proximity;
        
        if (proximity == CLProximityUnknown) {
            return;
        }
        
        NITBeaconNode *minorNode = [self.nodesManager beaconNodeWithBeacon:beacon inChildren:beaconNode.children];
        NITRegionEvent beaconEvent = [self regionEventFromProximity:proximity];
        NSString *beaconIdentifier = minorNode.identifier;
        
        if (minorNode != nil && beaconIdentifier != nil) {
            [appeared addObject:beaconIdentifier];
            
            CLProximity previousProximity = [self.beaconProximity proximityWithBeaconIdentifier:beaconIdentifier regionIdentifier:region.identifier];
            if (previousProximity != beacon.proximity) {
                [self.beaconProximity addProximityWithBeaconIdentifier:beaconIdentifier regionIdentifier:region.identifier proximity:beacon.proximity];
                [self triggerWithEvent:beaconEvent node:minorNode];
            }
        }
    }
    
    [self.beaconProximity evaluateDisappearedWithBeaconIdentifiers:appeared regionIdentifier:region.identifier];
}

// MARK: - Utils

- (NSArray *)nodes {
    return [self.nodesManager nodes];
}

- (NITRegionEvent)regionEventFromProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityImmediate:
            return NITRegionEventImmediate;
        case CLProximityNear:
            return NITRegionEventNear;
        case CLProximityFar:
            return NITRegionEventFar;
        default:
            return NITRegionEventUnknown;
    }
}

@end
