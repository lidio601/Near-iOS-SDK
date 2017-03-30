//
//  NITClaim.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITClaim.h"
#import "NITConstants.h"

@implementation NITClaim

- (NSDictionary *)attributesMap {
    return @{ @"serial_number" : @"serialNumber",
              @"claimed_at" : @"claimedAt",
              @"redeemed_at" : @"redeemedAt" };
}

- (NSDate *)claimed {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    return [dateFormatter dateFromString:self.claimedAt];
}

- (NSDate *)redeemed {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    if (self.redeemed) {
        return [dateFormatter dateFromString:(NSString * _Nonnull)self.redeemed];
    }
    return nil;
}

@end
