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
    NITConfiguration *config = [[NITConfiguration alloc] init];
    
    [config setApiKey:apiKey];
    
    XCTAssertNotNil(config.apiKey);
    XCTAssertTrue([config.apiKey isEqualToString:apiKey]);
    XCTAssertNotNil(config.appId);
    XCTAssertTrue([config.appId isEqualToString:@"MyAppId"]);
    
    [config clear];
    
    XCTAssertNil(config.apiKey);
    XCTAssertNil(config.appId);
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

@end
