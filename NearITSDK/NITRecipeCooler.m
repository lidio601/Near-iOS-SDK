//
//  NITRecipeCooler.m
//  NearITSDK
//
//  Created by Francesco Leoni on 03/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipeCooler.h"
#import "NITRecipe.h"
#import "NITCacheManager.h"
#import "NITDateManager.h"

#define LOGMAP_CACHE_KEY @"CoolerLogMap"
#define LATESTLOG_CACHE_KEY @"CoolerLatestLog"

@interface NITRecipeCooler()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *log;
@property (nonatomic, strong) NSNumber *latestLog;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITDateManager *dateManager;

@end

@implementation NITRecipeCooler

@synthesize log = _log;
@synthesize latestLog = _latestLog;

- (instancetype)initWithCacheManager:(NITCacheManager*)cacheManager dateManager:(NITDateManager*)dateManager {
    self = [super init];
    if (self) {
        self.cacheManager = cacheManager;
        self.dateManager = dateManager;
    }
    return self;
}

- (void)markRecipeAsShownWithId:(NSString *)recipeId {
    NSDate *now = [self.dateManager currentDate];
    NSTimeInterval timestamp = now.timeIntervalSince1970;
    [self.log setObject:[NSNumber numberWithDouble:timestamp] forKey:recipeId];
    self.latestLog = [NSNumber numberWithDouble:timestamp];
    [self.cacheManager saveWithObject:self.log forKey:LOGMAP_CACHE_KEY];
    [self.cacheManager saveWithObject:self.latestLog forKey:LATESTLOG_CACHE_KEY];
}

- (NSArray<NITRecipe *> *)filterRecipeWithRecipes:(NSArray<NITRecipe *> *)recipes {
    NSMutableArray<NITRecipe*> *filteredRecipes = [[NSMutableArray alloc] init];
    for (NITRecipe *recipe in recipes) {
        if ([self canShowRecipe:recipe]) {
            [filteredRecipes addObject:recipe];
        }
    }
    return [NSArray arrayWithArray:filteredRecipes];
}

- (BOOL)canShowRecipe:(NITRecipe*)recipe {
    NSDictionary<NSString*, id> *cooldown = recipe.cooldown;
    BOOL cooldownCheck = [self globalCooldownCheck:cooldown] && [self selfCooldownCheckWithRecipe:recipe cooldown:cooldown];
    return cooldown == nil || cooldownCheck;
}

- (BOOL)globalCooldownCheck:(NSDictionary<NSString*, id>*)cooldown {
    id globalCooldown = [cooldown objectForKey:@"global_cooldown"];
    if (globalCooldown == nil || [globalCooldown isEqual:[NSNull null]] || ![globalCooldown isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    
    NSDate *now = [self.dateManager currentDate];
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - [self.latestLog doubleValue];
    return expiredSeconds >= [globalCooldown doubleValue];
}

- (BOOL)selfCooldownCheckWithRecipe:(NITRecipe*)recipe cooldown:(NSDictionary<NSString*, id>*)cooldown {
    id selfCooldown = [cooldown objectForKey:@"self_cooldown"];
    if (selfCooldown == nil || [selfCooldown isEqual:[NSNull null]] || ![selfCooldown isKindOfClass:[NSNumber class]] || [self.log objectForKey:recipe.ID] == nil) {
        return YES;
    }
    
    if ([selfCooldown intValue] == [kRecipeNeverRepeat intValue] && [self.log objectForKey:recipe.ID] != nil) {
        return NO;
    }
    
    NSDate *now = [self.dateManager currentDate];
    NSTimeInterval recipeLatestLog = [[self.log objectForKey:recipe.ID] doubleValue];
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - recipeLatestLog;
    return expiredSeconds >= [selfCooldown doubleValue];
}

- (NSMutableDictionary<NSString *,NSNumber *> *)log {
    if (_log == nil) {
        NSDictionary<NSString*, NSNumber*> *savedLog = [self.cacheManager loadDictionaryForKey:LOGMAP_CACHE_KEY];
        if (savedLog) {
            _log = [savedLog mutableCopy];
        } else {
            _log = [[NSMutableDictionary alloc] init];
        }
    }
    return _log;
}

- (NSNumber*)latestLog {
    if (_latestLog == nil) {
        NSNumber *savedLatestLog = [self.cacheManager loadNumberForKey:LATESTLOG_CACHE_KEY];
        if (savedLatestLog) {
            _latestLog = savedLatestLog;
        } else {
            _latestLog = [NSNumber numberWithDouble:0];
        }
    }
    return _latestLog;
}

@end
