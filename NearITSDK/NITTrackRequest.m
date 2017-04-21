//
//  NITTrackRequest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTrackRequest.h"

@implementation NITTrackRequest

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.request forKey:@"request"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.request = [aDecoder decodeObjectForKey:@"request"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
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

@end
