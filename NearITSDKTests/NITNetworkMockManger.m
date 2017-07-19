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

@implementation NITNetworkResponse

- (instancetype)initWithJSONApi:(NITJSONAPI *)jsonApi {
    self = [super init];
    if (self) {
        self.jsonApi = jsonApi;
    }
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    self = [super init];
    if (self) {
        self.error = error;
    }
    return self;
}

@end

@interface NITNetworkMockManger()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NITMockBlock> *mockBlocks;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *mockCalls;
@property (nonatomic) BOOL isMockCalled;
@property (nonatomic) NSInteger numberOfCalls;
@property (assign) CFRunLoopRef clientRunLoop;

@end

@implementation NITNetworkMockManger

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mockBlocks = [[NSMutableDictionary alloc] init];
        self.mockCalls = [[NSMutableDictionary alloc] init];
        self.isMockCalled = NO;
        self.numberOfCalls = 0;
        self.clientRunLoop = CFRunLoopGetCurrent();
        self.responseTime = 0;
    }
    return self;
}

- (void)makeRequestWithURLRequest:(NSURLRequest *)request jsonApicompletionHandler:(void (^)(NITJSONAPI * _Nullable, NSError * _Nullable))completionHandler {
    dispatch_block_t block = ^{
        if (self.mockResponse) {
            NITNetworkResponse *response = self.mockResponse(request);
            if (response) {
                self.isMockCalled = true;
                self.numberOfCalls++;
                if (response.jsonApi) {
                    completionHandler(response.jsonApi, nil);
                } else if(response.error) {
                    completionHandler(nil, response.error);
                }
            }
        } else if (self.mock) {
            NITJSONAPI *json = self.mock(request);
            if (json) {
                self.isMockCalled = YES;
                self.numberOfCalls++;
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
                    [self.mockCalls setObject:[NSNumber numberWithBool:YES] forKey:key];
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
    };
    if (self.responseTime != 0) {
        [self executeOnClientRunLoopAfterDelay:self.responseTime block:block];
    } else {
        block();
    }
}

- (void)setMock:(NITMockBlock)mock forKey:(NSString *)key {
    [self.mockBlocks setObject:mock forKey:key];
}

- (void)removeMockForKey:(NSString *)key {
    [self.mockBlocks removeObjectForKey:key];
}

- (BOOL)isMockCalledForKey:(NSString *)key {
    NSNumber *called = [self.mockCalls objectForKey:key];
    if (called && [called boolValue]) {
        return YES;
    }
    return NO;
}

- (void)executeOnClientRunLoopAfterDelay:(NSTimeInterval)delayInSeconds block:(dispatch_block_t)block
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFRunLoopPerformBlock(self.clientRunLoop, kCFRunLoopDefaultMode, block);
        CFRunLoopWakeUp(self.clientRunLoop);
    });
}

@end
