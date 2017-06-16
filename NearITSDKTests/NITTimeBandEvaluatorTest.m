//
//  NITTimeBandEvaluatorTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITTimeBandEvaluator.h"
#import "NITDateManager.h"

@interface NITTimeBandEvaluatorTest : NITTestCase

@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITTimeBandEvaluator *timeEvaluator;

@end

@implementation NITTimeBandEvaluatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dateManager = mock([NITDateManager class]);
    self.timeEvaluator = [[NITTimeBandEvaluator alloc] initWithDateManager:self.dateManager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWithFromAndTo {
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:@"16:00"]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497535457]]; // Thu, 15 Jun 2017 14:04:17 +0000 -> 16:04 +0200
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:@"16:00"]);
    
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:@"16:00"]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:@"12:10" toHour:@"15:10"]);
}

- (void)testOnlyFrom {
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:nil]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497535457]]; // Thu, 15 Jun 2017 14:04:17 +0000 -> 16:04 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:nil]);
    
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00" toHour:nil]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:@"15:34" toHour:nil]);
}

- (void)testOnlyTo {
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:@"16:00"]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:@"15:00"]);
    
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:@"16:00"]);
    
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:@"15:00"]);
}

- (void)testNilTimeBand {
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:nil]);
    
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497565457]]; // Thu, 15 Jun 2017 22:24:17 +0000 -> 15:24 -0700
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:nil toHour:nil]);
}

- (void)testTimeBandWithSeconds {
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertTrue([self.timeEvaluator isInTimeBandWithFromHour:@"15:00:00" toHour:@"16:00:00"]);
    
    [self.timeEvaluator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"CET"]];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:1497533057]]; // Thu, 15 Jun 2017 13:24:17 +0000 -> 15:24 +0200
    XCTAssertFalse([self.timeEvaluator isInTimeBandWithFromHour:@"12:00:00" toHour:@"14:00:00"]);
}

@end
