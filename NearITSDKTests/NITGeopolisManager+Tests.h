//
//  NITGeopolisManager+Tests.h
//  NearITSDK
//
//  Created by Francesco Leoni on 21/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager.h"

@interface NITGeopolisManager (Tests)

- (void)testStepInRegion:(CLRegion* _Nonnull)region;
- (void)testStepOutRegion:(CLRegion* _Nonnull)region;
- (void)testAllNodes:(NSError**)anError;

@end
