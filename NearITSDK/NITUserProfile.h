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

@interface NITUserProfile : NSObject

@property (nonatomic, strong) NITInstallation * _Nonnull installation;

- (instancetype _Nonnull )initWithConfiguration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager;

- (void)createNewProfileWithCompletionHandler:(void (^ _Nullable)(NSString* _Nullable profileId, NSError* _Nullable error))handler;
- (void)setUserDataWithKey:(NSString* _Nonnull)key value:(NSString* _Nonnull)value completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)setBatchUserDataWithDictionary:(NSDictionary<NSString*, id>* _Nonnull)valuesDictiornary completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;
- (void)resetProfile;
- (void)setProfileId:(NSString*)profileId;

@end
