//
//  NITUtilsTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJlMzRhN2Q5MC0xNGQyLTQ2YjgtODFmMC04MWEyYzkzZGQ0ZDAiLCJyb2xlX2tleSI6ImFwcCJ9fX0.2GvA499N8c1Vui9au7NzUWM8B10GWaha6ASCCgPPlR8"

@interface NITUtilsTest : XCTestCase

@end

@implementation NITUtilsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGrabAppId {
    NSArray<NSString*> *components = [APIKEY componentsSeparatedByString:@"."];
    
    XCTAssertEqual([components count], 3);
    
    NSString *payload = [components objectAtIndex:1];
    
    NSInteger module = [payload length] % 4;
    if (module != 0) {
        while((4 - module) != 0) {
            payload = [payload stringByAppendingString:@"="];
            module++;
        }
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:payload options:0];
    
    XCTAssertNotNil(data, @"Data is nil");
    
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    
    XCTAssertNil(jsonError, @"");
    
    NSLog(@"%@", json);
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
