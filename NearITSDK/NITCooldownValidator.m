//
//  NITCooldownValidator.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCooldownValidator.h"
#import "NITDateManager.h"
#import "NITRecipeHistory.h"
#import "NITRecipe.h"

@interface NITCooldownValidator()

@property (nonatomic, strong) NITRecipeHistory *recipeHistory;
@property (nonatomic, strong) NITDateManager *dateManager;

@end

@implementation NITCooldownValidator

- (instancetype)initWithRecipeHistory:(NITRecipeHistory *)recipeHistory dateManager:(NITDateManager *)dateManager {
    self = [super init];
    if (self) {
        self.recipeHistory = recipeHistory;
        self.dateManager = dateManager;
    }
    return self;
}

- (BOOL)isValidWithRecipe:(NITRecipe *)recipe {
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
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - [self.recipeHistory.latestLog doubleValue];
    return expiredSeconds >= [globalCooldown doubleValue];
}

- (BOOL)selfCooldownCheckWithRecipe:(NITRecipe*)recipe cooldown:(NSDictionary<NSString*, id>*)cooldown {
    id selfCooldown = [cooldown objectForKey:@"self_cooldown"];
    if (selfCooldown == nil || [selfCooldown isEqual:[NSNull null]] || ![selfCooldown isKindOfClass:[NSNumber class]] || ![self.recipeHistory isRecipeInLogWithId:recipe.ID]) {
        return YES;
    }
    
    if ([selfCooldown intValue] == [kCooldwonNeverRepeat intValue] && [self.recipeHistory isRecipeInLogWithId:recipe.ID]) {
        return NO;
    }
    
    NSDate *now = [self.dateManager currentDate];
    NSTimeInterval recipeLatestLog = [[self.recipeHistory latestLogEntryWithId:recipe.ID] doubleValue];
    NSTimeInterval expiredSeconds = now.timeIntervalSince1970 - recipeLatestLog;
    return expiredSeconds >= [selfCooldown doubleValue];
}

@end
