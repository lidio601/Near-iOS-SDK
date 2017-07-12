//
//  NITUserDataBackoffTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NITUserDataBackoff.h"
#import "NITConfiguration.h"
#import "NITCacheManager.h"
#import "NITNetworkMockManger.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

@interface NITUserDataBackoff (Tests)

- (BOOL)isBusy;
- (BOOL)isQueued;
- (NSMutableDictionary *)userData;

@end

@interface NITUserDataBackoffTest : NITTestCase<NITUserDataBackoffDelegate>

@property (nonatomic, strong) NITUserDataBackoff *backoff;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) NITNetworkMockManger *networkManager;
@property (nonatomic, strong) XCTestExpectation *backoffExpectation;

@end

@implementation NITUserDataBackoffTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.configuration = mock([NITConfiguration class]);
    [given(self.configuration.profileId) willReturn:@"profileId"];
    self.cacheManager = mock([NITCacheManager class]);
    self.networkManager = [[NITNetworkMockManger alloc] init];
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [[NITJSONAPI alloc] init];
    };
    self.backoff = [[NITUserDataBackoff alloc] initWithConfiguration:self.configuration networkManager:self.networkManager cacheManager:self.cacheManager];
    self.backoff.delegate = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWithNoProfile {
    [given(self.configuration.profileId) willReturn:nil];
    
    [self.backoff setUserDataWithKey:@"key" value:@"value"];
    [verifyCount(self.cacheManager, times(1)) saveWithObject:anything() forKey:UserDataBackoffCacheKey];
    self.backoffExpectation = [self expectationWithDescription:@"noProfile"];
    
    [self performSelector:@selector(noProfileSelector) withObject:nil afterDelay:2.5];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testSingleDataPoint {
    [self.backoff setUserDataWithKey:@"key" value:@"value"];
    XCTAssertTrue([[self.backoff userData] count] == 1);
    [verifyCount(self.cacheManager, times(1)) saveWithObject:anything() forKey:UserDataBackoffCacheKey];
    self.backoffExpectation = [self expectationWithDescription:@"singleDataPoint"];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testSingleDataPointFailure {
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    
    [self.backoff setUserDataWithKey:@"key" value:@"value"];
    self.backoffExpectation = [self expectationWithDescription:@"singleDataPointFailure"];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testShouldSendDataPoints {
    [self.backoff setUserDataWithKey:@"key" value:@"value"];
    [self.backoff shouldSendDataPoints];
    
    self.backoffExpectation = [self expectationWithDescription:@"shouldSend"];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testMultipleDataPoints {
    [self.backoff setUserDataWithKey:@"key1" value:@"value1"];
    [self.backoff setUserDataWithKey:@"key2" value:@"value2"];
    
    self.backoffExpectation = [self expectationWithDescription:@"multipleDataPoints"];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

// MARK: - Timers

- (void)noProfileSelector {
    XCTAssertFalse(self.backoff.isBusy);
    XCTAssertTrue(self.backoff.isQueued);
    XCTAssertFalse(self.networkManager.isMockCalled);
    [verifyCount(self.configuration, times(1)) profileId];
    [self.backoffExpectation fulfill];
}

// MARK: - Backoff delegate

- (void)userDataBackoffDidComplete:(NITUserDataBackoff *)userDataBackoff {
    if ([[self name] containsString:@"testSingleDataPoint"]) {
        XCTAssertFalse(self.backoff.isBusy);
        XCTAssertFalse(self.backoff.isQueued);
        XCTAssertTrue(self.networkManager.isMockCalled);
        XCTAssertTrue([[self.backoff userData] count] == 0);
        [self.backoffExpectation fulfill];
    } else if ([[self name] containsString:@"testShouldSend"]) {
        XCTAssertFalse(self.backoff.isBusy);
        XCTAssertFalse(self.backoff.isQueued);
        XCTAssertTrue(self.networkManager.isMockCalled);
        XCTAssertTrue([[self.backoff userData] count] == 0);
        [self.backoffExpectation fulfill];
    } else if ([[self name] containsString:@"testMultipleDataPoints"]) {
        XCTAssertFalse(self.backoff.isBusy);
        XCTAssertFalse(self.backoff.isQueued);
        XCTAssertTrue(self.networkManager.isMockCalled);
        XCTAssertTrue(self.networkManager.numberOfCalls == 1);
        XCTAssertTrue([[self.backoff userData] count] == 0);
        [self.backoffExpectation fulfill];
    }
}

- (void)userDataBackoffDidFailed:(NITUserDataBackoff *)userDataBackoff withError:(NSError *)error {
    if ([[self name] containsString:@"testSingleDataPointFailure"]) {
        XCTAssertFalse(self.backoff.isBusy);
        XCTAssertTrue(self.backoff.isQueued);
        XCTAssertFalse(self.networkManager.isMockCalled);
        XCTAssertTrue([[self.backoff userData] count] == 1);
        [self.backoffExpectation fulfill];
    }
}

@end
