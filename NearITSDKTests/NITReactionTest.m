//
//  NITReactionTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITJSONAPI.h"
#import "NITRecipe.h"
#import "NITSimpleNotificationReaction.h"
#import "NITSimpleNotification.h"
#import "NITContentReaction.h"
#import "NITContent.h"
#import "NITImage.h"
#import "NITRecipesManager.h"
#import "NITCouponReaction.h"
#import "NITConfiguration.h"
#import "NITFeedbackReaction.h"
#import "NITFeedback.h"
#import "NITFeedbackEvent.h"
#import "NITCustomJSON.h"
#import "NITCustomJSONReaction.h"
#import "NITNetworkManager.h"
#import "NITNetworkMockManger.h"
#import "NITNetworkProvider.h"
#import "NITAudio.h"
#import "NITUpload.h"

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJlMzRhN2Q5MC0xNGQyLTQ2YjgtODFmMC04MWEyYzkzZGQ0ZDAiLCJyb2xlX2tleSI6ImFwcCJ9fX0.2GvA499N8c1Vui9au7NzUWM8B10GWaha6ASCCgPPlR8"
#define APPID @"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"
#define PROFILEID @"6a2490f4-28b9-4e36-b0f6-2c97c86b0002"
#define INSTALLATIONID @"fb56d2f1-0ef6-4333-b576-3efa8701b13d"

@interface NITReactionTest : NITTestCase

@end

@implementation NITReactionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [[NITConfiguration defaultConfiguration] setApiKey:APIKEY];
    [[NITConfiguration defaultConfiguration] setAppId:APPID];
    [[NITConfiguration defaultConfiguration] setProfileId:PROFILEID];
    [[NITConfiguration defaultConfiguration] setInstallationId:INSTALLATIONID];
    [[NITNetworkProvider sharedInstance] setConfiguration:[NITConfiguration defaultConfiguration]];
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
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITContentReaction *reaction = [[NITContentReaction alloc] initWithCacheManager:cacheManager networkManager:networkManager];
    
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_content_reaction"];
    };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [reaction contentWithRecipe:recipe completionHandler:^(id _Nonnull content, NSError * _Nullable error) {
        [verifyCount(cacheManager, times(1)) loadArrayForKey:@"ContentReaction"];
        XCTAssertTrue([networkManager isMockCalled]);
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
        
        NITAudio *audio = cntnt.audio;
        XCTAssertNotNil(audio);
        XCTAssertTrue([audio.url.absoluteString isEqualToString:@"audio-url"]);
        
        NITUpload *upload = cntnt.upload;
        XCTAssertNotNil(upload);
        XCTAssertTrue([upload.url.absoluteString isEqualToString:@"upload-url"]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testFeedbackReaction {
    NITRecipe *recipe = [[NITRecipe alloc] init];
    recipe.reactionBundleId = @"08b4935a-8ee5-45cd-923e-078a7d35953b";
    
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITFeedbackReaction *feedbackReaction = [[NITFeedbackReaction alloc] initWithCacheManager:cacheManager networkManager:networkManager];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_feeback_reaction"];
    };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [feedbackReaction contentWithRecipe:recipe completionHandler:^(id  _Nullable content, NSError * _Nullable error) {
        [verifyCount(cacheManager, times(1)) loadArrayForKey:@"FeedbackReaction"];
        XCTAssertTrue([networkManager isMockCalled]);
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITFeedback class]]);
        
        if ([content isKindOfClass:[NITFeedback class]]) {
            NITFeedback *feedback = (NITFeedback*)content;
            XCTAssertTrue([feedback.question isEqualToString:@"Sei pronto a rispondere?"]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testFeedbackEvent {
    NITRecipe *recipe = [[NITRecipe alloc] init];
    recipe.reactionBundleId = @"08b4935a-8ee5-45cd-923e-078a7d35953f";
    
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_feedback_event"];
    };
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITFeedbackReaction *reaction = [[NITFeedbackReaction alloc] initWithCacheManager:cacheManager configuration:[NITConfiguration defaultConfiguration] networkManager:networkManager];
    
    NITFeedback *feedback = [self feedbackWithContentsOfFile:@"feedback1"];
    feedback.recipeId = @"7d41504f-99e9-45e0-b272-a6fdd202b688";
    NITFeedbackEvent *event = [[NITFeedbackEvent alloc] initWithFeedback:feedback rating:4 comment:@"Test-Feedback"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [reaction sendEventWithFeedbackEvent:event completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([networkManager isMockCalled]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCustomJSON {
    NITRecipe *recipe = [[NITRecipe alloc] init];
    recipe.reactionBundleId = @"bb40734c-75c2-4ac6-a716-9267f9893baa";
    
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITCustomJSONReaction *reaction = [[NITCustomJSONReaction alloc] initWithCacheManager:cacheManager networkManager:networkManager];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_custom_json_reaction"];
    };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [reaction contentWithRecipe:recipe completionHandler:^(id  _Nullable content, NSError * _Nullable error) {
        [verifyCount(cacheManager, times(1)) loadArrayForKey:@"CustomJSONReaction"];
        XCTAssertTrue([networkManager isMockCalled]);
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITCustomJSON class]]);
        
        if ([content isKindOfClass:[NITCustomJSON class]]) {
            NITCustomJSON *customJson = (NITCustomJSON*)content;
            XCTAssertTrue([[customJson.content objectForKey:@"name"] isEqualToString:@"Mariolino"]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCouponReaction {
    NITRecipe *couponRecipe = [self recipeWithContentsOfFile:@"response_coupon_evaluated_recipe"];
    
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITCouponReaction *reaction = [[NITCouponReaction alloc] initWithCacheManager:cacheManager configuration:[NITConfiguration defaultConfiguration] networkManager:networkManager];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [reaction contentWithRecipe:couponRecipe completionHandler:^(id  _Nullable content, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        XCTAssertTrue([content isKindOfClass:[NITCoupon class]]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCoupons {
    NITConfiguration *config = [[NITConfiguration alloc] init];
    config.profileId = @"6a2490f4-28b9-4e36-b0f6-2c97c86b0002";
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:anything()]) willReturn:nil];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITCouponReaction *reaction = [[NITCouponReaction alloc] initWithCacheManager:cacheManager configuration:config networkManager:networkManager];
    
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"coupons"];
    };
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    [reaction couponsWithCompletionHandler:^(NSArray<NITCoupon *> * _Nullable coupons, NSError * _Nullable error) {
        XCTAssertTrue([networkManager isMockCalled]);
        XCTAssertNil(error);
        XCTAssertNotNil(coupons);
        XCTAssertTrue([coupons count] > 0);
        if ([coupons count] > 0) {
            NITCoupon *coupon = [coupons objectAtIndex:0];
            XCTAssertTrue([coupon.name isEqualToString:@"Le Coupon"]);
            XCTAssertTrue([coupon.value isEqualToString:@"50 €"]);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testCachedContentNotification {
    NSArray<NITContent*> *contents = [self contentsWithContentsOfFile:@"contents1"];
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    [given([cacheManager loadArrayForKey:@"ContentReaction"]) willReturn:contents];
    NITRecipe *recipe = [[NITRecipe alloc] init];
    
    recipe.reactionBundleId = @"c66db20c-20c4-4768-98e2-daf24def7722";
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"empty_config"];
    };
    NITContentReaction *reaction = [[NITContentReaction alloc] initWithCacheManager:cacheManager networkManager:networkManager];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [reaction contentWithRecipe:recipe completionHandler:^(id  _Nonnull content, NSError * _Nullable error) {
        [verifyCount(cacheManager, times(1)) loadArrayForKey:@"ContentReaction"];
        XCTAssertFalse([networkManager isMockCalled]);
        XCTAssertNil(error);
        XCTAssertNotNil(content);
        
        [cacheManager removeKey:@"ContentReaction"];
        [expectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

// MARK: - Objects

- (void)testCouponDates {
    NITCoupon *coupon = [[NITCoupon alloc] init];
    coupon.expiresAt = @"2017-04-12T23:59:59.999Z";
    NSDate *expires = coupon.expires;
    XCTAssertNotNil(expires);
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *expiresComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:expires];
    XCTAssertTrue([expiresComponents day] == 12);
    XCTAssertTrue([expiresComponents month] == 4);
    XCTAssertTrue([expiresComponents year] == 2017);
}

- (void)testClaimDates {
    NITClaim *claim = [[NITClaim alloc] init];
    claim.claimedAt = @"2017-01-10T23:59:59.999Z";
    NSDate *claimed = claim.claimed;
    XCTAssertNotNil(claimed);
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *claimedComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:claimed];
    XCTAssertTrue([claimedComponents day] == 10);
    XCTAssertTrue([claimedComponents month] == 1);
    XCTAssertTrue([claimedComponents year] == 2017);
    
    XCTAssertNil(claim.redeemed);
    claim.redeemedAt = @"2017-02-11T23:59:59.999Z";
    NSDate *redeemed = claim.redeemed;
    NSDateComponents *redeemedComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:redeemed];
    XCTAssertTrue([redeemedComponents day] == 11);
    XCTAssertTrue([redeemedComponents month] == 2);
    XCTAssertTrue([redeemedComponents year] == 2017);
    
}

@end
