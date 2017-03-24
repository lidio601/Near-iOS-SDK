//
//  NITReaction.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITManager;
@class NITRecipe;

@interface NITReaction : NSObject

- (NSString* _Nonnull)pluginName;
- (void)contentWithRecipe:(NITRecipe* _Nonnull)recipe completionHandler:(void (^_Nullable)(id _Nonnull content, NSError * _Nullable error))handler;

@end
