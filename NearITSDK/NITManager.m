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
#import "NITInstallation.h"

@interface NITManager()<NITManaging>

@property (nonatomic, strong) NITGeopolisManager *geopolisManager;
@property (nonatomic, strong) NITRecipesManager *recipesManager;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NITReaction*> *reactions;
@property (nonatomic) BOOL started;

@end

@implementation NITManager

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey {
    self = [super init];
    if (self) {
        [[NITConfiguration defaultConfiguration] setApiKey:apiKey];
        [[NITConfiguration defaultConfiguration] setAppId:[NITUtils fetchAppIdFromApiKey:apiKey]];
        
        [self pluginSetup];
        [self reactionsSetup];
        self.started = NO;
        
        [NITUserProfile createNewProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
            if(error == nil) {
                [self refreshConfig];
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
    
    [self.reactions setObject:[[NITSimpleNotificationReaction alloc] init] forKey:@"simple-notification"];
    [self.reactions setObject:[[NITContentReaction alloc] init] forKey:@"content-notification"];
}

- (void)refreshConfig {
    [self.geopolisManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        if(self.started) {
            [self.geopolisManager start];
        }
    }];
    [self.recipesManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
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
        [self.recipesManager sendTracking:recipeId];
        [self.recipesManager processRecipe:recipeId];
    }
}


// MARK: - NITManaging

- (void)recipesManager:(NITRecipesManager *)recipesManager gotRecipe:(NITRecipe *)recipe {
    //Handle reaction
    NITReaction *reaction = [self.reactions objectForKey:recipe.reactionPluginId];
    if(reaction) {
        [reaction contentWithRecipe:recipe completionHandler:^(id _Nonnull content, NSError * _Nullable error) {
            if(error) {
                if([self.delegate respondsToSelector:@selector(manager:eventFailureWithError:)]) {
                    [self.delegate manager:self eventFailureWithError:error];
                }
            } else {
                //Notify the delegate
                if ([self.delegate respondsToSelector:@selector(manager:eventWithContent:)]) {
                    [self.delegate manager:self eventWithContent:content];
                }
            }
        }];
    }
}

@end
