//
//  NITCustomJSON.m
//  NearITSDK
//
//  Created by Francesco Leoni on 31/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCustomJSON.h"

#define ContentKey @"content"

@implementation NITCustomJSON

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.content = [aDecoder decodeObjectForKey:ContentKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:ContentKey];
}

@end
