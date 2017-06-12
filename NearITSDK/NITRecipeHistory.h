//
//  NITRecipeHistory.h
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITCacheManager;
@class NITDateManager;

@interface NITRecipeHistory : NSObject

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager* _Nonnull)cacheManager dateManager:(NITDateManager* _Nonnull)dateManager;

- (void)markRecipeAsShownWithId:(NSString* _Nonnull)recipeId;
- (NSNumber* _Nonnull)latestLog;
- (NSMutableDictionary<NSString *,NSNumber *> * _Nonnull)log;
- (BOOL)isRecipeInLogWithId:(NSString* _Nonnull)recipeId;
- (NSNumber* _Nullable)latestLogEntryWithId:(NSString* _Nonnull)recipeId;

@end
