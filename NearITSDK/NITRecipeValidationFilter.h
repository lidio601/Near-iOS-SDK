//
//  NITRecipeValidationFilter.h
//  NearITSDK
//
//  Created by Francesco Leoni on 13/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITValidating.h"

@class NITRecipe;

@interface NITRecipeValidationFilter : NSObject

- (instancetype _Nonnull)initWithValidators:(NSArray<id<NITValidating>>* _Nonnull)validators;

- (NSArray<NITRecipe*>* _Nonnull)filterRecipes:(NSArray<NITRecipe*>* _Nonnull)recipes;

@end
