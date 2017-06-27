//
//  NITZipTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 26/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NSData+Zip.h"

@interface NITZipTest : NITTestCase

@end

@implementation NITZipTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHelloWorldUnzip {
    NSString *helloWorldZip = @"eNrzSM3JyVcIzy/KSVEEABxJBD4=";
    NSData *zipData = [[NSData alloc] initWithBase64EncodedString:helloWorldZip options:0];
    NSData *unzipped = [zipData gzipInflate];
    NSString *unzippedString = [[NSString alloc] initWithData:unzipped encoding:NSUTF8StringEncoding];
    XCTAssertTrue([unzippedString isEqualToString:@"Hello World!"]);
}

- (void)testJsonZipAndUnzip {
    NSString *json = @"{\"app_id\":\"aa3ffdd3-8111-438e-b55d-d952d5cd6f20\",\"content\":{\"ok\":true},\"owner_id\":\"678eed27-5890-45f9-8214-fa5a4ba584ae\",\"created_at\":\"2017-06-22T16:56:19.891518Z\",\"updated_at\":\"2017-06-22T16:56:19.891518Z\"}";
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSData *zipData = [jsonData zlibDeflate];
    NSData *unzipped = [zipData zlibInflate];
    NSString *unzippedJson = [[NSString alloc] initWithData:unzipped encoding:NSUTF8StringEncoding];
    XCTAssertTrue([unzippedJson isEqualToString:json]);
}

- (void)testJsonUnzip {
    NSString *unzippedJsonSample = @"{\"app_id\":\"aa3ffdd3-8111-438e-b55d-d952d5cd6f20\",\"content\":{\"ok\":true},\"owner_id\":\"678eed27-5890-45f9-8214-fa5a4ba584ae\",\"created_at\":\"2017-06-22T16:56:19.891518Z\",\"updated_at\":\"2017-06-22T16:56:19.891518Z\"}";
    NSString *jsonZip = @"eJyNzMEKgzAMANB/ydmMpja17XfstItEk8IYqIiyg/jvc+wHdn+8A2RZ+qdC\nAZG2VtUWExFhaJPhwKyomb3yqLF6Bw2M87TZtEE5YH5B2dbdzgbm92Tr74ld\nMlPfIafsMHDNmDwFrMISBuEUxL7ParKZ9nJV4B116CJ6f6dYOBbKt5SJKT0u\nui/6Hz0/JMc4wg==";
    NSData *zipData = [NSData dataFromBase64String:jsonZip];
    NSData *unzipped = [zipData zlibInflate];
    NSString *unzippedJson = [[NSString alloc] initWithData:unzipped encoding:NSUTF8StringEncoding];
    XCTAssertTrue([unzippedJson isEqualToString:unzippedJsonSample]);
}

@end
