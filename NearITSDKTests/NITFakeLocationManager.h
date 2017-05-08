//
//  NITFakeLocationManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 19/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface NITFakeLocationManager : CLLocationManager

- (void)simulateDidDetermineStateWithRegion:(CLRegion* _Nonnull)region state:(CLRegionState)state;
- (void)simulateDidRangeBeacons:(NSArray<CLBeacon*>* _Nonnull)beacons region:(CLBeaconRegion* _Nonnull)region;
- (void)simulateDidEnterRegion:(CLRegion* _Nonnull)region;
- (void)simulateDidExitRegion:(CLRegion* _Nonnull)region;

@end
