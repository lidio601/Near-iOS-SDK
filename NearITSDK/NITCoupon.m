//
//  NITCoupon.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCoupon.h"
#import "NITConstants.h"
#import "NITClaim.h"

#define NameKey @"name"
#define DescriptionKey @"description"
#define ValueKey @"value"
#define ExpiresAtKey @"expiresAt"
#define RedeemableFromKey @"redeemableFrom"
#define ClaimsKey @"claims"
#define IconKey @"icon"

@implementation NITCoupon

- (NSDictionary *)attributesMap {
    return @{ @"description" : @"couponDescription",
              @"expires_at" : @"expiresAt",
              @"redeemable_from" : @"redeemableFrom" };
}

- (NSDate *)expires {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    if (self.expiresAt) {
        return [dateFormatter dateFromString:self.expiresAt];
    }
    return nil;
}

- (NSDate *)redeemable {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ISO8601DateFormatMilliseconds;
    if (self.redeemableFrom) {
        return [dateFormatter dateFromString:self.redeemableFrom];
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:NameKey];
        self.couponDescription = [aDecoder decodeObjectForKey:DescriptionKey];
        self.value = [aDecoder decodeObjectForKey:ValueKey];
        self.expiresAt = [aDecoder decodeObjectForKey:ExpiresAtKey];
        self.redeemableFrom = [aDecoder decodeObjectForKey:RedeemableFromKey];
        self.claims = [aDecoder decodeObjectForKey:ClaimsKey];
        self.icon = [aDecoder decodeObjectForKey:IconKey];
        
        for(NITClaim *claim in self.claims) {
            claim.coupon = self;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:NameKey];
    [aCoder encodeObject:self.couponDescription forKey:DescriptionKey];
    [aCoder encodeObject:self.value forKey:ValueKey];
    [aCoder encodeObject:self.expiresAt forKey:ExpiresAtKey];
    [aCoder encodeObject:self.redeemableFrom forKey:RedeemableFromKey];
    [aCoder encodeObject:self.claims forKey:ClaimsKey];
    [aCoder encodeObject:self.icon forKey:IconKey];
}

@end
