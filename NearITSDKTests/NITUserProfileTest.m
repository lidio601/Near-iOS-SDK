//
//  NITUserProfileTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 11/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITUserProfile.h"
#import "NITInstallation.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define PROFILEID @"user-profile-id"

@interface NITUserProfileTest : NITTestCase

@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) NITNetworkMockManger *networkManager;
@property (nonatomic, strong) NITInstallation *installation;

@end

@implementation NITUserProfileTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.configuration = mock([NITConfiguration class]);
    [given([self.configuration appId]) willReturn:@"app-id"];
    [given([self.configuration profileId]) willReturn:nil];
    self.networkManager = [[NITNetworkMockManger alloc] init];
    
    __weak NITUserProfileTest *weakSelf = self;
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/plugins/congrego/profiles"] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"]) { // Create new profile
            return [weakSelf jsonApiWithContentsOfFile:@"response_create_new_profile"];
        }
        return [[NITJSONAPI alloc] init];
    };
    
    self.installation = mock([NITInstallation class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNewProfile {
    XCTestExpectation *expectation = [self expectationWithDescription:@"newProfile"];
    
    XCTAssertNil(self.configuration.profileId);
    
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    [profile createNewProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        [verifyCount(self.installation, times(1)) registerInstallation];
        XCTAssertNil(error);
        [verifyCount(self.configuration, times(1)) setProfileId:@"user-profile-id"];
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testResetProfile {
    [given([self.configuration profileId]) willReturn:PROFILEID];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    [profile resetProfile];
    [verifyCount(self.installation, times(1)) registerInstallation];
    [verifyCount(self.configuration, times(1)) setProfileId:nilValue()];
}

- (void)testSetProfile {
    XCTAssertNil(self.configuration.profileId);
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    [profile setProfileId:PROFILEID];
    [verifyCount(self.installation, times(1)) registerInstallation];
    [verifyCount(self.configuration, times(1)) setProfileId:PROFILEID];
}

- (void)testSingleUserDataKey {
    [given([self.configuration profileId]) willReturn:nil];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [[NITJSONAPI alloc] init];
    };
    
    XCTestExpectation *expWithError = [self expectationWithDescription:@"withError"];
    [profile setUserDataWithKey:@"aKey" value:@"aValue" completionHandler:^(NSError * _Nullable error) {
        XCTAssertNotNil(error); // Error should exists because profileId is nil
        XCTAssertFalse(self.networkManager.isMockCalled);
        [expWithError fulfill];
    }];
    
    [given([self.configuration profileId]) willReturn:PROFILEID];
    XCTestExpectation *expWithoutError = [self expectationWithDescription:@"withoutError"];
    [profile setUserDataWithKey:@"aKey" value:@"aValue" completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error); // Error should exists because profileId is nil
        XCTAssertTrue(self.networkManager.isMockCalled);
        [expWithoutError fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testBatchUserDataKey {
    [given([self.configuration profileId]) willReturn:nil];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [[NITJSONAPI alloc] init];
    };
    
    NSDictionary *dataPoints = @{@"key1" : @"value1", @"key2" : @"value2" };
    
    XCTestExpectation *expWithError = [self expectationWithDescription:@"withError"];
    [profile setBatchUserDataWithDictionary:dataPoints completionHandler:^(NSError * _Nullable error) {
        XCTAssertNotNil(error); // Error should exists because profileId is nil
        XCTAssertFalse(self.networkManager.isMockCalled);
        [expWithError fulfill];
    }];
    
    [given([self.configuration profileId]) willReturn:PROFILEID];
    XCTestExpectation *expWithoutError = [self expectationWithDescription:@"withoutError"];
    [profile setBatchUserDataWithDictionary:dataPoints completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error); // Error should exists because profileId is nil
        XCTAssertTrue(self.networkManager.isMockCalled);
        [expWithoutError fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testBatchUserDataKeyWithErrorFromNetwork {
    [given([self.configuration profileId]) willReturn:PROFILEID];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:self.installation];
    
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil; // The network failure (no data from network)
    };
    
    NSDictionary *dataPoints = @{@"key1" : @"value1", @"key2" : @"value2" };
    
    XCTestExpectation *expWithError = [self expectationWithDescription:@"withError"];
    [profile setBatchUserDataWithDictionary:dataPoints completionHandler:^(NSError * _Nullable error) {
        XCTAssertNotNil(error); // Error should exists because of a network failure
        [expWithError fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

@end
