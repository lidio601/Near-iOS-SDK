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

@interface NITNetworkMockManger()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NITMockBlock> *mockBlocks;

@end

@implementation NITNetworkMockManger

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mockBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)makeRequestWithURLRequest:(NSURLRequest *)request jsonApicompletionHandler:(void (^)(NITJSONAPI * _Nullable, NSError * _Nullable))completionHandler {
    if (self.mock) {
        NITJSONAPI *json = self.mock(request);
        if (json) {
            completionHandler(json, nil);
        } else {
            completionHandler(nil, [NSError errorWithDomain:NITNetworkMockErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"No json api given"}]);
        }
    } else if([self.mockBlocks count] > 0) {
        NITJSONAPI *json = nil;
        for (NSString *key in self.mockBlocks) {
            NITMockBlock block = [self.mockBlocks objectForKey:key];
            json = block(request);
            if (json) {
                break;
            }
        }
        if (json) {
            completionHandler(json, nil);
        } else {
            completionHandler(nil, [NSError errorWithDomain:NITNetworkMockErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"No json api given"}]);
        }
    } else {
        completionHandler(nil, [NSError errorWithDomain:NITNetworkMockErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"Invalid mock block"}]);
    }
}

- (void)setMock:(NITMockBlock)mock forKey:(NSString *)key {
    [self.mockBlocks setObject:mock forKey:key];
}

- (void)removeMockForKey:(NSString *)key {
    [self.mockBlocks removeObjectForKey:key];
}

@end
