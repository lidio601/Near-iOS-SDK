//
//  NITReactionTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITJSONAPI.h"
#import "NITRecipe.h"
#import "NITSimpleNotificationReaction.h"
#import "NITSimpleNotification.h"
#import "NITContentReaction.h"
#import "NITContent.h"

@interface NITReactionTest : XCTestCase

@end

@implementation NITReactionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleNotification {
    NITRecipe *recipe = [self recipeWithContentsOfFile:@"simple_recipe"];
    NITSimpleNotificationReaction *reaction = [[NITSimpleNotificationReaction alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [reaction contentWithRecipe:recipe completionHandler:^(id  _Nonnull content, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITSimpleNotification class]]);
        
        NITSimpleNotification *notification = (NITSimpleNotification*)content;
        XCTAssertNotNil(notification.notificationTitle);
        XCTAssertNotNil(notification.message);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testContentNotification {
    NITRecipe *recipe = [self recipeWithContentsOfFile:@"content_recipe"];
    NITContentReaction *reaction = [[NITContentReaction alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [reaction contentWithRecipe:recipe completionHandler:^(id _Nonnull content, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITContent class]]);
        
        NITContent *cntnt = (NITContent*)content;
        XCTAssertTrue([cntnt.images count] > 0);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (NITRecipe*)recipeWithContentsOfFile:(NSString*)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    
    [jsonApi registerClass:[NITRecipe class] forType:@"recipes"];
    
    NSArray<NITRecipe*> *recipes = [jsonApi parseToArrayOfObjects];
    XCTAssertTrue([recipes count] > 0);
    
    return [recipes objectAtIndex:0];
}

@end
