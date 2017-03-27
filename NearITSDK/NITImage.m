//
//  NITImage.m
//  NearITSDK
//
//  Created by Francesco Leoni on 27/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITImage.h"

@implementation NITImage

- (NSURL *)smallSizeURL {
    NSDictionary *dict = [self.image objectForKey:@"square_300"];
    NSString *urlString = [dict objectForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }
    return nil;
}

@end
