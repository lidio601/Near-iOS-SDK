//
//  NITContent.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITContent.h"

#define ContentKey @"content"

@implementation NITContent

- (NSDictionary *)attributesMap {
    return @{ @"image_ids" : @"imagesIds" };
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.content = [aDecoder decodeObjectForKey:ContentKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.content forKey:ContentKey];
}

@end
