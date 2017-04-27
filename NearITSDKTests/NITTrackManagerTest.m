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
#import "NITTestDateManager.h"

#define REQUEST_URL @"http//my.trackings"

@interface NITTrackManagerTest : NITTestCase

@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITTestDateManager *dateManager;

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
    
    self.dateManager = [[NITTestDateManager alloc] init];
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
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
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
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
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
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
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
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
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

- (void)testTrackManagerCachePrefilled {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = ReachableViaWiFi;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSDate *now = [NSDate date];
    NITTrackRequest *req1 = [[NITTrackRequest alloc] init];
    req1.request = [self simpleTrackRequest];
    req1.date = now;
    NITTrackRequest *req2 = [[NITTrackRequest alloc] init];
    req2.request = [self simpleTrackRequest];
    req2.date = now;
    NSArray<NITTrackRequest*> *requests = @[req1, req2];
    [self.cacheManager saveWithObject:requests forKey:@"Trackings"];
    
    [NSThread sleepForTimeInterval:0.5];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    XCTAssertTrue([trackManager.requests count] == 2);
    XCTAssertTrue([[[[[trackManager.requests firstObject] request] URL] absoluteString] isEqualToString:REQUEST_URL]);
    XCTAssertTrue([[[trackManager.requests firstObject] date] compare:now] == NSOrderedSame);
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerCache {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    [NSThread sleepForTimeInterval:1.0];
    
    NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:@"Trackings"];
    XCTAssertTrue([cachedRequests count] == 2);
    NITTrackRequest *trackRequest = [cachedRequests firstObject];
    XCTAssertTrue([trackRequest.request.URL.absoluteString isEqualToString:REQUEST_URL]);
    XCTAssertTrue([trackRequest.date compare:now] == NSOrderedSame);
}

- (void)testTrackRequestRetry {
    NSDate *now = [NSDate date];
    
    NITTrackRequest *request = [[NITTrackRequest alloc] init];
    request.request = [self simpleTrackRequest];
    request.date = now;
    [request increaseRetryWithTimeInterval:5.0]; // X1
    
    XCTAssertTrue([request availableForNextRetryWithDate:now] == NO);
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:7]] == YES);
    
    [request increaseRetryWithTimeInterval:5.0]; // X2
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:9]] == NO);
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:12]] == YES);
    
    [request increaseRetryWithTimeInterval:5.0]; // X3
    [request increaseRetryWithTimeInterval:5.0]; // X4
    [request increaseRetryWithTimeInterval:5.0]; // X5
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:78]] == NO);
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:82]] == YES);
}

- (void)testTrackManagerRetry {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = ReachableViaWWAN;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    
    NSArray<NITTrackRequest*> *availableRequests = [trackManager availableRequests];
    XCTAssertTrue([trackManager.requests count] == 1);
    XCTAssertTrue([availableRequests count] == 0);
    
    self.dateManager.testCurrentDate = [now dateByAddingTimeInterval:3];
    
    availableRequests = [trackManager availableRequests];
    XCTAssertTrue([availableRequests count] == 0);
    
    self.dateManager.testCurrentDate = [now dateByAddingTimeInterval:20];
    
    availableRequests = [trackManager availableRequests];
    XCTAssertTrue([availableRequests count] == 1);
    
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [trackManager sendTrackings];
    [queue waitUntilAllOperationsAreFinished];
    
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerApplicationDidBecomeActive {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    TestReachability *reachability = [[TestReachability alloc] init];
    reachability.testNetworkStatus = NotReachable;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:queue dateManager:self.dateManager];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [queue waitUntilAllOperationsAreFinished];
    XCTAssertTrue([trackManager.requests count] == 1);
    
    self.dateManager.testCurrentDate = [now dateByAddingTimeInterval:30];
    reachability.testNetworkStatus = ReachableViaWiFi;
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
    [queue waitUntilAllOperationsAreFinished];
    XCTAssertTrue([trackManager.requests count] == 0);
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
