//
//  NITStubGeopolisRadar.m
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITStubGeopolisRadar.h"
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface NITStubGeopolisRadar()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSTimer *locationTimer;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)locationTimerFired:(NSTimer*)timer;

@end

@implementation NITStubGeopolisRadar

- (instancetype)initWithDelegate:(id<NITGeopolisRadarDelegate>)delegate nodesManager:(NITGeopolisNodesManager *)nodesManager locationManager:(CLLocationManager *)locationManager beaconProximityManager:(NITBeaconProximityManager * _Nonnull)beaconProximity {
    self = [super initWithDelegate:delegate nodesManager:nodesManager locationManager:locationManager beaconProximityManager:beaconProximity];
    if (self) {
        self.authorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    }
    return self;
}

- (CLAuthorizationStatus)locationAuthorizationStatus {
    return self.authorizationStatus;
}

- (NSTimer*)makeLocationTimer {
    if (self.stubLocationTimer) {
        return self.stubLocationTimer;
    }
    return mock([NSTimer class]);
}

- (void)fireLocationTimer {
    [self locationTimerFired:self.locationTimer];
}

- (void)simulateDidDetermineStateWithRegion:(CLRegion *)region state:(CLRegionState)state {
    if ([self respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
        [self locationManager:self.locationManager didDetermineState:state forRegion:region];
    }
}

- (void)simulateDidEnterRegion:(CLRegion*)region {
    if ([self respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
        [self locationManager:self.locationManager didEnterRegion:region];
    }
    if ([self respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
        [self locationManager:self.locationManager didDetermineState:CLRegionStateInside forRegion:region];
    }
}

- (void)simulateDidExitRegion:(CLRegion*)region {
    if ([self respondsToSelector:@selector(locationManager:didExitRegion:)]) {
        [self locationManager:self.locationManager didExitRegion:region];
    }
    if ([self respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
        [self locationManager:self.locationManager didDetermineState:CLRegionStateOutside forRegion:region];
    }
}

- (void)simulateDidRangeBeacons:(NSArray<CLBeacon*>*)beacons region:(CLBeaconRegion*)region {
    if ([self respondsToSelector:@selector(locationManager:didRangeBeacons:inRegion:)]) {
        [self locationManager:self.locationManager didRangeBeacons:beacons inRegion:region];
    }
}

@end
