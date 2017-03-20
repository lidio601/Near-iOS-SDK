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

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";

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
@property (nonatomic, strong) NSMutableArray<CLRegion*> *monitoredRegions; //For test purpose
@property (nonatomic, strong) NSMutableArray<CLRegion*> *rangedRegions; // For test purpose
@property (nonatomic) BOOL started;

@end

@implementation NITGeopolisManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.nodesManager = [[NITNodesManager alloc] init];
        self.monitoredRegions = [[NSMutableArray alloc] init];
        self.rangedRegions = [[NSMutableArray alloc] init];
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
        CLRegion *region = [node createRegion];
        [self.locationManager startMonitoringForRegion:region];
        [self.monitoredRegions addObject:region];
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
            [self.monitoredRegions addObject:region];
            NSLog(@"%@", self.locationManager.monitoredRegions);
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
        [self.rangedRegions addObject:currentRegion];
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

// MARK: - Tests

- (void)testStepInRegion:(CLRegion*)region {
    [self stepInRegion:region];
}

- (void)testStepOutRegion:(CLRegion*)region {
    [self stepOutRegion:region];
}

- (BOOL)testVerifyMonitoringWithNode:(NITNode*)node error:(NSError**)anError {
    CLRegion *nodeRegion = [node createRegion];
    
    if ([nodeRegion isKindOfClass:[CLBeaconRegion class]]) {
        
        if ([self.rangedRegions count] == 0) {
            if (anError != NULL) {
                NSString *description = [NSString stringWithFormat:@"Ranged regions is wrong: %lu", (unsigned long)[self.rangedRegions count]];
                *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
            }
            return NO;
        }
        
        if ([node isLeaf]) {
            return YES;
        }
        
        CLRegion *foundRegion = nil;
        NSArray<CLRegion*> *regions = self.rangedRegions;
        for (CLRegion *region in regions) {
            if([region.identifier isEqualToString:nodeRegion.identifier]) {
                foundRegion = region;
                break;
            }
        }
        
        if(foundRegion == nil) {
            NSString *description = [NSString stringWithFormat:@"No region found in ranging"];
            *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
            return NO;
        }
        
        return YES;
    } else {
        NSInteger nodesCount = 1 + [node.children count];
        if ([self.monitoredRegions count] != nodesCount) {
            if (anError != NULL) {
                NSString *description = [NSString stringWithFormat:@"The number of monitoredRegions is wrong: %lu", (unsigned long)[self.locationManager.monitoredRegions count]];
                *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description, NodeKey: node}];
            }
            return NO;
        }
        
        NSMutableDictionary<NSString*, NSNumber*> *regionsMap = [[NSMutableDictionary alloc] init];
        for(CLRegion *region in self.monitoredRegions) {
            [regionsMap setObject:[NSNumber numberWithBool:NO] forKey:region.identifier];
        }
        
        if ([regionsMap objectForKey:node.ID]) {
            [regionsMap setObject:[NSNumber numberWithBool:YES] forKey:node.ID];
        }
        
        for(NITNode *child in node.children) {
            if ([regionsMap objectForKey:child.ID]) {
                [regionsMap setObject:[NSNumber numberWithBool:YES] forKey:child.ID];
            }
        }
        
        for(NSString *key in regionsMap) {
            if (![regionsMap objectForKey:key]) {
                if (anError != NULL) {
                    NSString *description = [NSString stringWithFormat:@"The regions map is wrong"];
                    *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
                }
                return NO;
            }
        }
        
        return YES;
    }
    return NO;
}

- (void)testAllNodes:(NSError**)anError {
    for (NITNode *node in [self.nodesManager nodes]) {
        NSError *nodeError;
        BOOL result = [self testWithNode:node error:&nodeError];
        if (nodeError) {
            *anError = nodeError;
            break;
        } else if(!result) {
            *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Generic error"}];
            break;
        }
    }
}

- (BOOL)testWithNode:(NITNode*)node error:(NSError**)anError {
    [self testStepInRegion:[node createRegion]];
    NSError *nodeError;
    if([self testVerifyMonitoringWithNode:node error:&nodeError]) {
        NITNode *firstChild = [node firstChild];
        NITNode *nextSibling = [node nextSibling];
        if (firstChild) {
            NSError *childError;
            if([self testWithNode:firstChild error:&childError]) {
                if (nextSibling) {
                    NSError *siblingError;
                    [self testStepOutRegion:[node createRegion]];
                    if([self testWithNode:nextSibling error:&siblingError]) {
                        return YES;
                    } else {
                        *anError = siblingError;
                        return NO;
                    }
                } else {
                    [self testStepOutRegion:[node createRegion]];
                    return YES;
                }
            } else {
                *anError = childError;
                return NO;
            }
        } else if(nextSibling) {
            NSError *siblingError;
            [self testStepOutRegion:[node createRegion]];
            if([self testWithNode:nextSibling error:&siblingError]) {
                return YES;
            } else {
                *anError = siblingError;
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        *anError = nodeError;
        return NO;
    }
    return NO;
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

// MARK: - Utils

- (NSArray *)nodes {
    return [self.nodesManager nodes];
}

@end
