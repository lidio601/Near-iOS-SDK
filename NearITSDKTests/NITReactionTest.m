//
//  NITReactionTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NITJSONAPI.h"
#import "NITRecipe.h"
#import "NITSimpleNotificationReaction.h"
#import "NITSimpleNotification.h"
#import "NITContentReaction.h"
#import "NITContent.h"
#import "NITImage.h"
#import "NITNetworkMock.h"
#import "NITRecipesManager.h"
#import "NITCouponReaction.h"

@interface NITReactionTest : NITTestCase

@end

@implementation NITReactionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"response_content_reaction" ofType:@"json"];
    [NITNetworkMock sharedInstance].enabled = YES;
    [[NITNetworkMock sharedInstance] registerData:[NSData dataWithContentsOfFile:path] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/content-notification/contents/e77d28fc-c6a0-4b9f-a28a-44e776119e25"]) {
            return YES;
        }
        return NO;
    }];
    [[NITNetworkMock sharedInstance] registerData:[NSData data] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/content-notification/contents/c66db20c-20c4-4768-98e2-daf24def7722"]) {
            return YES;
        }
        return NO;
    }];
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
        XCTAssert([cntnt.content containsString:@"Benvenuto e Benvenuti"]);
        
        NITImage *image = [cntnt.images objectAtIndex:0];
        NSURL *smallSizeURL = [image smallSizeURL];
        XCTAssertNotNil(smallSizeURL);
        XCTAssertTrue([smallSizeURL.absoluteString containsString:@"square_300_file.jpeg"]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCouponReaction {
    NITRecipe *couponRecipe = [self recipeWithContentsOfFile:@"response_coupon_evaluated_recipe"];
    
    NITCouponReaction *reaction = [[NITCouponReaction alloc] init];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [reaction contentWithRecipe:couponRecipe completionHandler:^(id  _Nullable content, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITCoupon class]]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCachedContentNotification {
    NSArray<NITContent*> *contents = [self contentsWithContentsOfFile:@"contents1"];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"content-test"];
    [cacheManager saveWithArray:contents forKey:@"ContentReaction"];
    [NSThread sleepForTimeInterval:0.5];
    NITRecipe *recipe = [self recipeWithContentsOfFile:@"content_recipe"];
    recipe.reactionBundleId = @"c66db20c-20c4-4768-98e2-daf24def7722";
    NITContentReaction *reaction = [[NITContentReaction alloc] initWithCacheManager:cacheManager];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [reaction contentWithRecipe:recipe completionHandler:^(id  _Nonnull content, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        
        [cacheManager removeKey:@"ContentReaction"];
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

@end
