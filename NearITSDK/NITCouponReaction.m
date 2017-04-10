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
            handler((NITCoupon*)recipe.reactionBundle, nil);
        }
    } else {
        if (handler) {
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:103 userInfo:@{NSLocalizedDescriptionKey:@"Invalid recipe"}];
            handler(nil, anError);
        }
    }
}

- (void)couponsWithCompletionHandler:(void (^)(NSArray<NITCoupon *> * _Nullable, NSError * _Nullable))handler {
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] couponsWithProfileId:self.configuration.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if(error) {
            if (handler) {
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:104 userInfo:@{NSLocalizedDescriptionKey:@"Invalid coupons data", NSUnderlyingErrorKey: error}];
                handler(nil, anError);
            }
        } else {
            [json registerClass:[NITCoupon class] forType:@"coupons"];
            [json registerClass:[NITClaim class] forType:@"claims"];
            [json registerClass:[NITImage class] forType:@"images"];
            NSArray<NITCoupon*> *coupons = [json parseToArrayOfObjects];
            if (handler) {
                handler(coupons, nil);
            }
        }
    }];
}

@end
