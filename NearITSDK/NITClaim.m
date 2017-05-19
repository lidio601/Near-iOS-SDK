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
              @"redeemed_at" : @"redeemedAt",
              @"recipe_id" : @"recipeId" };
}

- (NSDate *)claimed {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    return [dateFormatter dateFromString:self.claimedAt];
}

- (NSDate *)redeemed {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    if (self.redeemedAt) {
        return [dateFormatter dateFromString:(NSString * _Nonnull)self.redeemedAt];
    }
    return nil;
}

@end
