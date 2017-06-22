//
//  NITReactionModelTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import "NITSimpleNotification.h"
#import "NITContent.h"
#import "NITImage.h"
#import "NITAudio.h"
#import "NITUpload.h"
#import "NITCoupon.h"
#import "NITClaim.h"
#import "NITFeedback.h"
#import "NITCustomJSON.h"

@interface NITReactionModelTest : NITTestCase

@end

@implementation NITReactionModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// MARK: - Simple Notification

- (void)testSerializeSimpleNotification {
    NITSimpleNotification *simpleNotification = [[NITSimpleNotification alloc] init];
    simpleNotification.notificationTitle = @"title";
    simpleNotification.message = @"message";
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:simpleNotification];
    XCTAssertNotNil(archivedData);
    NITSimpleNotification *unarchivedSimpleNotification = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    XCTAssertTrue([unarchivedSimpleNotification.notificationTitle isEqualToString:simpleNotification.notificationTitle]);
    XCTAssertTrue([unarchivedSimpleNotification.message isEqualToString:simpleNotification.message]);
}

// MARK: - Content

- (void)testSerializeContent {
    NITContent *content = [[NITContent alloc] init];
    content.content = @"Hello World!";
    content.videoLink = @"http://video.link";
    NITImage *image = [[NITImage alloc] init];
    content.images = @[image];
    content.audio = [[NITAudio alloc] init];
    content.upload = [[NITUpload alloc] init];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:content];
    XCTAssertNotNil(archivedData);
    NITContent *unarchivedContent = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    XCTAssertTrue([unarchivedContent.content isEqualToString:content.content]);
    XCTAssertTrue([unarchivedContent.videoLink isEqualToString:content.videoLink]);
    XCTAssertTrue([unarchivedContent.images count] == [content.images count]);
    XCTAssertNotNil(unarchivedContent.audio);
    XCTAssertNotNil(unarchivedContent.upload);
}

- (void)testSerializeImage {
    NITImage *image = [[NITImage alloc] init];
    image.image = @{@"square_300" : @{@"url" : @"http://image.com"}};
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:image];
    XCTAssertNotNil(archivedData);
    NITImage *unarchivedImage = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    NSString *unarchivedSmallUrl = [[unarchivedImage smallSizeURL] absoluteString];
    NSString *smallUrl = [[image smallSizeURL] absoluteString];
    XCTAssertTrue([unarchivedSmallUrl isEqualToString:smallUrl]);
}

- (void)testSerializeAudio {
    NITAudio *audio = [[NITAudio alloc] init];
    audio.audio = @{@"url" : @"http://audio.com"};
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:audio];
    XCTAssertNotNil(archivedData);
    NITAudio *unarchivedAudio = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    NSString *unarchivedAudioUrl = [[unarchivedAudio url] absoluteString];
    NSString *audioUrl = [[audio url] absoluteString];
    XCTAssertTrue([unarchivedAudioUrl isEqualToString:audioUrl]);
}

- (void)testSerializeUpload {
    NITUpload *upload = [[NITUpload alloc] init];
    upload.upload = @{@"url" : @"http://upload.com"};
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:upload];
    XCTAssertNotNil(archivedData);
    NITAudio *unarchivedUpload = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    NSString *unarchivedUploadUrl = [[unarchivedUpload url] absoluteString];
    NSString *uploadUrl = [[upload url] absoluteString];
    XCTAssertTrue([unarchivedUploadUrl isEqualToString:uploadUrl]);
}

// MARK: - Coupon

- (void)testSerializeCoupon {
    NITCoupon *coupon = [[NITCoupon alloc] init];
    coupon.name = @"Coupon name";
    coupon.couponDescription = @"Description";
    coupon.value = @"10 $";
    coupon.expiresAt = @"2017-06-05T08:32:00.000Z";
    coupon.redeemableFrom = @"2017-06-01T08:32:00.000Z";
    NITClaim *claim = [[NITClaim alloc] init];
    coupon.claims = @[claim];
    coupon.icon = [[NITImage alloc] init];
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:coupon];
    XCTAssertNotNil(archivedData);
    NITCoupon *unarchivedCoupon = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    XCTAssertTrue([unarchivedCoupon.name isEqualToString:coupon.name]);
    XCTAssertTrue([unarchivedCoupon.couponDescription isEqualToString:coupon.couponDescription]);
    XCTAssertTrue([unarchivedCoupon.value isEqualToString:coupon.value]);
    XCTAssertTrue([unarchivedCoupon.expiresAt isEqualToString:coupon.expiresAt]);
    XCTAssertTrue([unarchivedCoupon.redeemableFrom isEqualToString:coupon.redeemableFrom]);
    XCTAssertTrue([unarchivedCoupon.claims count] == 1);
    XCTAssertNotNil(unarchivedCoupon.icon);
    XCTAssertTrue([unarchivedCoupon.claims objectAtIndex:0].coupon == unarchivedCoupon);
}

- (void)testSerializeClaim {
    NITClaim *claim = [[NITClaim alloc] init];
    claim.serialNumber = @"8601";
    claim.claimedAt = @"2017-06-05T08:32:00.000Z";
    claim.redeemedAt = @"2017-06-01T08:32:00.000Z";
    claim.recipeId = @"0ff2";
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:claim];
    XCTAssertNotNil(archivedData);
    NITClaim *unarchivedClaim = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    XCTAssertTrue([unarchivedClaim.serialNumber isEqualToString:claim.serialNumber]);
    XCTAssertTrue([unarchivedClaim.claimedAt isEqualToString:claim.claimedAt]);
    XCTAssertTrue([unarchivedClaim.redeemedAt isEqualToString:claim.redeemedAt]);
    XCTAssertTrue([unarchivedClaim.recipeId isEqualToString:claim.recipeId]);
}

// MARK: - Feedback

- (void)testSerializeFeedback {
    NITFeedback *feedback = [[NITFeedback alloc] init];
    feedback.question = @"What am I?";
    feedback.recipeId = @"ffe0";
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:feedback];
    XCTAssertNotNil(archivedData);
    NITFeedback *unarchivedFeedback = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    XCTAssertTrue([unarchivedFeedback.question isEqualToString:feedback.question]);
    XCTAssertTrue([unarchivedFeedback.recipeId isEqualToString:feedback.recipeId]);
}

// MARK: - Custom JSON

- (void)testSerializeCustomJSON {
    NITCustomJSON *json = [[NITCustomJSON alloc] init];
    json.content = @{@"message" : @"Hello world!"};
    
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:json];
    XCTAssertNotNil(archivedData);
    NITCustomJSON *unarchivedJson = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    NSDictionary<NSString*, id> *unarchivedContent = unarchivedJson.content;
    XCTAssertNotNil(unarchivedContent);
    NSString *unarchivedMessage = [unarchivedContent objectForKey:@"message"];
    XCTAssertNotNil(unarchivedMessage);
    XCTAssertTrue([unarchivedMessage isEqualToString:@"Hello world!"]);
}

@end
