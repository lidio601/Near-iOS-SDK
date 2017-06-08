//
//  NITConfigurationTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 03/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NITConfiguration.h"
#import "NITUtils.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

@interface NITConfigurationTest : NITTestCase

@end

@implementation NITConfigurationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testApiKey {
    NSString *apiKey = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJNeUFwcElkIiwicm9sZV9rZXkiOiJhcHAifX19.AalMftx-rJa-6O3ZzMdjSod4LzBfdvp2G7uT5sFx1Xg";
    NSUserDefaults *userDefaults = mock([NSUserDefaults class]);
    NITConfiguration *config = [[NITConfiguration alloc] initWithUserDefaults:userDefaults];
    
    [config setApiKey:apiKey];
    [verify(userDefaults) setObject:apiKey forKey:@"apikey-MyAppId"];
    
    XCTAssertNotNil(config.apiKey);
    XCTAssertTrue([config.apiKey isEqualToString:apiKey]);
    XCTAssertNotNil(config.appId);
    XCTAssertTrue([config.appId isEqualToString:@"MyAppId"]);
    
    [config clear];
    [verify(userDefaults) removeObjectForKey:@"apikey-MyAppId"];
    
    XCTAssertNil(config.apiKey);
    XCTAssertNil(config.appId);
}

- (void)testLoadApiKeyFromUserDefaults {
    NSString *apiKey = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJNeUFwcElkIiwicm9sZV9rZXkiOiJhcHAifX19.AalMftx-rJa-6O3ZzMdjSod4LzBfdvp2G7uT5sFx1Xg";
    NSUserDefaults *userDefaults = mock([NSUserDefaults class]);
    NITConfiguration *config = [[NITConfiguration alloc] initWithUserDefaults:userDefaults];
    
    config.appId = @"MyAppId";
    [given([userDefaults objectForKey:@"apikey-MyAppId"]) willReturn:apiKey];
    XCTAssertTrue([config.apiKey isEqualToString:apiKey]);
}

- (void)testMultiConfiguration {
    NSString *apiKey1 = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJhcGlLZXkxIiwicm9sZV9rZXkiOiJhcHAifX19.ibOb_wrTd-r5lehDv-G0-h9CBkI6nf_icE9Rbp5r938";
    NSString *apiKey2 = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJhcGlLZXkyIiwicm9sZV9rZXkiOiJhcHAifX19.ATS4pdCxlnJt4939E-cfOK9mX2ns8FNNz9QQFn7mMRk";
    
    
    NITConfiguration *config1 = [[NITConfiguration alloc] init];
    NITConfiguration *config2 = [[NITConfiguration alloc] init];
    
    config1.apiKey = apiKey1;
    XCTAssertNotNil(config1.apiKey);
    XCTAssertNotNil(config1.appId);
    XCTAssertTrue([config1.appId isEqualToString:@"apiKey1"]);
    XCTAssertTrue([[[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey1"] isEqualToString:@"apiKey1"]);
    XCTAssertNil(config2.apiKey);
    XCTAssertNil(config2.appId);
    
    config2.apiKey = apiKey2;
    XCTAssertNotNil(config2.apiKey);
    XCTAssertNotNil(config2.appId);
    XCTAssertTrue([config2.appId isEqualToString:@"apiKey2"]);
    XCTAssertTrue([[[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey2"] isEqualToString:@"apiKey2"]);
    
    [config1 clear];
    XCTAssertNil(config1.apiKey);
    XCTAssertNil(config1.appId);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey1"]);
    XCTAssertNotNil(config2.apiKey);
    XCTAssertNotNil(config2.appId);
    XCTAssertNotNil([[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey2"]);
    
    [config2 clear];
    XCTAssertNil(config1.apiKey);
    XCTAssertNil(config1.appId);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey1"]);
    XCTAssertNil(config2.apiKey);
    XCTAssertNil(config2.appId);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"appid-apiKey2"]);
}

- (void)testSetWithoutApiKey {
    NITConfiguration *config = [[NITConfiguration alloc] init];
    [config setDeviceToken:@"device-token"];
    
    XCTAssertNotNil(config.deviceToken);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"]);
    [config clear];
    XCTAssertNil(config.deviceToken);
}

- (void)testProfileId {
    NSString *apiKey1 = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJhcGlLZXkxIiwicm9sZV9rZXkiOiJhcHAifX19.ibOb_wrTd-r5lehDv-G0-h9CBkI6nf_icE9Rbp5r938";
    
    NITConfiguration *config = [[NITConfiguration alloc] init];
    config.apiKey = apiKey1;
    config.profileId = @"test-profile-id";
    XCTAssertNotNil(config.profileId);
    XCTAssertTrue([config.profileId isEqualToString:@"test-profile-id"]);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"profileId"]);
    XCTAssertNotNil([[NSUserDefaults standardUserDefaults] stringForKey:@"profileId-apiKey1"]);
    [config clear];
}

- (void)testInstallationId {
    NSString *apiKey1 = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJhcGlLZXkxIiwicm9sZV9rZXkiOiJhcHAifX19.ibOb_wrTd-r5lehDv-G0-h9CBkI6nf_icE9Rbp5r938";
    
    NITConfiguration *config = [[NITConfiguration alloc] init];
    config.apiKey = apiKey1;
    config.installationId = @"test-installation-id";
    XCTAssertNotNil(config.installationId);
    XCTAssertTrue([config.installationId isEqualToString:@"test-installation-id"]);
    XCTAssertNil([[NSUserDefaults standardUserDefaults] stringForKey:@"installationid"]);
    XCTAssertNotNil([[NSUserDefaults standardUserDefaults] stringForKey:@"installationid-apiKey1"]);
    [config clear];
}

- (void)testUserDefaultsSuite {
    NSString *apiKey = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJNeUFwcElkIiwicm9sZV9rZXkiOiJhcHAifX19.AalMftx-rJa-6O3ZzMdjSod4LzBfdvp2G7uT5sFx1Xg";
    NSString *profileId = @"profile-id";
    NSString *installationId = @"installation-id";
    
    NSUserDefaults *userDefaults = mock([NSUserDefaults class]);
    NITConfiguration *config = [[NITConfiguration alloc] initWithUserDefaults:userDefaults];
    [config setApiKey:apiKey];
    [config setProfileId:profileId];
    [config setInstallationId:installationId];
    
    NSUserDefaults *suiteUserDefaults = mock([NSUserDefaults class]);
    [config setSuiteUserDefaults:suiteUserDefaults];
    
    [verify(suiteUserDefaults) setObject:apiKey forKey:@"apikey"];
    [verify(suiteUserDefaults) setObject:profileId forKey:@"profileId"];
    [verify(suiteUserDefaults) setObject:installationId forKey:@"installationid"];
}

- (void)testInitUserDefaultsPrefilled {
    NSString *apiKey = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJNeUFwcElkIiwicm9sZV9rZXkiOiJhcHAifX19.AalMftx-rJa-6O3ZzMdjSod4LzBfdvp2G7uT5sFx1Xg";
    NSString *profileId = @"profile-id";
    NSString *installationId = @"installation-id";
    
    NSUserDefaults *userDefaults = mock([NSUserDefaults class]);
    [given([userDefaults objectForKey:@"apikey"]) willReturn:apiKey];
    [given([userDefaults objectForKey:@"profileId"]) willReturn:profileId];
    [given([userDefaults objectForKey:@"installationid"]) willReturn:installationId];
    
    NITConfiguration *config = [[NITConfiguration alloc] initWithUserDefaults:userDefaults];
    XCTAssertTrue([config.apiKey isEqualToString:apiKey]);
    XCTAssertTrue([config.appId isEqualToString:@"MyAppId"]);
    XCTAssertTrue([config.profileId isEqualToString:profileId]);
    XCTAssertTrue([config.installationId isEqualToString:installationId]);
}

@end
