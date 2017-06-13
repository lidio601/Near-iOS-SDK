//
//  NITRecipeValidationFilter.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipeValidationFilter.h"

@interface NITRecipeValidationFilter()

@property (nonatomic, strong) NSArray<id<NITValidating>> *validators;

@end

@implementation NITRecipeValidationFilter

- (instancetype)initWithValidators:(NSArray<id<NITValidating>> *)validators {
    self = [super init];
    if (self) {
        self.validators = validators;
    }
    return self;
}

- (NSArray<NITRecipe *> *)filterRecipes:(NSArray<NITRecipe *> *)recipes {
    NSMutableArray *filteredRecipes = [[NSMutableArray alloc] init];
    
    for(NITRecipe *recipe in recipes) {
        if ([self isValidWithRecipe:recipe]) {
            [filteredRecipes addObject:recipe];
        }
    }
    
    return [NSArray arrayWithArray:filteredRecipes];
}

- (BOOL)isValidWithRecipe:(NITRecipe*)recipe {
    BOOL valid = YES;
    for(id validator in self.validators) {
        valid &= [validator isValidWithRecipe:recipe];
    }
    return valid;
}

@end
