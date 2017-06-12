//
//  NITValidating.h
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

@class NITRecipe;

@protocol NITValidating <NSObject>

- (BOOL)isValidWithRecipe:(NITRecipe*)recipe;

@end
