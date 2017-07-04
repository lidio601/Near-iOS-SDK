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
#define MAX_LOCATION_TIMER_RETRY 3

@interface NITGeopolisRadar()<CLLocationManagerDelegate>

@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic) NSInteger locationTimerRetry;
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
        [self.locationManager requestLocation];
        self.started = NO;
    }
    return self;
}

// MARK: - Start

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
    
    self.locationTimerRetry = 0;
    self.locationTimer = [self makeLocationTimer];
    
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

// MARK: - Stop

- (void)stop {
    self.started = NO;
    
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
    for (CLBeaconRegion *region in self.locationManager.rangedRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    [self.locationManager stopUpdatingLocation];
    [self.nodesManager clear];
    [self.locationTimer invalidate];
    self.locationTimer = nil;
    self.locationTimerRetry = 0;
}

// MARK: - Location timer

- (void)locationTimerFired:(NSTimer*)timer {
    self.locationTimerRetry++;
    NITLogD(@"LocationTimer", @"Entered in timer: retry %d", self.locationTimerRetry);
    /* if (!self.stepResponse) {
        NITLogW(@"LocationTimer", @"Request step response by timer");
        [self.locationManager requestLocation];
        [self requestStateForRoots];
    } else {
        [self.locationTimer invalidate];
        NITLogD(@"LocationTimer", @"Invalidate timer due to a successful state");
    } */
    if (self.locationTimerRetry >= MAX_LOCATION_TIMER_RETRY) {
        NITLogW(@"LocationTimer", @"MAX_LOCATION_TIMER_RETRY reached");
        [self.locationTimer invalidate];
    } else {
        [self.locationManager requestLocation];
    }
}

// MARK: - Utils

- (CLAuthorizationStatus)locationAuthorizationStatus {
    return [CLLocationManager authorizationStatus];
}

- (NSTimer*)makeLocationTimer {
    return [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(locationTimerFired:) userInfo:nil repeats:YES];
}

// MARK: - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    NITLogD(LOGTAG, @"Location update (%.4f,%.4f) %.1f seconds ago", location.coordinate.latitude, location.coordinate.longitude, fabs(howRecent));
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

@end
