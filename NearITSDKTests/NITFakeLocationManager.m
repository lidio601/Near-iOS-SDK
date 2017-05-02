//
//  NITFakeLocationManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 19/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITFakeLocationManager.h"

@interface NITFakeLocationManager()

@property (nonatomic, strong) NSMutableArray<CLRegion*> *fakeMonitoredRegions;
@property (nonatomic, strong) NSMutableArray<CLRegion*> *fakeRangedRegions;

@end

@implementation NITFakeLocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.fakeMonitoredRegions = [[NSMutableArray alloc] init];
        self.fakeRangedRegions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSSet<CLRegion *> *)monitoredRegions {
    return [NSSet setWithArray:self.fakeMonitoredRegions];
}

- (NSSet<CLRegion *> *)rangedRegions {
    return [NSSet setWithArray:self.fakeRangedRegions];
}

- (void)startMonitoringForRegion:(CLRegion *)region {
    [self.fakeMonitoredRegions addObject:region];
}

- (void)stopMonitoringForRegion:(CLRegion *)region {
    [self.fakeMonitoredRegions removeObject:region];
}

- (void)startRangingBeaconsInRegion:(CLBeaconRegion *)region {
    [self.fakeRangedRegions addObject:region];
}

- (void)stopRangingBeaconsInRegion:(CLBeaconRegion *)region {
    [self.fakeRangedRegions removeObject:region];
}

- (void)simulateDidDetermineStateWithRegion:(CLRegion *)region state:(CLRegionState)state {
    if ([self.delegate respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
        [self.delegate locationManager:self didDetermineState:state forRegion:region];
    }
    if ([self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)] && state == CLRegionStateInside) {
        [self.delegate locationManager:self didEnterRegion:region];
    } else if ([self.delegate respondsToSelector:@selector(locationManager:didExitRegion:)] && state == CLRegionStateOutside) {
        [self.delegate locationManager:self didExitRegion:region];
    }
}

- (void)simulateDidRangeBeacons:(NSArray<CLBeacon*>*)beacons region:(CLBeaconRegion*)region {
    if ([self.delegate respondsToSelector:@selector(locationManager:didRangeBeacons:inRegion:)]) {
        [self.delegate locationManager:self didRangeBeacons:beacons inRegion:region];
    }
}

@end
