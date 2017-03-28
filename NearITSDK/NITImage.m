//
//  NITImage.m
//  NearITSDK
//
//  Created by Francesco Leoni on 27/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITImage.h"

#define ImageKey @"image"

@implementation NITImage

- (NSURL *)smallSizeURL {
    NSDictionary *dict = [self.image objectForKey:@"square_300"];
    NSString *urlString = [dict objectForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.image = [aDecoder decodeObjectForKey:ImageKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:ImageKey];
}

@end
