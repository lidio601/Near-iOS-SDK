//
//  NITCooldownValidator.h
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITValidating.h"

@class NITRecipeHistory;
@class NITDateManager;

#define kCooldwonNeverRepeat @-1

@interface NITCooldownValidator : NSObject<NITValidating>

- (instancetype _Nonnull)initWithRecipeHistory:(NITRecipeHistory* _Nonnull)recipeHistory dateManager:(NITDateManager* _Nonnull)dateManager;

@end
