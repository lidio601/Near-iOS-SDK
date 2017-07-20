//
//  NITUserProfile.h
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

@class NITConfiguration;
@class NITNetworkManager;
@class NITInstallation;
@class NITUserDataBackoff;
@class NITUserProfile;

@protocol NITUserProfileDelegate <NSObject>

- (void)profileUserDataBackoffDidComplete:(NITUserProfile* _Nonnull)profile;

@end

@interface NITUserProfile : NSObject

@property (nonatomic, weak) id<NITUserProfileDelegate> _Nullable delegate;
@property (nonatomic, strong) NITInstallation * _Nonnull installation;

- (instancetype _Nonnull )initWithConfiguration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager installation:(NITInstallation* _Nonnull)installation userDataBackoff:(NITUserDataBackoff* _Nonnull)userDataBackoff;

- (void)createNewProfileWithCompletionHandler:(void (^ _Nullable)(NSString* _Nullable profileId, NSError* _Nullable error))handler;
- (void)setUserDataWithKey:(NSString* _Nonnull)key value:(NSString* _Nullable)value completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)setBatchUserDataWithDictionary:(NSDictionary<NSString*, id>* _Nonnull)valuesDictiornary completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)setDeferredUserDataWithKey:(NSString* _Nonnull)key value:(NSString* _Nullable)value;
- (void)resetProfile;
- (void)setProfileId:(NSString*_Nonnull)profileId;
- (void)shouldSendUserData;

@end
