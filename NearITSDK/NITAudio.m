//
//  NITAudio.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITAudio.h"

@implementation NITAudio

- (NSURL *)url {
    NSString* stringUrl = [self.audio objectForKey:@"url"];
    return [NSURL URLWithString:stringUrl];
}

@end
