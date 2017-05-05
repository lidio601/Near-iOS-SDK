//
//  NITCoupon.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCoupon.h"
#import "NITConstants.h"

@implementation NITCoupon

- (NSDictionary *)attributesMap {
    return @{ @"description" : @"couponDescription",
              @"expires_at" : @"expiresAt" };
}

- (NSDate *)expires {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    if (self.expiresAt) {
        return [dateFormatter dateFromString:self.expiresAt];
    }
    return nil;
}

@end
