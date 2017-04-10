//
//  NITRecipesManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 20/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITManager.h"

@class NITJSONAPI;
@class NITCacheManager;
@class NITNetworkManager;

@protocol NITRecipesManaging <NSObject>

- (void)setRecipesWithJsonApi:(NITJSONAPI* _Nullable)json;
- (void)gotPulseWithPulsePlugin:(NSString* _Nonnull)pulsePlugin pulseAction:(NSString* _Nonnull)pulseAction pulseBundle:(NSString* _Nullable)pulseBundle;

@end

@interface NITRecipesManager : NSObject<NITRecipesManaging>

@property (nonatomic, strong) id<NITManaging> _Nullable manager;

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager* _Nonnull)cacheManager networkManager:(NITNetworkManager*)networkManager;

- (void)refreshConfigWithCompletionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;
- (void)processRecipe:(NSString* _Nonnull)recipeId;
- (void)sendTrackingWithRecipeId:(NSString * _Nonnull)recipeId event:(NSString* _Nonnull)event;
- (NSInteger)recipesCount;
- (NSArray<NITRecipe *> * _Nullable)recipes;

@end
