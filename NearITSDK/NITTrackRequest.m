//
//  NITTrackRequest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTrackRequest.h"

@interface NITTrackRequest()

@property (nonatomic, strong) NSDate *nextRetry;
@property (nonatomic) NSInteger retry;

@end

@implementation NITTrackRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.retry = 0;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.request forKey:@"request"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.retry] forKey:@"retry"];
    [aCoder encodeObject:self.nextRetry forKey:@"nextRetry"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.request = [aDecoder decodeObjectForKey:@"request"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    NSNumber *retry = [aDecoder decodeObjectForKey:@"retry"];
    if (retry) {
        self.retry = [retry integerValue];
    } else {
        self.retry = 0;
    }
    self.nextRetry = [aDecoder decodeObjectForKey:@"nextRetry"];
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NITTrackRequest class]]) {
        NITTrackRequest *tr = (NITTrackRequest*)object;
        if (self.request && tr.request) {
            if ([tr.request.URL.absoluteString isEqualToString:self.request.URL.absoluteString] && [tr.request.HTTPBody isEqual:self.request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)increaseRetryWithTimeInterval:(NSTimeInterval)interval {
    self.retry += 1;
    self.nextRetry = [self.date dateByAddingTimeInterval:interval * pow(2, self.retry >= 1 ? self.retry -1 : 0)];
}

- (BOOL)availableForNextRetryWithDate:(NSDate *)date {
    if (self.nextRetry == nil) {
        return YES;
    }
    NSComparisonResult result = [date compare:self.nextRetry];
    if (result == NSOrderedDescending || result == NSOrderedSame) {
        return YES;
    }
    return NO;
}

@end
