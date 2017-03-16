//
//  NearITSDKTests.m
//  NearITSDKTests
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITJSONAPI.h"

@import ObjectiveC.runtime;

@interface NearITSDKTests : XCTestCase

@end

@implementation NearITSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testReflection {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([NITJSONAPI class], &outCount);
    for(int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            //const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithCString:propName
                                                        encoding:[NSString defaultCStringEncoding]];
            NSLog(@"%@", propertyName);
        }
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
