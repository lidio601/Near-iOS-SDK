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

@property (nonatomic, strong) NITCacheManager *cacheManager;

@end

@implementation NITTrackManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
    [self.cacheManager removeAllItemsWithCompletionHandler:^{
        dispatch_semaphore_signal(semaphore2);
    }];
    dispatch_semaphore_wait(semaphore2, dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC));
    [super tearDown];
}

- (void)testTrackManagerOnline {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = ReachableViaWWAN;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
    [queue waitUntilAllOperationsAreFinished];
    
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerOnlineTriple {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        [NSThread sleepForTimeInterval:0.5]; // Slow network simulation
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = ReachableViaWWAN;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
    [queue waitUntilAllOperationsAreFinished];
    
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerOffline {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
    [queue waitUntilAllOperationsAreFinished];
    
    [NSThread sleepForTimeInterval:0.5];
    
    XCTAssertTrue([trackManager.requests count] == 1);
    NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:@"Trackings"];
    XCTAssertTrue([cachedRequests count] == 1);
    NITTrackRequest *trackRequest = [cachedRequests firstObject];
    XCTAssertTrue([trackRequest.request.URL.absoluteString isEqualToString:REQUEST_URL]);
}

- (void)testTrackManagerNetworkSwitch {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    reachability.testNetworkStatus = ReachableViaWWAN;
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    [NSThread sleepForTimeInterval:0.5];
    
    XCTAssertTrue([trackManager.requests count] == 0);
    NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:@"Trackings"];
    XCTAssertTrue([cachedRequests count] == 0);
}

- (void)testTrackManagerCache {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    [NSThread sleepForTimeInterval:2.0];
    
    NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:@"Trackings"];
    XCTAssertTrue([cachedRequests count] == 2);
}

// MARK: - Utility

- (NSURLRequest*)simpleTrackRequest {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:REQUEST_URL]];
    request.HTTPMethod = @"post";
    request.HTTPBody = [@"{\"track\":\"test\"}" dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (NSURLRequest*)simpleTrackRequestWithBody:(NSString*)body {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:REQUEST_URL]];
    request.HTTPMethod = @"post";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}


@end
