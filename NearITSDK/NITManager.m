//
//  NITManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITManager.h"
#import "NITConfiguration.h"
#import "NITUserProfile.h"
#import "NITUtils.h"
#import "NITGeopolisManager.h"
#import "NITReaction.h"
#import "NITSimpleNotificationReaction.h"
#import "NITRecipe.h"
#import "NITContentReaction.h"
#import "NITCouponReaction.h"
#import "NITFeedbackReaction.h"
#import "NITCustomJSONReaction.h"
#import "NITInstallation.h"
#import "NITEvent.h"
#import "NITConstants.h"

@interface NITManager()<NITManaging>

@property (nonatomic, strong) NITGeopolisManager *geopolisManager;
@property (nonatomic, strong) NITRecipesManager *recipesManager;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NITReaction*> *reactions;
@property (nonatomic, strong) NITFeedbackReaction *feedbackReaction;
@property (nonatomic, strong) NITCouponReaction *couponReaction;
@property (nonatomic) BOOL started;

@end

@implementation NITManager

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey {
    self = [super init];
    if (self) {
        [[NITConfiguration defaultConfiguration] setApiKey:apiKey];
        [[NITCacheManager sharedInstance] setAppId:[[NITConfiguration defaultConfiguration] appId]];
        
        [self pluginSetup];
        [self reactionsSetup];
        self.started = NO;
        
        [NITUserProfile createNewProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
            if(error == nil) {
                [self refreshConfigWithCompletionHandler:nil];
            }
        }];
    }
    return self;
}

- (void)start {
    self.started = YES;
    [self.geopolisManager start];
}

- (void)stop {
    self.started = NO;
    [self.geopolisManager stop];
}

- (void)pluginSetup {
    self.recipesManager = [[NITRecipesManager alloc] init];
    self.recipesManager.manager = self;
    self.geopolisManager = [[NITGeopolisManager alloc] init];
    self.geopolisManager.recipesManager = self.recipesManager;
}

- (void)reactionsSetup {
    self.reactions = [[NSMutableDictionary alloc] init];
    
    self.couponReaction = [[NITCouponReaction alloc] init];
    self.feedbackReaction = [[NITFeedbackReaction alloc] init];
    
    [self.reactions setObject:[[NITSimpleNotificationReaction alloc] init] forKey:@"simple-notification"];
    [self.reactions setObject:[[NITContentReaction alloc] init] forKey:@"content-notification"];
    [self.reactions setObject:self.couponReaction forKey:@"coupon-blaster"];
    [self.reactions setObject:self.feedbackReaction forKey:@"feedbacks"];
    [self.reactions setObject:[[NITCustomJSONReaction alloc] init] forKey:@"json-sender"];
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self.geopolisManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            [errors addObject:error];
        } else {
            if(self.started) {
                [self.geopolisManager start];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self.recipesManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            [errors addObject:error];
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionHandler) {
            if ([errors count] > 0) {
                NSError *anError = [NSError errorWithDomain:NITManagerErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@"Refresh config failed for some reason, check the 'errors' key for more detail", @"errors" : errors}];
                completionHandler(anError);
            } else {
                completionHandler(nil);
            }
        }
    });
    
    for(NSString *reactionKey in self.reactions) {
        NITReaction *reaction = [self.reactions objectForKey:reactionKey];
        [reaction refreshConfigWithCompletionHandler:nil];
    }
}

/**
 * Set the APN token for push.
 * @param deviceToken The token in string format
 */
- (void)setDeviceToken:(NSString *)deviceToken {
    [[NITConfiguration defaultConfiguration] setDeviceToken:deviceToken];
    [[NITInstallation sharedInstance] registerInstallationWithCompletionHandler:nil];
}

/**
 * Process a recipe from a remote notification.
 * @param userInfo The remote notification userInfo dictionary
 */
- (void)processRecipeWithUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    if(userInfo == nil) {
        return;
    }
    
    NSString *recipeId = [userInfo objectForKey:@"recipe_id"];
    if(recipeId) {
        [self.recipesManager processRecipe:recipeId];
    }
}

- (void)sendTrackingWithRecipeId:(NSString *)recipeId event:(NSString *)event {
    [self.recipesManager sendTrackingWithRecipeId:recipeId event:event];
}

- (void)setUserDataWithKey:(NSString *)key value:(NSString *)value completionHandler:(void (^)(NSError * _Nullable))handler {
    [NITUserProfile setUserDataWithKey:key value:value completionHandler:^(NSError * _Nullable error) {
        if (handler) {
            handler(error);
        }
        [self.recipesManager refreshConfigWithCompletionHandler:nil];
    }];
}

- (void)setBatchUserDataWithDictionary:(NSDictionary<NSString *,id> *)valuesDictiornary completionHandler:(void (^)(NSError * _Nullable))handler {
    [NITUserProfile setBatchUserDataWithDictionary:valuesDictiornary completionHandler:^(NSError * _Nullable error) {
        if (handler) {
            handler(error);
        }
        [self.recipesManager refreshConfigWithCompletionHandler:nil];
    }];
}

- (void)sendEventWithEvent:(NITEvent *)event completionHandler:(void (^)(NSError * _Nullable))handler {
    if ([[event pluginName] isEqualToString:NITFeedbackPluginName]) {
        [self.feedbackReaction sendEventWithFeedbackEvent:(NITFeedbackEvent*)event completionHandler:^(NSError * _Nullable error) {
            if (handler) {
                handler(error);
            }
        }];
    } else if (handler) {
        NSError *newError = [NSError errorWithDomain:NITReactionErrorDomain code:201 userInfo:@{NSLocalizedDescriptionKey:@"Unrecognized event action"}];
        handler(newError);
    }
}

- (void)couponsWithCompletionHandler:(void (^)(NSArray<NITCoupon*>*, NSError*))handler {
    [self.couponReaction couponsWithCompletionHandler:^(NSArray<NITCoupon *> * coupons, NSError * error) {
        if (handler) {
            handler(coupons, error);
        }
    }];
}

- (NSArray<NITRecipe *> *)recipes {
    NSArray<NITRecipe*> *recipes = [self.recipesManager recipes];
    if (recipes) {
        return recipes;
    }
    return [NSArray array];
}

- (void)processRecipeWithId:(NSString *)recipeId  {
    [self.recipesManager processRecipe:recipeId];
}

- (void)resetProfile {
    [NITUserProfile resetProfile];
}

// MARK: - NITManaging

- (void)recipesManager:(NITRecipesManager *)recipesManager gotRecipe:(NITRecipe *)recipe {
    //Handle reaction
    NITReaction *reaction = [self.reactions objectForKey:recipe.reactionPluginId];
    if(reaction) {
        [reaction contentWithRecipe:recipe completionHandler:^(id _Nonnull content, NSError * _Nullable error) {
            if(error) {
                if([self.delegate respondsToSelector:@selector(manager:eventFailureWithError:recipe:)]) {
                    [self.delegate manager:self eventFailureWithError:error recipe:recipe];
                }
            } else {
                //Notify the delegate
                if ([self.delegate respondsToSelector:@selector(manager:eventWithContent:recipe:)]) {
                    [self.delegate manager:self eventWithContent:content recipe:recipe];
                }
            }
        }];
    }
}

@end
