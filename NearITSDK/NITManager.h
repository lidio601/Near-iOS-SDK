//
//  NITManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITRecipesManager;
@class NITRecipe;
@class NITManager;

@protocol NITManaging <NSObject>

- (void)recipesManager:(NITRecipesManager* _Nonnull)recipesManager gotRecipe:(NITRecipe* _Nonnull)recipe;

@end

@protocol NITManagerDelegate <NSObject>

- (void)manager:(NITManager* _Nonnull)manager eventWithContent:(id _Nonnull)content;
- (void)manager:(NITManager* _Nonnull)manager eventFailureWithError:(NSError* _Nonnull)error;

@end

@interface NITManager : NSObject

@property (nonatomic, weak) id<NITManagerDelegate> _Nullable delegate;

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey;

- (void)refreshConfig;
- (void)setDeviceToken:(NSString*)deviceToken;

@end
