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
#import "NITGeofenceNode.h"
#import "NITBeaconProximityManager.h"
#import "NITUtils.h"
#import "NITCacheManager.h"
#import "NITJSONAPIResource.h"
#import "NITConfiguration.h"
#import "NITLog.h"
#import "NITGeopolisNodesManager.h"
#import "NITTrackManager.h"
#import <CoreLocation/CoreLocation.h>

#define LOGTAG @"GeopolisManager"
#define MAX_LOCATION_TIMER_RETRY 3

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";
NSString* const NodeJSONCacheKey = @"GeopolisNodesJSON";

@interface NITGeopolisManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) id<NITNetworkManaging> networkManaeger;
@property (nonatomic, strong) NITTrackManager *trackManager;
@property (nonatomic, strong) NITBeaconProximityManager *beaconProximity;
@property (nonatomic, strong) NITNode *currentNode;
@property (nonatomic, strong) NSMutableArray<NSString*> *enteredRegions;
@property (nonatomic, strong) NSString *pluginName;
@property (nonatomic, strong) NITNetworkProvider *provider;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic, strong) NSMutableArray<NITNode*> *visitedNodes;
@property (nonatomic) NSInteger locationTimerRetry;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL stepResponse;

@end

@implementation NITGeopolisManager

- (instancetype)initWithNodesManager:(NITGeopolisNodesManager*)nodesManager cachaManager:(NITCacheManager*)cacheManager networkManager:(id<NITNetworkManaging>)networkManager configuration:(NITConfiguration*)configuration locationManager:(CLLocationManager *)locationManager trackManager:(NITTrackManager *)trackManager {
    self = [super init];
    if (self) {
        if (locationManager) {
            self.locationManager = locationManager;
        } else {
            self.locationManager = [[CLLocationManager alloc] init];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
        [self.locationManager requestLocation];
        self.nodesManager = nodesManager;
        self.cacheManager = cacheManager;
        self.networkManaeger = networkManager;
        self.trackManager = trackManager;
        self.configuration = configuration;
        self.enteredRegions = [[NSMutableArray alloc] init];
        self.visitedNodes = [[NSMutableArray alloc] init];
        self.pluginName = @"geopolis";
        self.started = NO;
        self.stepResponse = NO;
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
    
    NITLogD(LOGTAG, @"Geopolis start");
    
    if([[self.nodesManager roots] count] == 0) {
        return NO;
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse && authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        NITLogE(LOGTAG, @"Geopolis couldn't start: CLLocationManager authorizationStatus is wrong");
        return false;
    }
    
    [self stop];
    
    self.locationTimerRetry = 0;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationTimerFired:) userInfo:nil repeats:YES];
    }];
    
    [self startMonitoringRoots];
    
    return YES;
}

- (void)locationTimerFired:(NSTimer*)timer {
    self.locationTimerRetry++;
    NITLogD(@"LocationTimer", @"Entered in timer: retry %d", self.locationTimerRetry);
    if (!self.stepResponse) {
        NITLogW(@"LocationTimer", @"Request step response by timer");
        [self.locationManager requestLocation];
        [self requestStateForRoots];
    } else {
        [self.locationTimer invalidate];
        NITLogD(@"LocationTimer", @"Invalidate timer due to a successful state");
    }
    if (self.locationTimerRetry >= MAX_LOCATION_TIMER_RETRY) {
        NITLogW(@"LocationTimer", @"MAX_LOCATION_TIMER_RETRY reached");
        [self.locationTimer invalidate];
    }
}

- (void)startMonitoringRoots {
    NITLogD(LOGTAG, @"Geopolis start monitoring roots");
    NSArray<NITNode*> *roots = [self.nodesManager roots];
    for (NITNode *node in roots) {
        CLRegion *region = [node createRegion];
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager requestStateForRegion:region];
    }
    
    self.started = YES;
}

- (void)requestStateForRoots {
    NSArray<NITNode*> *roots = [self.nodesManager roots];
    for (NITNode *node in roots) {
        CLRegion *region = [node createRegion];
        [self.locationManager requestStateForRegion:region];
    }
}

- (void)stop {
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
    for (CLBeaconRegion *region in self.locationManager.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    [self.locationManager stopUpdatingLocation];
    [self.nodesManager clear];
    self.started = NO;
    [self.locationTimer invalidate];
    self.locationTimer = nil;
    self.locationTimerRetry = 0;
    [self.visitedNodes removeAllObjects];
}

- (BOOL)hasCurrentNode {
    if (self.currentNode) {
        return YES;
    }
    return NO;
}

// MARK: - Region step

- (void)stepInRegion:(CLRegion*)region {
    self.stepResponse = YES;
    NITLogD(LOGTAG, @"StepInRegion -> %@", region.identifier);
    NITNode *node = [self.nodesManager nodeWithID:region.identifier];
    if (node == nil) {
        return;
    }
    NITLogD(LOGTAG, @"StepInNode -> %@", node);
    if (![self isAlreadyVisitedWithNode:node]) {
        [self triggerInRegion:region];
    }
    
    [self setVisitedWithNode:node];
    NSArray<NITNode*> *monitoredNodes = [self.nodesManager monitoredNodesOnEnterWithId:region.identifier];
    NSArray<NITNode*> *rangedNodes = [self.nodesManager rangedNodesOnEnterWithId:region.identifier];
    NITLogD(LOGTAG, @"Regions state stepIn MR -> %d, RR -> %d", [monitoredNodes count], [rangedNodes count]);
    
    [self setMonitoringWithNodes:monitoredNodes];
    [self setRangingWithNodes:rangedNodes];
}

- (void)triggerInRegion:(CLRegion*)region {
    self.stepResponse = YES;
    NITLogD(LOGTAG, @"TriggerInRegion -> %@", region.identifier);
    NITNode *node = [self.nodesManager nodeWithID:region.identifier];
    if (node == nil) {
        return;
    }
    NITLogD(LOGTAG, @"TriggerInNode -> %@", node);
    
    [self setVisitedWithNode:node];
    if ([node isKindOfClass:[NITGeofenceNode class]]) {
        [self triggerWithEvent:NITRegionEventEnterPlace node:node];
    } else {
        [self triggerWithEvent:NITRegionEventEnterArea node:node];
    }
}

- (void)stepOutRegion:(CLRegion*)region {
    self.stepResponse = YES;
    NITLogD(LOGTAG, @"StepOutRegion -> %@", region.identifier);
    NITNode *node = [self.nodesManager nodeWithID:region.identifier];
    if (node == nil) {
        return;
    }
    NITLogD(LOGTAG, @"StepOutNode -> %@", node);
    
    BOOL isMonitored = NO;
    for (CLRegion *monitoredRegion in self.locationManager.monitoredRegions) {
        if ([monitoredRegion.identifier isEqualToString:region.identifier]) {
            isMonitored = YES;
        }
    }
    
    if (!isMonitored) {
        NITLogD(LOGTAG, @"StepOutNode ignored because is not monitored -> %@", node);
        return;
    }
    
    NSArray<NITNode*> *monitoredNodes = [self.nodesManager monitoredNodesOnExitWithId:region.identifier];
    NSArray<NITNode*> *rangedNodes = [self.nodesManager rangedNodesOnExitWithId:region.identifier];
    NITLogD(LOGTAG, @"Regions state stepOut MR -> %d, RR -> %d", [monitoredNodes count], [rangedNodes count]);
    
    [self setMonitoringWithNodes:monitoredNodes];
    [self setRangingWithNodes:rangedNodes];
}

- (void)triggerOutRegion:(CLRegion*)region {
    self.stepResponse = YES;
    NITLogD(LOGTAG, @"TriggerOutRegion -> %@", region.identifier);
    NITNode *node = [self.nodesManager nodeWithID:region.identifier];
    if (node == nil) {
        return;
    }
    NITLogD(LOGTAG, @"TriggerOutNode -> %@", node);
    
    if ([node isKindOfClass:[NITGeofenceNode class]]) {
        [self triggerWithEvent:NITRegionEventLeavePlace node:node];
    } else {
        [self triggerWithEvent:NITRegionEventLeaveArea node:node];
    }
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
            NITNode *node = [self.nodesManager nodeWithID:region.identifier];
            if (node) {
                [self setNotVisitedWithNode:node];
            }
        }
    }
    
    for(NITNode *node in nodes) {
        if (![self existsWithRegionIdentifier:node.ID regions:[self.locationManager.monitoredRegions allObjects]]) {
            CLRegion *region = [node createRegion];
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            [self.locationManager startMonitoringForRegion:region];
            [self.locationManager requestStateForRegion:region];
        }
    }
}

- (void)setRangingWithNodes:(NSArray<NITNode*>*)nodes {
    for(CLBeaconRegion *region in self.locationManager.rangedRegions) {
        if (![self stillExistsWithRegionIdentifier:region.identifier nodes:nodes]) {
            [self.locationManager stopRangingBeaconsInRegion:region];
            [self.beaconProximity removeRegionWithIdentifier:region.identifier];
            NITNode *node = [self.nodesManager nodeWithID:region.identifier];
            if (node) {
                [self setNotVisitedWithNode:node];
            }
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

- (void)setVisitedWithNode:(NITNode*)node {
    [self.visitedNodes addObject:node];
}

- (void)setNotVisitedWithNode:(NITNode*)node {
    [self.visitedNodes removeObject:node];
}

- (BOOL)isAlreadyVisitedWithNode:(NITNode*)node {
    NSUInteger index = [self.visitedNodes indexOfObject:node];
    if (index != NSNotFound) {
        return YES;
    }
    return NO;
}

// MARK: - Trigger

- (void)triggerWithEvent:(NITRegionEvent)event node:(NITNode*)node {
    if (node == nil || node.identifier == nil) {
        return;
    }
    
    NSString *eventString = [NITUtils stringFromRegionEvent:event];
    NITLogD(LOGTAG, @"Trigger for event -> %@ - node -> %@", eventString, node);
    
    [self trackEventWithIdentifier:node.identifier event:event];
    
    BOOL hasIdentifier = NO;
    BOOL hasTags = NO;
    NSString *pulseAction = [NITUtils stringFromRegionEvent:event];
    
    if([self.recipesManager respondsToSelector:@selector(gotPulseWithPulsePlugin:pulseAction:pulseBundle:)]) {
        hasIdentifier = [self.recipesManager gotPulseWithPulsePlugin:self.pluginName pulseAction:pulseAction pulseBundle:node.identifier];
    }
    if (!hasIdentifier && [self.recipesManager respondsToSelector:@selector(gotPulseWithPulsePlugin:pulseAction:tags:)]) {
        NSString *pulseTagAction = [NITUtils stringTagFromRegionEvent:event];
        hasTags = [self.recipesManager gotPulseWithPulsePlugin:self.pluginName pulseAction:pulseTagAction tags:node.tags];
    }
    if (!hasIdentifier && !hasTags && [self.recipesManager respondsToSelector:@selector(gotPulseOnlineWithPulsePlugin:pulseAction:pulseBundle:)]) {
        [self.recipesManager gotPulseOnlineWithPulsePlugin:self.pluginName pulseAction:pulseAction pulseBundle:node.identifier];
    }
}

- (void)trackEventWithIdentifier:(NSString*)identifier event:(NITRegionEvent)event {
    NITJSONAPI *json = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"trackings";
    if (self.configuration.profileId && self.configuration.installationId && self.configuration.appId) {
        [resource addAttributeObject:self.configuration.profileId forKey:@"profile_id"];
        [resource addAttributeObject:self.configuration.installationId forKey:@"installation_id"];
        [resource addAttributeObject:self.configuration.appId forKey:@"app_id"];
    } else {
        NITLogW(LOGTAG, @"Can't send recipe tracking: missing data");
        return;
    }
    [resource addAttributeObject:identifier forKey:@"identifier"];
    NSString *eventString = [NITUtils stringFromRegionEvent:event];
    [resource addAttributeObject:eventString forKey:@"event"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [resource addAttributeObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"tracked_at"];
    
    [json setDataWithResourceObject:resource];
    
    [self.trackManager addTrackWithRequest:[[NITNetworkProvider sharedInstance] sendGeopolisTrackingsWithJsonApi:json]];
}

// MARK: - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    switch (state) {
        case CLRegionStateInside:
            [self stepInRegion:region];
            break;
        case CLRegionStateOutside:
            [self stepOutRegion:region];
            break;
        case CLRegionStateUnknown:
            NITLogE(LOGTAG, @"Undefined status for region in node: %@", [self.nodesManager nodeWithID:region.identifier]);
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self triggerInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self triggerOutRegion:region];
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
            continue;
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

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NITLogD(LOGTAG, @"Location update (%.4f,%.4f) %.1f seconds ago", location.coordinate.latitude, location.coordinate.longitude, fabs(howRecent));
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NITLogW(LOGTAG, @"Location manager error: %@", error);
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
