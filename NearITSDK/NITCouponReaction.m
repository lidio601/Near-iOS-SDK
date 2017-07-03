//
//  NITCouponReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCouponReaction.h"
#import "NITRecipe.h"
#import "NITResource.h"
#import "NITCoupon.h"
#import "NITConstants.h"
#import "NITJSONAPI.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITConfiguration.h"
#import "NITClaim.h"
#import "NITImage.h"
#import "NITLog.h"

#define LOGTAG @"CouponReaction"

@interface NITCouponReaction()

@property (nonatomic, strong) NITConfiguration *configuration;

@end

@implementation NITCouponReaction

- (instancetype)initWithCacheManager:(NITCacheManager *)cacheManager configuration:(NITConfiguration*)configuration networkManager:(id<NITNetworkManaging>)networkManager {
    self = [super initWithCacheManager:cacheManager networkManager:networkManager];
    if (self) {
        self.configuration = configuration;
    }
    return self;
}

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id _Nullable, NSError * _Nullable))handler {
    if ([recipe.reactionBundle isKindOfClass:[NITCoupon class]]) {
        if (handler) {
            NITCoupon *coupon = (NITCoupon*)recipe.reactionBundle;
            if (coupon.hasContentToInclude) {
                NITLogD(LOGTAG, @"Coupon has content to include");
                [self requestSingleReactionWithBundleId:recipe.reactionBundle.ID completionHandler:^(id content, NSError *error) {
                    if (error) {
                        handler(nil, error);
                    } else {
                        NITCoupon *coupon = (NITCoupon*)content;
                        handler(coupon, nil);
                    }
                }];
            } else {
                NITLogD(LOGTAG, @"Coupon from reactionBundle");
                handler(coupon, nil);
            }
        }
    } else {
        if (handler) {
            NITLogE(LOGTAG, @"No coupon found in reactionBundle: recipeId -> %@", recipe.ID);
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:103 userInfo:@{NSLocalizedDescriptionKey:@"Invalid recipe"}];
            handler(nil, anError);
        }
    }
}

- (void)contentWithReactionBundleId:(NSString *)reactionBundleId recipeId:(NSString* _Nonnull)recipeId completionHandler:(void (^)(id _Nullable, NSError * _Nullable))handler {
    if (handler) {
        [self requestSingleReactionWithBundleId:reactionBundleId completionHandler:^(id content, NSError *error) {
            handler(content, error);
        }];
    }
}

- (id)contentWithJsonReactionBundle:(NSDictionary<NSString *,id> *)jsonReactionBundle recipeId:(NSString * _Nonnull)recipeId{
    NITJSONAPI *json = [[NITJSONAPI alloc] initWithDictionary:jsonReactionBundle];
    [self registerJsonApiClasses:json];
    NSArray<NITCoupon*> *coupons = [json parseToArrayOfObjects];
    if ([coupons count] > 0) {
        NITCoupon *coupon = [coupons objectAtIndex:0];
        if (coupon.claims != nil && [coupon.claims count] >= 1) {
            return coupon;
        }
    }
    return nil;
}

- (void)requestSingleReactionWithBundleId:(NSString*)bundleId completionHandler:(void (^)(id content, NSError *error))handler {
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] couponWithProfileId:self.configuration.profileId bundleId:bundleId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if(error) {
            if (handler) {
                NITLogE(LOGTAG, @"Coupon request failure");
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:105 userInfo:@{NSLocalizedDescriptionKey:@"Invalid coupon data", NSUnderlyingErrorKey: error}];
                handler(nil, anError);
            }
        } else {
            [self registerJsonApiClasses:json];
            NSArray<NITCoupon*> *coupons = [json parseToArrayOfObjects];
            if ([coupons count] > 0) {
                NITCoupon *coupon = [coupons objectAtIndex:0];
                if (handler) {
                    handler(coupon, nil);
                }
            } else {
                if (handler) {
                    NITLogW(LOGTAG, @"Empty coupon data");
                    NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:106 userInfo:@{NSLocalizedDescriptionKey:@"Empty coupon data", NSUnderlyingErrorKey: error}];
                    handler(nil, anError);
                }
            }
        }
    }];
}

- (void)couponsWithCompletionHandler:(void (^)(NSArray<NITCoupon *> * _Nullable, NSError * _Nullable))handler {
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] couponsWithProfileId:self.configuration.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if(error) {
            if (handler) {
                NITLogE(LOGTAG, @"Coupons request failure");
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:104 userInfo:@{NSLocalizedDescriptionKey:@"Invalid coupons data", NSUnderlyingErrorKey: error}];
                handler(nil, anError);
            }
        } else {
            [self registerJsonApiClasses:json];
            NSArray<NITCoupon*> *coupons = [json parseToArrayOfObjects];
            if (handler) {
                NITLogD(LOGTAG, @"Coupons request success, number of coupons %d", [coupons count]);
                handler(coupons, nil);
            }
        }
    }];
}

- (void)registerJsonApiClasses:(NITJSONAPI*)json {
    [json registerClass:[NITCoupon class] forType:@"coupons"];
    [json registerClass:[NITClaim class] forType:@"claims"];
    [json registerClass:[NITImage class] forType:@"images"];
}

@end
