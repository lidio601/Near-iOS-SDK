//
//  NITRecipeCooler.m
//  NearITSDK
//
//  Created by Francesco Leoni on 03/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipeCooler.h"
#import "NITRecipe.h"

@interface NITRecipeCooler()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *log;
@property (nonatomic) NSTimeInterval latestLog;

@end

// TODO: Manage cache
@implementation NITRecipeCooler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.log = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)markRecipeAsShownWithId:(NSString *)recipeId {
    NSDate *now = [NSDate date];
    NSTimeInterval timestamp = now.timeIntervalSince1970;
    [self.log setObject:[NSNumber numberWithDouble:timestamp] forKey:recipeId];
    self.latestLog = timestamp;
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
    
    NSDate *now = [NSDate date];
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - self.latestLog;
    return expiredSeconds >= [globalCooldown doubleValue];
}

- (BOOL)selfCooldownCheckWithRecipe:(NITRecipe*)recipe cooldown:(NSDictionary<NSString*, id>*)cooldown {
    id selfCooldown = [cooldown objectForKey:@"self_cooldown"];
    if (selfCooldown == nil || [selfCooldown isEqual:[NSNull null]] || ![selfCooldown isKindOfClass:[NSNumber class]] || [self.log objectForKey:recipe.ID] == nil) {
        return YES;
    }
    
    NSDate *now = [NSDate date];
    NSTimeInterval recipeLatestLog = [[self.log objectForKey:recipe.ID] doubleValue];
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - recipeLatestLog;
    return expiredSeconds >= [selfCooldown doubleValue];
}

@end
