//
//  NITFeedbackReaction.h
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITReaction.h"
#import "NITNetworkManaging.h"

@class NITFeedbackEvent;
@class NITConfiguration;

extern NSString* _Nonnull const NITFeedbackPluginName;

@interface NITFeedbackReaction : NITReaction

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager * _Nonnull)cacheManager configuration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager;

- (void)sendEventWithFeedbackEvent:(NITFeedbackEvent* _Nonnull)event completionHandler:(void (^_Nullable)(NSError* _Nullable error))handler;

@end
