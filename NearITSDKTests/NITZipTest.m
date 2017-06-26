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

@end
