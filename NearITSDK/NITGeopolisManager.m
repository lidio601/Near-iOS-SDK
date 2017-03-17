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
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, NITRegionEvent) {
    NITRegionEventEnterArea,
    NITRegionEventLeaveArea,
    NITRegionEventImmediate,
    NITRegionEventNear,
    NITRegionEventFar,
    NITRegionEventEnterPlace,
    NITRegionEventLeavePlace
};

@interface NITGeopolisManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITNodesManager *nodesManager;
@property (nonatomic, strong) NITNode *currentNode;
@property (nonatomic, strong) NSMutableArray<NSString*> *enteredRegions;
@property (nonatomic) BOOL started;

@end

@implementation NITGeopolisManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.nodesManager = [[NITNodesManager alloc] init];
        self.started = NO;
    }
    return self;
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        [self.nodesManager parseAndSetNodes:json];
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
        [self.locationManager startMonitoringForRegion:[node createRegion]];
    }
    
    self.started = YES;
}

- (void)stop {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
            [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
        }
    }
    self.started = NO;
}

- (void)stopMonitoringNodes:(NSArray<NITNode*>*)nodes {
    for (NITNode *node in nodes) {
        CLRegion *region = [node createRegion];
        if (region) {
            [self.locationManager stopMonitoringForRegion:region];
            
            if([region isKindOfClass:[CLBeaconRegion class]]) {
                CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
                [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
            }
        }
    }
}

- (void)startMonitoringNodes:(NSArray<NITNode*>*)nodes {
    for (NITNode *node in nodes) {
        CLRegion *region = [node createRegion];
        if (region) {
            [self.locationManager startMonitoringForRegion:region];
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
    NITNode * newCurrentNode = [self.nodesManager findNodeWithID:region.identifier];
    if (newCurrentNode == nil) {
        return;
    }
    
    NITNode *previousNode = self.currentNode;
    self.currentNode = newCurrentNode;
    
    if (previousNode != nil && [previousNode.parent.ID isEqualToString:self.currentNode.parent.ID]) {
        [self stopMonitoringNodes:previousNode.children];
    } else {
        NSArray<NITNode*> *siblings = [self.nodesManager siblingsWithNode:self.currentNode];
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
    if ([currentRegion isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)currentRegion];
    } else {
        [self startMonitoringNodes:children];
    }
}

- (void)stepOutRegion:(CLRegion*)region {
    NITNode * exitedNode = [self.nodesManager findNodeWithID:region.identifier];
    if (exitedNode == nil) {
        return;
    }
    
    if ([self.enteredRegions containsObject:region.identifier]) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            [self triggerWithEvent:NITRegionEventLeaveArea node:exitedNode];
        } else {
            [self triggerWithEvent:NITRegionEventEnterPlace node:exitedNode];
        }
    } else {
        return;
    }
    
    self.currentNode = exitedNode.parent;
    [self stopMonitoringNodes:self.currentNode.children];
    [self startMonitoringNodes:[self.nodesManager siblingsWithNode:self.currentNode.parent]];
}

- (void)testStepInRegion:(CLRegion*)region {
    [self stepInRegion:region];
}

- (void)testStepOutRegion:(CLRegion*)region {
    [self stepOutRegion:region];
}

// MARK: - Trigger

- (void)triggerWithEvent:(NITRegionEvent)event node:(NITNode*)node { // It's only a stub for now
    
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
    
}

@end
