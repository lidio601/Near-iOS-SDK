//
//  NITRecipeHistory.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipeHistory.h"
#import "NITCacheManager.h"
#import "NITDateManager.h"

#define LOGMAP_CACHE_KEY @"RecipeHistoryLogMap"
#define LATESTLOG_CACHE_KEY @"RecipeHistoryLatestLog"

@interface NITRecipeHistory()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *log;
@property (nonatomic, strong) NSNumber *latestLog;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITDateManager *dateManager;

@end

@implementation NITRecipeHistory

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

- (BOOL)isRecipeInLogWithId:(NSString *)recipeId {
    NSNumber *item = [[self log] objectForKey:recipeId];
    if (item) {
        return YES;
    }
    return NO;
}

- (NSNumber *)latestLogEntryWithId:(id)recipeId {
    return [[self log] objectForKey:recipeId];
}

@end
