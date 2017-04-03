//
//  NITRecipeCooler.h
//  NearITSDK
//
//  Created by Francesco Leoni on 03/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITRecipe;

@interface NITRecipeCooler : NSObject

- (void)markRecipeAsShownWithId:(NSString* _Nonnull)recipeId;
- (NSArray<NITRecipe*>* _Nonnull)filterRecipeWithRecipes:(NSArray<NITRecipe*>* _Nonnull)recipes;

@end
