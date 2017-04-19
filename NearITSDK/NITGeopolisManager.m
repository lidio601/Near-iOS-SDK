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
#import "NITCacheManager.h"
#import "NITJSONAPIResource.h"
#import "NITConfiguration.h"
#import "NITLog.h"
#import "NITGeopolisNodesManager.h"
#import <CoreLocation/CoreLocation.h>

#define LOGTAG @"GeopolisManager"

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";
NSString* const NodeJSONCacheKey = @"GeopolisNodesJSON";

@interface NITGeopolisManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) id<NITNetworkManaging> networkManaeger;
@property (nonatomic, strong) NITBeaconProximityManager *beaconProximity;
@property (nonatomic, strong) NITNode *currentNode;
@property (nonatomic, strong) NSMutableArray<NSString*> *enteredRegions;
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NITNetworkProvider *provider;
@property (nonatomic) BOOL started;

@end

@implementation NITGeopolisManager

- (instancetype)initWithNodesManager:(NITGeopolisNodesManager*)nodesManager cachaManager:(NITCacheManager*)cacheManager networkManager:(id<NITNetworkManaging>)networkManager configuration:(NITConfiguration*)configuration locationManager:(CLLocationManager *)locationManager {
    self = [super init];
    if (self) {
        if (locationManager) {
            self.locationManager = locationManager;
        } else {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        self.locationManager.delegate = self;
        self.nodesManager = nodesManager;
        self.cacheManager = cacheManager;
        self.networkManaeger = networkManager;
        self.configuration = configuration;
        self.enteredRegions = [[NSMutableArray alloc] init];
        self.pluginName = @"geopolis";
        self.started = NO;
        self.beaconProximity = [[NITBeaconProximityManager alloc] init];
    }
    return self;
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    [self.networkManaeger makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] geopolisNodes] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            NITJSONAPI *jsonApi = [self.cacheManager loadObjectForKey:NodeJSONCacheKey];
            if (jsonApi) {
                [self.nodesManager setNodesWithJsonApi:jsonApi];
                completionHandler(nil);
            } else {
                completionHandler(error);
            }
        } else {
            [self.nodesManager setNodesWithJsonApi:json];
            [self.cacheManager saveWithObject:json forKey:NodeJSONCacheKey];
            completionHandler(nil);
        }
    }];
}

- (BOOL)start {
    if(self.started) {
        return YES;
    }
    
    if([[self.nodesManager roots] count] == 0) {
        return NO;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse && authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        return false;
    }
    
    [self startMonitoringRoots];
    
    return YES;
}

- (void)startMonitoringRoots {
    NSArray<NITNode*> *roots = [self.nodesManager roots];
    for (NITNode *node in roots) {
        CLRegion *region = [node createRegion];
        [self.locationManager startMonitoringForRegion:region];
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
    [self.nodesManager clear];
    self.started = NO;
}

- (BOOL)hasCurrentNode {
    if (self.currentNode) {
        return YES;
    }
    return NO;
}

// MARK: - Region step

- (void)stepInRegion:(CLRegion*)region {
    NITLogD(LOGTAG, @"StepInRegion -> %@", region.identifier);
    
    NSArray<NITNode*> *monitoredNodes = [self.nodesManager monitoredNodesOnEnterWithId:region.identifier];
    NSArray<NITNode*> *rangedNodes = [self.nodesManager rangedNodesOnEnterWithId:region.identifier];
    
    [self setMonitoringWithNodes:monitoredNodes];
    [self setRangingWithNodes:rangedNodes];
}

- (void)stepOutRegion:(CLRegion*)region {
    NITLogD(LOGTAG, @"StepOutRegion -> %@", region.identifier);
    
    NSArray<NITNode*> *monitoredNodes = [self.nodesManager monitoredNodesOnExitWithId:region.identifier];
    NSArray<NITNode*> *rangedNodes = [self.nodesManager rangedNodesOnExitWithId:region.identifier];
    
    [self setMonitoringWithNodes:monitoredNodes];
    [self setRangingWithNodes:rangedNodes];
}

- (BOOL)stillExistsWithRegionIdentifier:(NSString*)identifier nodes:(NSArray<NITNode*>*)nodes {
    BOOL exists = NO;
    for(NITNode *node in nodes) {
        if ([node.ID.lowercaseString isEqualToString:identifier.lowercaseString]) {
            exists = YES;
            break;
        }
    }
    return exists;
}

- (BOOL)existsWithRegionIdentifier:(NSString*)identifier regions:(NSArray<CLRegion*>*)regions {
    BOOL exists = NO;
    for (CLRegion *region in regions) {
        if ([region.identifier.lowercaseString isEqualToString:identifier.lowercaseString]) {
            exists = YES;
            break;
        }
    }
    return exists;
}

- (void)setMonitoringWithNodes:(NSArray<NITNode*>*)nodes {
    for(CLRegion *region in self.locationManager.monitoredRegions) {
        if (![self stillExistsWithRegionIdentifier:region.identifier nodes:nodes]) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
    
    for(NITNode *node in nodes) {
        if (![self existsWithRegionIdentifier:node.ID regions:[self.locationManager.monitoredRegions allObjects]]) {
            [self.locationManager startMonitoringForRegion:[node createRegion]];
        }
    }
}

- (void)setRangingWithNodes:(NSArray<NITNode*>*)nodes {
    for(CLBeaconRegion *region in self.locationManager.rangedRegions) {
        if (![self stillExistsWithRegionIdentifier:region.identifier nodes:nodes]) {
            [self.locationManager stopRangingBeaconsInRegion:region];
            [self.beaconProximity removeRegionWithIdentifier:region.identifier];
        }
    }
    
    for(NITNode *node in nodes) {
        if (![self existsWithRegionIdentifier:node.ID regions:[self.locationManager.rangedRegions allObjects]]) {
            CLRegion *region = [node createRegion];
            if ([region isKindOfClass:[CLBeaconRegion class]]) {
                [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
                [self.beaconProximity addRegionWithIdentifier:region.identifier];
            }
        }
    }
}

// MARK: - Trigger

- (void)triggerWithEvent:(NITRegionEvent)event node:(NITNode*)node {
    if (node == nil || node.identifier == nil) {
        return;
    }
    
    NSString *eventString = [NITUtils stringFromRegionEvent:event];
    NITLogD(LOGTAG, @"Trigger for event -> %@ - node -> %", eventString, node);
    
    [self trackEventWithIdentifier:node.identifier event:event];
    if([self.recipesManager respondsToSelector:@selector(gotPulseWithPulsePlugin:pulseAction:pulseBundle:)]) {
        NSString *pulseAction = [NITUtils stringFromRegionEvent:event];
        [self.recipesManager gotPulseWithPulsePlugin:self.pluginName pulseAction:pulseAction pulseBundle:node.identifier];
    }
}

- (void)trackEventWithIdentifier:(NSString*)identifier event:(NITRegionEvent)event {
    NITJSONAPI *json = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"trackings";
    [resource addAttributeObject:self.configuration.profileId forKey:@"profile_id"];
    [resource addAttributeObject:self.configuration.installationId forKey:@"installation_id"];
    [resource addAttributeObject:self.configuration.appId forKey:@"app_id"];
    [resource addAttributeObject:identifier forKey:@"identifier"];
    NSString *eventString = [NITUtils stringFromRegionEvent:event];
    [resource addAttributeObject:eventString forKey:@"event"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    [resource addAttributeObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"tracked_at"];
    
    [json setDataWithResourceObject:resource];
    
    [self.networkManaeger makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] sendGeopolisTrackingsWithJsonApi:json] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        
    }];
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
