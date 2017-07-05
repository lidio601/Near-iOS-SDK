//
//  NITStubGeopolisRadar.h
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisRadar.h"
#import <CoreLocation/CoreLocation.h>

@interface NITStubGeopolisRadar : NITGeopolisRadar

@property (nonatomic) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) NSTimer * _Nullable stubLocationTimer;

- (CLAuthorizationStatus)locationAuthorizationStatus;
- (void)fireLocationTimer;
- (void)simulateDidDetermineStateWithRegion:(CLRegion* _Nonnull)region state:(CLRegionState)state;
- (void)simulateDidRangeBeacons:(NSArray<CLBeacon*>* _Nonnull)beacons region:(CLBeaconRegion* _Nonnull)region;
- (void)simulateDidEnterRegion:(CLRegion* _Nonnull)region;
- (void)simulateDidExitRegion:(CLRegion* _Nonnull)region;

@end
