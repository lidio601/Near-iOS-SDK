//
//  NITNetworkMockManger.m
//  NearITSDK
//
//  Created by Francesco Leoni on 10/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNetworkMockManger.h"
#import "NITJSONAPI.h"

NSErrorDomain const NITNetworkMockErrorDomain = @"com.nearit.networkmock";

@implementation NITNetworkMockManger

- (void)makeRequestWithURLRequest:(NSURLRequest *)request jsonApicompletionHandler:(void (^)(NITJSONAPI * _Nullable, NSError * _Nullable))completionHandler {
    if (self.mock) {
        NITJSONAPI *json = self.mock(request);
        completionHandler(json, nil);
    } else {
        completionHandler(nil, [NSError errorWithDomain:NITNetworkMockErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"Invalid mock block"}]);
    }
}

@end
