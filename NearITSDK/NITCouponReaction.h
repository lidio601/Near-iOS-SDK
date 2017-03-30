//
//  NITCouponReaction.h
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITReaction.h"

@class NITCoupon;
@class NITConfiguration;

@interface NITCouponReaction : NITReaction

- (instancetype _Nonnull)initWithConfiguration:(NITConfiguration* _Nonnull)configuration;
- (void)couponsWithCompletionHandler:(void (^ _Nullable)(NSArray<NITCoupon*>* _Nullable, NSError* _Nullable))handler;

@end
