//
//  NITAudio.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITAudio.h"

#define AudioKey @"audio"

@implementation NITAudio

- (NSURL *)url {
    NSString* stringUrl = [self.audio objectForKey:@"url"];
    return [NSURL URLWithString:stringUrl];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.audio = [aDecoder decodeObjectForKey:AudioKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.audio forKey:AudioKey];
}

@end
