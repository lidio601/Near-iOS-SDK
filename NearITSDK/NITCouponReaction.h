//
//  NITCouponReaction.h
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITReaction.h"
#import "NITNetworkManaging.h"

@class NITCoupon;
@class NITConfiguration;
@class NITCacheManager;

@interface NITCouponReaction : NITReaction

- (instancetype _Nonnull)initWithCacheManager:(NITCacheManager * _Nonnull)cacheManager configuration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager;
- (void)couponsWithCompletionHandler:(void (^ _Nullable)(NSArray<NITCoupon*>* _Nullable, NSError* _Nullable))handler;

@end
