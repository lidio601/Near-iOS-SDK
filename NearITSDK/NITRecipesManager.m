//
//  NITRecipesManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipesManager.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITJSONAPI.h"
#import "NITRecipe.h"
#import "NITJSONAPIResource.h"
#import "NITConfiguration.h"

@interface NITRecipesManager()

@property (nonatomic, strong) NSArray<NITRecipe*> *recipes;

@end

@implementation NITRecipesManager

- (void)setRecipesWithJsonApi:(NITJSONAPI*)json {
    self.recipes = [json parseToArrayOfObjects];
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider recipesProcessList] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        [json registerClass:[NITRecipe class] forType:@"recipes"];
        self.recipes = [json parseToArrayOfObjects];
        completionHandler(error);
    }];
}

// MARK: - NITRecipesManaging

- (void)gotPulseWithPulsePlugin:(NSString *)pulsePlugin pulseAction:(NSString *)pulseAction pulseBundle:(NSString *)pulseBundle {
    NSMutableArray<NITRecipe*> *matchingRecipes = [[NSMutableArray alloc] init];
    
    for (NITRecipe *recipe in self.recipes) {
        if ([recipe.pulsePluginId isEqualToString:pulsePlugin] && [recipe.pulseAction.ID isEqualToString:pulseAction] && [recipe.pulseBundle.ID isEqualToString:pulseBundle]) {
            [matchingRecipes addObject:recipe];
        }
    }
    
    NSDate *now = [NSDate date];
    NSMutableArray<NITRecipe*> *validRecipes = [[NSMutableArray alloc] init];
    for (NITRecipe *recipe in matchingRecipes) {
        if([recipe isScheduledNow:now]) {
            [validRecipes addObject:recipe];
        }
    }
    
    if ([validRecipes count] == 0) {
        // TODO: Online pulse evaluation
    } else {
        [self gotRecipe:[matchingRecipes objectAtIndex:0]];
    }
}

- (void)processRecipe:(NSString*)recipeId {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider processRecipeWithId:recipeId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (json) {
            [json registerClass:[NITRecipe class] forType:@"recipes"];
            NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
            if ([recipes count] > 0) {
                NITRecipe *recipe = [recipes objectAtIndex:0];
                [self gotRecipe:recipe];
            }
        }
    }];
}

- (void)sendTracking:(NSString *)recipeId {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"trackings";
    [resource addAttributeObject:config.profileId forKey:@"profile_id"];
    [resource addAttributeObject:config.installationId forKey:@"installation_id"];
    [resource addAttributeObject:config.appId forKey:@"app_id"];
    [resource addAttributeObject:recipeId forKey:@"recipe_id"];
    // TODO: Pass event as argument
    [resource addAttributeObject:@"engaged" forKey:@"event"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    [resource addAttributeObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"tracked_at"];
    
    [jsonApi setDataWithResourceObject:resource];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider sendTrackingsWithJsonApi:jsonApi] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        
    }];
}

- (void)gotRecipe:(NITRecipe*)recipe {
    if ([self.manager respondsToSelector:@selector(recipesManager:gotRecipe:)]) {
        [self.manager recipesManager:self gotRecipe:recipe];
    }
}

@end
