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

@interface NITGeopolisManager : NSObject

@property (nonatomic, weak) id<NITRecipesManaging> _Nullable recipesManager;

- (void)refreshConfigWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))completionHandler;
- (BOOL)start;
- (BOOL)startForUnitTest;
- (void)stop;
- (BOOL)hasCurrentNode;
- (NSArray<NITNode*>* _Nullable)nodes;

@end
