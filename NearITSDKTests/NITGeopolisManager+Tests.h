//
//  NITGeopolisManager+Tests.h
//  NearITSDK
//
//  Created by Francesco Leoni on 21/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager.h"

@class NITBeaconProximityManager;

@interface NITGeopolisManager (Tests)

- (void)stepInRegion:(CLRegion*)region;
- (void)stepOutRegion:(CLRegion*)region;
- (NSArray<CLRegion*>*)monitoredRegions;
- (NSArray<CLRegion*>*)rangedRegions;
- (BOOL)startForUnitTest;
- (NITBeaconProximityManager *)beaconProximity;

@end
