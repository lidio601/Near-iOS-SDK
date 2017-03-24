//
//  NITNetworkMock.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNetworkMock.h"

static NITNetworkMock *sharedMock;

@interface NITNetworkMockTest : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NITNetworkMockTestBlock test;

@end

@implementation NITNetworkMockTest

@end

@interface NITNetworkMock()

@property (nonatomic, strong) NSMutableArray<NITNetworkMockTest*> *tests;

@end

@implementation NITNetworkMock

+ (NITNetworkMock *)sharedInstance {
    if (sharedMock == nil) {
        sharedMock = [NITNetworkMock new];
    }
    return sharedMock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tests = [[NSMutableArray alloc] init];
        self.enabled = NO;
    }
    return self;
}

- (void)clearTests {
    [self.tests removeAllObjects];
}

- (void)registerData:(NSData*)data withTest:(NITNetworkMockTestBlock)test {
    NITNetworkMockTest *mockTest = [[NITNetworkMockTest alloc] init];
    mockTest.data = data;
    mockTest.test = test;
    [self.tests addObject:mockTest];
}

- (NSData *)dataWithRequest:(NSURLRequest *)request {
    if(!self.enabled) {
        return nil;
    }
    for(NITNetworkMockTest *test in self.tests) {
        if (test.test(request)) {
            return test.data;
        }
    }
    return nil;
}

@end
