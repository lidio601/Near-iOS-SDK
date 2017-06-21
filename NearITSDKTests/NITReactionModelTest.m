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

@end
