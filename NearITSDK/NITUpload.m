//
//  NITUpload.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITUpload.h"

@implementation NITUpload

- (NSURL *)url {
    NSString* stringUrl = [self.upload objectForKey:@"url"];
    return [NSURL URLWithString:stringUrl];
}

@end
