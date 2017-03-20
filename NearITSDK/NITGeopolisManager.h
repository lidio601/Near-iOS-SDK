//
//  NITGeopolisManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLRegion;
@class NITNode;

@interface NITGeopolisManager : NSObject

- (void)refreshConfigWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))completionHandler;
- (BOOL)start;
- (BOOL)startForUnitTest;
- (void)stop;
- (BOOL)hasCurrentNode;
- (void)testStepInRegion:(CLRegion* _Nonnull)region;
- (void)testStepOutRegion:(CLRegion* _Nonnull)region;
- (NSArray<NITNode*>* _Nullable)nodes;
- (void)testAllNodes:(NSError** _Nonnull)anError;

@end
