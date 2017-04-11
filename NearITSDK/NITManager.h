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
@class NITEvent;
@class NITCoupon;

@protocol NITManaging <NSObject>

- (void)recipesManager:(NITRecipesManager* _Nonnull)recipesManager gotRecipe:(NITRecipe* _Nonnull)recipe;

@end

@protocol NITManagerDelegate <NSObject>

- (void)manager:(NITManager* _Nonnull)manager eventWithContent:(id _Nonnull)content recipe:(NITRecipe* _Nonnull)recipe;
- (void)manager:(NITManager* _Nonnull)manager eventFailureWithError:(NSError* _Nonnull)error recipe:(NITRecipe* _Nonnull)recipe;

@end

@interface NITManager : NSObject

@property (nonatomic, weak) id<NITManagerDelegate> _Nullable delegate;

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey;

- (void)start;
- (void)stop;
- (void)refreshConfigWithCompletionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler;
- (void)setDeviceToken:(NSString* _Nonnull)deviceToken;
- (void)processRecipeWithUserInfo:(NSDictionary<NSString*, id> * _Nullable)userInfo;
- (void)sendTrackingWithRecipeId:(NSString * _Nonnull)recipeId event:(NSString* _Nonnull)event;
- (void)setUserDataWithKey:(NSString* _Nonnull)key value:(NSString* _Nonnull)value completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)setBatchUserDataWithDictionary:(NSDictionary<NSString*, id>* _Nonnull)valuesDictiornary completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)sendEventWithEvent:(NITEvent* _Nonnull)event completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)couponsWithCompletionHandler:(void (^ _Nullable)(NSArray<NITCoupon*>* _Nullable, NSError* _Nullable))handler;
- (NSArray<NITRecipe*>* _Nonnull)recipes;
- (void)processRecipeWithId:(NSString* _Nonnull)recipeId;
- (void)resetProfile;
- (NSString* _Nullable)profileId;
- (void)createNewProfileWithCompletionHandler:(void (^ _Nullable)(NSString* _Nullable profileId, NSError* _Nullable error))handler;
- (void)setProfileId:(NSString * _Nonnull)profileId;

@end
