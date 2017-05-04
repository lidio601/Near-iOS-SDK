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

#define PROFILEID @"user-profile-id"

@interface NITUserProfileTest : NITTestCase

@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) NITNetworkMockManger *networkManager;

@end

@implementation NITUserProfileTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.configuration = [[NITConfiguration alloc] init];
    self.configuration.apiKey = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJ1c2VyLXByb2ZpbGUtYXBwLWlkIiwicm9sZV9rZXkiOiJhcHAifX19.Y-NMi7bRqKE1S8MCI7sEyXEEg2Yjz6-UXh2vZ01S6GU";
    self.networkManager = [[NITNetworkMockManger alloc] init];
    
    __weak NITUserProfileTest *weakSelf = self;
    self.networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"/plugins/congrego/profiles"] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"]) { // Create new profile
            return [weakSelf jsonApiWithContentsOfFile:@"response_create_new_profile"];
        }
        return [[NITJSONAPI alloc] init];
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.configuration clear];
}

- (void)testNewProfile {
    XCTestExpectation *expectation = [self expectationWithDescription:@"newProfile"];
    
    XCTAssertNil(self.configuration.profileId);
    
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configuration networkManager:self.networkManager];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:installation];
    [profile createNewProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([self.configuration.profileId isEqualToString:PROFILEID]);
        XCTAssertNil(self.configuration.installationId);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testResetProfile {
    self.configuration.profileId = PROFILEID;
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configuration networkManager:self.networkManager];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:installation];
    [profile resetProfile];
    XCTAssertNil(self.configuration.profileId);
}

- (void)testSetProfile {
    XCTAssertNil(self.configuration.profileId);
    NITInstallation *installation = [[NITInstallation alloc] initWithConfiguration:self.configuration networkManager:self.networkManager];
    NITUserProfile *profile = [[NITUserProfile alloc] initWithConfiguration:self.configuration networkManager:self.networkManager installation:installation];
    [profile setProfileId:PROFILEID];
    XCTAssertTrue([self.configuration.profileId isEqualToString:PROFILEID]);
}

@end
