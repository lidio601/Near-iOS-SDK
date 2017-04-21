//
//  NITTrackManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITTrackManager+Tests.h"
#import "NITTrackRequest.h"
#import "NITCacheManager.h"
#import "TestReachability.h"

#define REQUEST_URL @"http//my.trackings"

@interface NITTrackManagerTest : NITTestCase

@end

@implementation NITTrackManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrackManagerOnline {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = ReachableViaWWAN;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:REQUEST_URL]];
    request.HTTPMethod = @"post";
    request.HTTPBody = [@"{\"track\":\"test\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [trackManager addTrackWithRequest:request];
    
    [NSThread sleepForTimeInterval:0.5];
    
    XCTAssertTrue([trackManager.requests count] == 0);
    
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore2);
    }];
    dispatch_semaphore_wait(semaphore2, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
}

- (void)testTrackManagerOffline {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:REQUEST_URL]];
    request.HTTPMethod = @"post";
    request.HTTPBody = [@"{\"track\":\"test\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [trackManager addTrackWithRequest:request];
    
    [NSThread sleepForTimeInterval:0.5];
    
    XCTAssertTrue([trackManager.requests count] == 1);
    NSArray<NITTrackRequest*> *cachedRequests = [cacheManager loadArrayForKey:@"Trackings"];
    XCTAssertTrue([cachedRequests count] == 1);
    NITTrackRequest *trackRequest = [cachedRequests firstObject];
    XCTAssertTrue([trackRequest.request.URL.absoluteString isEqualToString:REQUEST_URL]);
    
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    [cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore2);
    }];
    dispatch_semaphore_wait(semaphore2, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
}

@end
