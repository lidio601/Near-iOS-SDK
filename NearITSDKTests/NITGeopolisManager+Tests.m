//
//  NITGeopolisManager+Tests.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager+Tests.h"
#import "NITGeopolisNodesManager.h"
#import "NITNode.h"
#import <CoreLocation/CoreLocation.h>

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";

@interface NITGeopolisManager()

- (void)stepInRegion:(CLRegion*)region;
- (void)stepOutRegion:(CLRegion*)region;
- (void)startMonitoringRoots;

@end

@implementation NITGeopolisManager (Tests)

- (BOOL)startForUnitTest {
    if(self.started) {
        return YES;
    }
    
    [self startMonitoringRoots];
    return YES;
}

@end
