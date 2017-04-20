//
//  NITLogTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestLogger.h"
#import "NITLog.h"

@interface NITLogTest : XCTestCase

@property (nonatomic, strong) NITTestLogger *testLogger;

@end

@implementation NITLogTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testLogger = [[NITTestLogger alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDefaultDisabled {
    [NITLog setLogger:self.testLogger];
    
    NITLogD([self name], @"My default debug");
    NITLogE([self name], @"My default error");
    
    XCTAssertTrue([self.testLogger.logs count] == 0);
}

- (void)testDefaultLevelEnabled {
    [NITLog setLogger:self.testLogger];
    [NITLog setLogEnabled:YES];
    
    NITLogV([self name], @"My default verbose");
    NITLogD([self name], @"My default debug");
    NITLogE([self name], @"My default error");
    
    XCTAssertTrue([self.testLogger.logs count] == 2);
    XCTAssertTrue([[[self.testLogger logs] firstObject] containsString:@"[DEBUG]"]);
    XCTAssertTrue([[[self.testLogger logs] lastObject] containsString:@"[ERROR]"]);
}

- (void)testLevel {
    [NITLog setLogger:self.testLogger];
    [NITLog setLogEnabled:YES];
    [NITLog setLevel:NITLogLevelWarning];
    
    NITLogV([self name], @"My default verbose");
    NITLogD([self name], @"My default debug");
    NITLogW([self name], @"My default warning");
    NITLogE([self name], @"My default error");
    
    XCTAssertTrue([self.testLogger.logs count] == 2);
    XCTAssertTrue([[[self.testLogger logs] firstObject] containsString:@"[WARNING]"]);
    XCTAssertTrue([[[self.testLogger logs] lastObject] containsString:@"[ERROR]"]);
}

@end
