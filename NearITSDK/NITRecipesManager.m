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
#import "NITRecipeCooler.h"
#import "NITCacheManager.h"

#define NITRecipeStatusNotified @"notified"

NSString* const RecipesCacheKey = @"Recipes";

@interface NITRecipesManager()

@property (nonatomic, strong) NSArray<NITRecipe*> *recipes;
@property (nonatomic, strong) NITRecipeCooler *cooler;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITNetworkManager *networkManager;

@end

@implementation NITRecipesManager

- (instancetype)initWithCacheManager:(NITCacheManager*)cacheManager networkManager:(NITNetworkManager *)networkManager {
    self = [super init];
    if (self) {
        self.cooler = [[NITRecipeCooler alloc] initWithCacheManager:cacheManager];
        self.cacheManager = cacheManager;
        self.networkManager = networkManager;
    }
    return self;
}

- (void)setRecipesWithJsonApi:(NITJSONAPI*)json {
    [json registerClass:[NITRecipe class] forType:@"recipes"];
    self.recipes = [json parseToArrayOfObjects];
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler {
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider recipesProcessListWithJsonApi:[self buildEvaluationBody]] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            NSArray<NITRecipe*> *cachedRecipes = [self.cacheManager loadArrayForKey:RecipesCacheKey];
            if (cachedRecipes) {
                self.recipes = cachedRecipes;
                if (completionHandler) {
                    completionHandler(nil);
                }
            } else {
                if (completionHandler) {
                    completionHandler(error);
                }
            }
        } else {
            [json registerClass:[NITRecipe class] forType:@"recipes"];
            self.recipes = [json parseToArrayOfObjects];
            [self.cacheManager saveWithObject:self.recipes forKey:RecipesCacheKey];
            if (completionHandler) {
                completionHandler(error);
            }
        }
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
    
    NSArray<NITRecipe*> *recipes = [self.cooler filterRecipeWithRecipes:validRecipes];
    
    if ([recipes count] == 0) {
        [self onlinePulseEvaluationWithPlugin:pulsePlugin action:pulseAction bundle:pulseBundle];
    } else {
        NITRecipe *recipe = [recipes objectAtIndex:0];
        if(recipe.isEvaluatedOnline) {
            [self evaluateRecipeWithId:recipe.ID];
        } else {
            [self gotRecipe:recipe];
        }
    }
}

- (void)processRecipe:(NSString*)recipeId {
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider processRecipeWithId:recipeId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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
    NITJSONAPI *jsonApi = [self buildEvaluationBodyWithPlugin:plugin action:action bundle:bundle];
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider onlinePulseEvaluationWithJsonApi:jsonApi] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider evaluateRecipeWithId:recipeId jsonApi:[self buildEvaluationBody]] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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
        [self.cooler markRecipeAsShownWithId:recipeId];
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
    
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider sendTrackingsWithJsonApi:jsonApi] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        
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

- (NSInteger)recipesCount {
    return [self.recipes count];
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

- (NSDictionary*)buildCoreObject {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NSMutableDictionary<NSString*, id> *core = [[NSMutableDictionary alloc] init];
    if (config.appId && config.profileId && config.installationId) {
        [core setObject:config.profileId forKey:@"profile_id"];
        [core setObject:config.installationId forKey:@"installation_id"];
        [core setObject:config.appId forKey:@"app_id"];
    }
    if (self.cooler) {
        [core setObject:[self buildCooldownBlockWithRecipeCooler:self.cooler] forKey:@"cooldown"];
    }
    return [NSDictionary dictionaryWithDictionary:core];
}

- (NSDictionary*)buildCooldownBlockWithRecipeCooler:(NITRecipeCooler*)recipeCooler {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSNumber *latestLog = [recipeCooler latestLog];
    if (latestLog) {
        [dict setObject:latestLog forKey:@"last_notified_at"];
    }
    NSDictionary<NSString*, NSNumber*> *log = [recipeCooler log];
    if (log) {
        [dict setObject:log forKey:@"recipes_notified_at"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
