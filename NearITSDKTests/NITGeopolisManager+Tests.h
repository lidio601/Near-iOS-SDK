//
//  NITGeopolisManager+Tests.h
//  NearITSDK
//
//  Created by Francesco Leoni on 21/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager.h"
#import "NITConstants.h"

@class NITBeaconProximityManager;

@interface NITGeopolisManager (Tests)

- (void)stepInRegion:(CLRegion*)region;
- (void)stepOutRegion:(CLRegion*)region;
- (BOOL)startForUnitTest;
- (NITBeaconProximityManager *)beaconProximity;
- (NITGeopolisNodesManager*)nodesManager;
- (BOOL)started;
- (void)triggerWithEvent:(NITRegionEvent)event node:(NITNode*)node;

@end
