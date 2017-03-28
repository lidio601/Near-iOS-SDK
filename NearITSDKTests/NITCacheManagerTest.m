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

- (void)testRemoveAllItems {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    NSArray<NSString*> *stringItems1 = @[@"Paul", @"Joe", @"Richard", @"John"];
    NSArray<NSString*> *stringItems2 = @[@"Red", @"Yellow", @"Blue", @"Green"];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"];
    [cacheManager saveWithArray:stringItems1 forKey:@"array1"];
    [cacheManager saveWithArray:stringItems2 forKey:@"array2"];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 2);
    [cacheManager removeAllItemsWithCompletionHandler:^{
        XCTAssertTrue([cacheManager numberOfStoredKeys] == 0);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (void)testCollisions {
    NITCacheManager *cacheManagerA = [[NITCacheManager alloc] initWithAppId:@"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"];
    NITCacheManager *cacheManagerB = [[NITCacheManager alloc] initWithAppId:@"e34a7dff-1422-46b8-81cb-81a2c93ddaab"];
    
    NSArray<NSString*> *stringItems1 = @[@"Paul", @"Joe", @"Richard", @"John"];
    NSArray<NSString*> *stringItems2 = @[@"Red", @"Yellow", @"Blue", @"Green", @"Pink"];
    
    [cacheManagerA saveWithArray:stringItems1 forKey:@"items"];
    [NSThread sleepForTimeInterval:0.5];
    [cacheManagerB saveWithArray:stringItems2 forKey:@"items"];
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertTrue([cacheManagerA existsItemForKey:@"items"]);
    XCTAssertTrue([cacheManagerB existsItemForKey:@"items"]);
    XCTAssertTrue([cacheManagerA numberOfStoredKeys] == 1);
    XCTAssertTrue([cacheManagerB numberOfStoredKeys] == 1);
    
    NSArray<NSString*> *loadedItems1 = [cacheManagerA loadArrayForKey:@"items"];
    NSArray<NSString*> *loadedItems2 = [cacheManagerB loadArrayForKey:@"items"];
    XCTAssertTrue([loadedItems1 count] == 4);
    XCTAssertTrue([loadedItems2 count] == 5);
    if([loadedItems1 count] >= 3) {
        XCTAssertTrue([[loadedItems1 objectAtIndex:2] isEqualToString:@"Richard"]);
    }
    if([loadedItems2 count] >= 3) {
        XCTAssertTrue([[loadedItems2 objectAtIndex:2] isEqualToString:@"Blue"]);
    }
    
    [cacheManagerA removeAllItemsWithCompletionHandler:nil];
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertTrue([cacheManagerA numberOfStoredKeys] == 0);
    XCTAssertTrue([cacheManagerB numberOfStoredKeys] == 1);
    XCTAssertFalse([cacheManagerA existsItemForKey:@"items"]);
    XCTAssertTrue([cacheManagerB existsItemForKey:@"items"]);
    [cacheManagerB removeAllItemsWithCompletionHandler:nil];
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertTrue([cacheManagerB numberOfStoredKeys] == 0);
    XCTAssertFalse([cacheManagerB existsItemForKey:@"items"]);
}

@end
