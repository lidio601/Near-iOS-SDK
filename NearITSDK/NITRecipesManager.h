//
//  NITRecipesManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 20/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITJSONAPI;

@protocol NITRecipesManaging <NSObject>

- (void)setRecipesWithJsonApi:(NITJSONAPI* _Nullable)json;
- (void)gotPulseWithPulsePlugin:(NSString* _Nonnull)pulsePlugin pulseAction:(NSString* _Nonnull)pulseAction pulseBundle:(NSString* _Nullable)pulseBundle;

@end

@interface NITRecipesManager : NSObject<NITRecipesManaging>

- (void)refreshConfigWithCompletionHandler:(void (^_Nonnull)(NSError * _Nullable error))completionHandler;

@end
