//
//  NITReaction.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITCacheManager.h"

@class NITManager;
@class NITRecipe;
@class NITNetworkManager;

@interface NITReaction : NSObject

@property (nonatomic, strong) NITCacheManager * _Nonnull cacheManager;
@property (nonatomic, strong) NITNetworkManager * _Nonnull networkManager;

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager* _Nonnull)cacheManager networkManager:(NITNetworkManager* _Nonnull)networkManager;

- (NSString* _Nonnull)pluginName;
- (void)contentWithRecipe:(NITRecipe* _Nonnull)recipe completionHandler:(void (^_Nullable)(id _Nullable content, NSError * _Nullable error))handler;
- (void)refreshConfigWithCompletionHandler:(void(^ _Nullable)(NSError * _Nullable error))handler;

@end
