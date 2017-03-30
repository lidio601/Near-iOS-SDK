//
//  NITCoupon.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCoupon.h"

@implementation NITCoupon

- (NSDictionary *)attributesMap {
    return @{ @"description" : @"couponDescription",
              @"expires_at" : @"expiresAt" };
}

@end
