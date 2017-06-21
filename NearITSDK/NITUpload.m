//
//  NITUpload.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITUpload.h"

#define UploadKey @"upload"

@implementation NITUpload

- (NSURL *)url {
    NSString* stringUrl = [self.upload objectForKey:@"url"];
    return [NSURL URLWithString:stringUrl];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.upload = [aDecoder decodeObjectForKey:UploadKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.upload forKey:UploadKey];
}

@end
