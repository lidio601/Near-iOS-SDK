//
//  NITGeopolisManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITRecipesManager.h"

@class CLRegion;
@class NITNode;
@class NITNodesManager;

@interface NITGeopolisManager : NSObject

@property (nonatomic, weak) id<NITRecipesManaging> _Nullable recipesManager;

- (instancetype _Nonnull)initWithNodesManager:(NITNodesManager* _Nonnull)nodesManager;

- (void)refreshConfigWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))completionHandler;
- (BOOL)start;
- (BOOL)startForUnitTest;
- (void)stop;
- (BOOL)hasCurrentNode;
- (NSArray<NITNode*>* _Nullable)nodes;

@end
