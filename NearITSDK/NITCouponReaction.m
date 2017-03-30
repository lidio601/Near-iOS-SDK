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

@implementation NITCouponReaction

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

@end
