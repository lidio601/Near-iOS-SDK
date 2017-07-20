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
#import "Reachability.h"
#import "NITTestDateManager.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define REQUEST_URL @"http//my.trackings"

#define EXP_ONE @"one"
#define EXP_TWO @"two"
#define EXP_THREE @"three"

@interface NITTrackManagerTest : NITTestCase<NITTrackManagerDelegate>

@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITTestDateManager *dateManager;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) id<NITTrackManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary<NSString*, XCTestExpectation*> *expectations;
@property (nonatomic) NSInteger caseNumber;

@end

@implementation NITTrackManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cacheManager = mock([NITCacheManager class]);
    self.reachability = mock([Reachability class]);
    self.dateManager = [[NITTestDateManager alloc] init];
    self.expectations = [[NSMutableDictionary alloc] init];
    self.caseNumber = 0;
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
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    trackManager.delegate = self;
    
    [self.expectations setObject:[self expectationWithDescription:EXP_ONE] forKey:EXP_ONE];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testTrackManagerOnlineTriple {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.responseTime = 1.5;
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    trackManager.delegate = self;
    
    [self.expectations setObject:[self expectationWithDescription:EXP_ONE] forKey:EXP_ONE];
    [self.expectations setObject:[self expectationWithDescription:EXP_TWO] forKey:EXP_TWO];
    [self.expectations setObject:[self expectationWithDescription:EXP_THREE] forKey:EXP_THREE];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
    [self executeOnClientRunLoopAfterDelay:0.5 block:^{
        XCTAssertTrue(trackManager.requests.count == 1);
        [trackManager addTrackWithRequest:[self simpleTrackRequest]];
        
        [self executeOnClientRunLoopAfterDelay:0.5 block:^{
            XCTAssertTrue(trackManager.requests.count == 2);
            [trackManager addTrackWithRequest:[self simpleTrackRequest]];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
}

- (void)testTrackManagerOffline {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [verifyCount(self.cacheManager, times(1)) saveWithObject:anything() forKey:@"Trackings"];
    
    XCTAssertTrue([trackManager.requests count] == 1);
}

- (void)testTrackManagerNetworkSwitch {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    trackManager.delegate = self;
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [verifyCount(self.cacheManager, times(2)) saveWithObject:anything() forKey:@"Trackings"];
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    
    [self.expectations setObject:[self expectationWithDescription:EXP_ONE] forKey:EXP_ONE];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [verifyCount(self.cacheManager, atLeastOnce()) saveWithObject:anything() forKey:@"Trackings"];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testTrackManagerCachePrefilled {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    
    NSDate *now = [NSDate date];
    NITTrackRequest *req1 = [[NITTrackRequest alloc] init];
    req1.request = [self simpleTrackRequest];
    req1.date = now;
    NITTrackRequest *req2 = [[NITTrackRequest alloc] init];
    req2.request = [self simpleTrackRequest];
    req2.date = now;
    NSArray<NITTrackRequest*> *requests = @[req1, req2];
    [given([self.cacheManager loadArrayForKey:@"Trackings"]) willReturn:requests];
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    trackManager.delegate = self;
    XCTAssertTrue([trackManager.requests count] == 2);
    XCTAssertTrue([[[[[trackManager.requests firstObject] request] URL] absoluteString] isEqualToString:REQUEST_URL]);
    XCTAssertTrue([[[trackManager.requests firstObject] date] compare:now] == NSOrderedSame);
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    [verifyCount(self.cacheManager, atLeastOnce()) saveWithObject:anything() forKey:@"Trackings"];
    
    XCTAssertTrue([trackManager.requests count] == 0);
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
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:18]] == YES);
    
    [request increaseRetryWithTimeInterval:5.0]; // X3
    [request increaseRetryWithTimeInterval:5.0]; // X4
    [request increaseRetryWithTimeInterval:5.0]; // X5
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:132]] == NO);
    XCTAssertTrue([request availableForNextRetryWithDate:[now dateByAddingTimeInterval:160]] == YES);
}

- (void)testTrackManagerRetry {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    trackManager.delegate = self;
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    
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
    
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerMaxRetry {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWWAN];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,1)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X2
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,2)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X3
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,3)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X4
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,4)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X5
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,5)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X6
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,6)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X7
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,7)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X8
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,8)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X9
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,9)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X10
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,10)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X11
    XCTAssertTrue([trackManager.requests count] == 1);
    
    now = [now dateByAddingTimeInterval:6 * pow(2,11)];
    self.dateManager.testCurrentDate = now;
    
    [trackManager sendTrackings]; // X12
    XCTAssertTrue([trackManager.requests count] == 0);
}

- (void)testTrackManagerApplicationDidBecomeActive {
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"track_response"];
    };
    
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:NotReachable];
    
    NSDate *now = [NSDate date];
    self.dateManager.testCurrentDate = now;
    
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:self.cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] dateManager:self.dateManager];
    [trackManager addTrackWithRequest:[self simpleTrackRequest]];
    XCTAssertTrue([trackManager.requests count] == 1);
    
    self.dateManager.testCurrentDate = [now dateByAddingTimeInterval:30];
    [given([self.reachability currentReachabilityStatus]) willReturnInteger:ReachableViaWiFi];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    
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

// MARK: - Track manager delegate

- (void)trackManagerDidComplete:(NITTrackManager *)trackManager {
    if([[self name] containsString:@"testTrackManagerOnlineTriple"]) {
        if (self.caseNumber == 0) {
            self.caseNumber++;
            [[self.expectations objectForKey:EXP_ONE] fulfill];
        } else if (self.caseNumber == 1) {
            self.caseNumber++;
            [[self.expectations objectForKey:EXP_TWO] fulfill];
        } else if (self.caseNumber == 2) {
            XCTAssertTrue([trackManager.availableRequests count] == 0);
            [[self.expectations objectForKey:EXP_THREE] fulfill];
        }
    } else if ([[self name] containsString:@"testTrackManagerOnline"]) {
        XCTAssertTrue([trackManager.requests count] == 0);
        [[self.expectations objectForKey:EXP_ONE] fulfill];
    } else if([[self name] containsString:@"testTrackManagerNetworkSwitch"]) {
        XCTAssertTrue([trackManager.requests count] == 0);
        [[self.expectations objectForKey:EXP_ONE] fulfill];
    }
}

@end
