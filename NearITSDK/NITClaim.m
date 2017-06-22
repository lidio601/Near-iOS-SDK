//
//  NITClaim.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITClaim.h"
#import "NITConstants.h"

#define SerialNumberKey @"serialNumber"
#define ClaimedAt @"claimedAt"
#define RedeemedAt @"redeemedAt"
#define RecipeId @"recipeId"

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.serialNumber = [aDecoder decodeObjectForKey:SerialNumberKey];
        self.claimedAt = [aDecoder decodeObjectForKey:ClaimedAt];
        self.redeemedAt = [aDecoder decodeObjectForKey:RedeemedAt];
        self.recipeId = [aDecoder decodeObjectForKey:RecipeId];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.serialNumber forKey:SerialNumberKey];
    [aCoder encodeObject:self.claimedAt forKey:ClaimedAt];
    [aCoder encodeObject:self.redeemedAt forKey:RedeemedAt];
    [aCoder encodeObject:self.recipeId forKey:RecipeId];
}

@end
