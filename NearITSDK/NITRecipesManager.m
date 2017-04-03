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
#import "NITCoupon.h"
#import "NITConstants.h"
#import "NITImage.h"
#import "NITClaim.h"

#define NITRecipeStatusNotified @"notified"

@interface NITRecipesManager()

@property (nonatomic, strong) NSArray<NITRecipe*> *recipes;

@end

@implementation NITRecipesManager

- (void)setRecipesWithJsonApi:(NITJSONAPI*)json {
    [json registerClass:[NITRecipe class] forType:@"recipes"];
    self.recipes = [json parseToArrayOfObjects];
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider recipesProcessListWithJsonApi:[self buildEvaluationBody]] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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
        [self onlinePulseEvaluationWithPlugin:pulsePlugin action:pulseAction bundle:pulseBundle];
    } else {
        NITRecipe *recipe = [matchingRecipes objectAtIndex:0];
        if(recipe.isEvaluatedOnline) {
            [self evaluateRecipeWithId:recipe.ID];
        } else {
            [self gotRecipe:recipe];
        }
    }
}

- (void)processRecipe:(NSString*)recipeId {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider processRecipeWithId:recipeId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (json) {
            [self registerClassesWithJsonApi:json];
            NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
            if ([recipes count] > 0) {
                NITRecipe *recipe = [recipes objectAtIndex:0];
                [self gotRecipe:recipe];
            }
        }
    }];
}

- (void)onlinePulseEvaluationWithPlugin:(NSString*)plugin action:(NSString*)action bundle:(NSString*)bundle {
    // TODO: Online pulse evaluation
    NITJSONAPI *jsonApi = [self buildEvaluationBodyWithPlugin:plugin action:action bundle:bundle];
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider onlinePulseEvaluationWithJsonApi:jsonApi] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (json) {
            [self registerClassesWithJsonApi:json];
            NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
            if ([recipes count] > 0) {
                NITRecipe *recipe = [recipes objectAtIndex:0];
                [self gotRecipe:recipe];
            }
        }
    }];
}

- (void)evaluateRecipeWithId:(NSString*)recipeId {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider evaluateRecipeWithId:recipeId jsonApi:[self buildEvaluationBody]] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (json) {
            [self registerClassesWithJsonApi:json];
            NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
            if([recipes count] > 0) {
                NITRecipe *recipe = [recipes objectAtIndex:0];
                [self gotRecipe:recipe];
            }
        }
    }];
}

- (void)sendTrackingWithRecipeId:(NSString *)recipeId event:(NSString*)event {
    if ([event isEqualToString:NITRecipeStatusNotified]) {
        // TODO: Recipe cooler, markRecipeAsShown(recipeId)
    }
    
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"trackings";
    [resource addAttributeObject:config.profileId forKey:@"profile_id"];
    [resource addAttributeObject:config.installationId forKey:@"installation_id"];
    [resource addAttributeObject:config.appId forKey:@"app_id"];
    [resource addAttributeObject:recipeId forKey:@"recipe_id"];
    [resource addAttributeObject:event forKey:@"event"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
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

- (void)registerClassesWithJsonApi:(NITJSONAPI*)jsonApi {
    [jsonApi registerClass:[NITRecipe class] forType:@"recipes"];
    [jsonApi registerClass:[NITCoupon class] forType:@"coupons"];
    [jsonApi registerClass:[NITClaim class] forType:@"claims"];
    [jsonApi registerClass:[NITImage class] forType:@"images"];
}

- (NITJSONAPI*)buildEvaluationBody {
    return [self buildEvaluationBodyWithPlugin:nil action:nil bundle:nil];
}

- (NITJSONAPI*)buildEvaluationBodyWithPlugin:(NSString*)plugin action:(NSString*)action bundle:(NSString*)bundle {
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"evaluation";
    [resource addAttributeObject:[self buildCoreObject] forKey:@"core"];
    if(plugin) {
        [resource addAttributeObject:plugin forKey:@"pulse_plugin_id"];
    }
    if(action) {
        [resource addAttributeObject:action forKey:@"pulse_action_id"];
    }
    if(bundle) {
        [resource addAttributeObject:bundle forKey:@"pulse_bundle_id"];
    }
    [jsonApi setDataWithResourceObject:resource];
    return jsonApi;
}

// TODO: Check recipe cooler
- (NSDictionary*)buildCoreObject {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NSMutableDictionary<NSString*, NSString*> *core = [[NSMutableDictionary alloc] init];
    if (config.appId && config.profileId && config.installationId) {
        [core setObject:config.profileId forKey:@"profile_id"];
        [core setObject:config.installationId forKey:@"installation_id"];
        [core setObject:config.appId forKey:@"app_id"];
    }
    return [NSDictionary dictionaryWithDictionary:core];
}

@end
