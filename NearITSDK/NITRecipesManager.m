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

- (void)gotRecipe:(NITRecipe*)recipe {
    if ([self.manager respondsToSelector:@selector(recipesManager:gotRecipe:)]) {
        [self.manager recipesManager:self gotRecipe:recipe];
    }
}

@end
