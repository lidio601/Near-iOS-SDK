//
//  NITGeopolisRadar.m
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisRadar.h"
#import "NITGeopolisNodesManager.h"
#import "NITLog.h"
#import <CoreLocation/CoreLocation.h>
#import "NITNode.h"
#import "NITGeofenceNode.h"
#import "NITBeaconNode.h"

#define LOGTAG @"GeopolisRadar"

@interface NITGeopolisRadar()<CLLocationManagerDelegate>

@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL started;

@end

@implementation NITGeopolisRadar

- (instancetype)initWithDelegate:(id<NITGeopolisRadarDelegate>)delegate nodesManager:(NITGeopolisNodesManager *)nodesManager locationManager:(CLLocationManager *)locationManager {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.nodesManager = nodesManager;
        self.locationManager = locationManager;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
        self.started = NO;
    }
    return self;
}

- (BOOL)start {
    if(self.started) {
        return YES;
    }
    
    NITLogD(LOGTAG, @"Geopolis radar start");
    
    if([[self.nodesManager roots] count] == 0) {
        return NO;
    }
    
    CLAuthorizationStatus authorizationStatus = [self locationAuthorizationStatus];
    if (authorizationStatus != kCLAuthorizationStatusAuthorizedWhenInUse && authorizationStatus != kCLAuthorizationStatusAuthorizedAlways) {
        NITLogE(LOGTAG, @"Geopolis couldn't start radar: CLLocationManager authorizationStatus is wrong");
        return NO;
    }
    self.started = YES;
    
    [self startMonitoringRoots];
    
    return YES;
}

- (BOOL)isStarted {
    return self.started;
}

- (void)startMonitoringRoots {
    NITLogD(LOGTAG, @"Geopolis start monitoring roots");
    NSArray<NITNode*> *roots = [self.nodesManager roots];
    for (NITNode *node in roots) {
        CLRegion *region = [node createRegion];
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager requestStateForRegion:region];
    }
}


- (CLAuthorizationStatus)locationAuthorizationStatus {
    return [CLLocationManager authorizationStatus];
}

// MARK: - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

@end
