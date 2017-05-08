//
//  NITRecipeCooler.h
//  NearITSDK
//
//  Created by Francesco Leoni on 03/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRecipeNeverRepeat @-1

@class NITRecipe;
@class NITCacheManager;
@class NITDateManager;

@interface NITRecipeCooler : NSObject

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager* _Nonnull)cacheManager dateManager:(NITDateManager* _Nonnull)dateManager;

- (void)markRecipeAsShownWithId:(NSString* _Nonnull)recipeId;
- (NSArray<NITRecipe*>* _Nonnull)filterRecipeWithRecipes:(NSArray<NITRecipe*>* _Nonnull)recipes;
- (NSNumber* _Nonnull)latestLog;
- (NSMutableDictionary<NSString *,NSNumber *> * _Nonnull)log;

@end
