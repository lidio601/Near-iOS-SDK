//
//  NITCacheManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITCacheManager.h"

@interface NITCacheManagerTest : XCTestCase

@end

@implementation NITCacheManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAppDirectory {
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"];
    NSString *appPath = [cacheManager appDirectory];
    XCTAssertTrue([appPath containsString:@"Near/e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"]);
}

- (void)testComplete {
    NSString *KEY = @"names";
    NSArray<NSString*> *stringItems = @[@"Paul", @"Joe", @"Richard", @"John"];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"];
    [cacheManager saveWithArray:stringItems forKey:KEY];
    [NSThread sleepForTimeInterval:1.0];
    XCTAssertTrue([cacheManager existsItemForKey:KEY]);
    NSArray<NSString*> *loadedItems = [cacheManager loadArrayForKey:KEY];
    XCTAssertTrue([loadedItems count] == 4);
    if([loadedItems count] >= 3) {
        XCTAssertTrue([[loadedItems objectAtIndex:0] isEqualToString:@"Paul"]);
        XCTAssertTrue([[loadedItems objectAtIndex:2] isEqualToString:@"Richard"]);
    }
    [cacheManager removeKey:KEY];
    XCTAssertFalse([cacheManager existsItemForKey:KEY]);
}

@end
