//
//  NITGeopolisManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITRecipesManager.h"
#import "NITNetworkManaging.h"

@class CLRegion;
@class NITNode;
@class NITNodesManager;
@class NITCacheManager;
@class NITNetworkManager;
@class NITConfiguration;
@class CLLocationManager;

@interface NITGeopolisManager : NSObject

@property (nonatomic, weak) id<NITRecipesManaging> _Nullable recipesManager;

- (instancetype _Nonnull)initWithNodesManager:(NITNodesManager* _Nonnull)nodesManager cachaManager:(NITCacheManager* _Nonnull)cacheManager networkManager:(id<NITNetworkManaging> _Nonnull)networkManager configuration:(NITConfiguration* _Nonnull)configuration locationManager:(CLLocationManager* _Nullable)locationManager;

- (void)refreshConfigWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))completionHandler;
- (BOOL)start;
- (void)stop;
- (BOOL)hasCurrentNode;
- (NSArray<NITNode*>* _Nullable)nodes;

@end
