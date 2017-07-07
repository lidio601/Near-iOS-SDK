//
//  NITSchedulerValidatorTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITDateManager.h"
#import "NITScheduleValidator.h"

#define DAY_SECONDS 86400
#define YEAR_SECONDS 31536000

@interface NITSchedulerValidatorTest : NITTestCase

@property (nonatomic, strong) NITScheduleValidator *scheduleValidator;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITRecipe *testRecipe;
@property (nonatomic, strong) NITRecipe *testRecipe2;
@property (nonatomic, strong) NITRecipe *testRecipe3;
@property (nonatomic, strong) NSString *realDefaultTimeZoneAbbreviation;

@end

@implementation NITSchedulerValidatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testRecipe = [[NITRecipe alloc] init];
    self.testRecipe2 = [[NITRecipe alloc] init];
    self.testRecipe3 = [[NITRecipe alloc] init];
    self.dateManager = mock([NITDateManager class]);
    NSDate *now = [NSDate date];
    [given([self.dateManager currentDate]) willReturn:now];
    self.scheduleValidator = [[NITScheduleValidator alloc] initWithDateManager:self.dateManager];
    [self.scheduleValidator setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    self.realDefaultTimeZoneAbbreviation = [NSTimeZone localTimeZone].abbreviation;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:self.realDefaultTimeZoneAbbreviation]];
}

- (void)testSchedulingIsMissing {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_complete_coverage_validity"] objectForKey:@"scheduling"];
    self.testRecipe2.scheduling = scheduling;
    
    scheduling = [[self jsonWithContentsOfFile:@"schedule_always_valid_edge_case"] objectForKey:@"scheduling"];
    self.testRecipe3.scheduling = scheduling;
    
    NSDate *now = [NSDate date];
    [given([self.dateManager currentDate]) willReturn:now];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval: DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe3]);
}

- (void)testRecipeScheduleForDatePeriod {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_only_during_jun_2017"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2017];
    [dateComponents setMonth:6];
    [dateComponents setDay:15];
    [dateComponents setHour:12];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    // middle of june
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-06-15 12:00:00
    
    // start of june
    [dateComponents setDay:1];
    [dateComponents setHour:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-06-01 00:00:00
    
    // end of june
    [dateComponents setDay:30];
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-06-30 23:59:59
    
    // way before
    [dateComponents setMonth:1];
    [dateComponents setDay:1];
    [dateComponents setHour:12];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-01-01 12:00:00
    
    // just before
    [dateComponents setMonth:5];
    [dateComponents setDay:31];
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-05-31 23:59:59
    
    // just after
    [dateComponents setMonth:7];
    [dateComponents setDay:1];
    [dateComponents setHour:0];
    [dateComponents setMinute:00];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-07-01 00:00:00
    
    // way after
    [dateComponents setMonth:8];
    [dateComponents setDay:20];
    [dateComponents setHour:18];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]); // 2017-08-20 18:00:00
}

- (void)testRecipeIsScheduledOnlyForSelectedDaysOfWeek {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_only_mon_wed_thu_sat"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    
    scheduling = [[self jsonWithContentsOfFile:@"schedule_empty_days_schedule"] objectForKey:@"scheduling"];
    self.testRecipe2.scheduling = scheduling;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2017];
    [dateComponents setMonth:6];
    [dateComponents setDay:12];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    // Monday
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Tuesday
    [dateComponents setDay:13];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Wednesday
    [dateComponents setDay:14];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Thursday
    [dateComponents setDay:15];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Friday
    [dateComponents setDay:16];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Saturday
    [dateComponents setDay:17];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
    
    // Sunday
    [dateComponents setDay:18];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe2]);
}

- (void)testRecipeScheduledForMultipleTimeframes {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_various_daily_timeframes"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2017];
    [dateComponents setMonth:6];
    [dateComponents setDay:12];
    
    // True values
    
    [dateComponents setHour:9];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:9];
    [dateComponents setMinute:30];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:12];
    [dateComponents setMinute:30];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:13];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:14];
    [dateComponents setMinute:45];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:17];
    [dateComponents setMinute:15];
    [dateComponents setSecond:27];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:18];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:18];
    [dateComponents setMinute:50];
    [dateComponents setSecond:3];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // False values
    
    [dateComponents setHour:8];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:8];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setSecond:1];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:11];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:12];
    [dateComponents setMinute:29];
    [dateComponents setSecond:59];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:14];
    [dateComponents setMinute:45];
    [dateComponents setSecond:1];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:16];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:17];
    [dateComponents setMinute:15];
    [dateComponents setSecond:26];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:18];
    [dateComponents setMinute:50];
    [dateComponents setSecond:4];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setDay:13]; // Tuesday
    [dateComponents setHour:12];
    [dateComponents setMinute:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testRecipeHasOverlappingConditions {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_multiple_validity_periods"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    // on a day of june
    [dateComponents setYear:2017];
    [dateComponents setMonth:6];
    [dateComponents setDay:15];
    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    // june 2017 exclusive hours
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // 2017 exclusive hours
    [dateComponents setHour:15];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // always on hours
    [dateComponents setHour:17];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // 20th august 2017 exclusive hours
    [dateComponents setHour:20];
    [dateComponents setMinute:30];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // on a day of 2017
    [dateComponents setMonth:10];
    [dateComponents setDay:3];
    // june 2017 exclusive hours
    [dateComponents setHour:10];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // always on hours
    [dateComponents setHour:15];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // always on hours
    [dateComponents setHour:17];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // 20th august 2017 exclusive hours
    [dateComponents setHour:20];
    [dateComponents setMinute:30];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testMultipleTimeframesTimeZonePDT {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_various_daily_timeframes"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    [self.scheduleValidator setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2017];
    [dateComponents setMonth:6];
    [dateComponents setDay:12];
    
    // True values
    
    [dateComponents setHour:9];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:14];
    [dateComponents setMinute:45];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:18];
    [dateComponents setMinute:50];
    [dateComponents setSecond:3];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // False values
    
    [dateComponents setHour:8];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [dateComponents setHour:18];
    [dateComponents setMinute:50];
    [dateComponents setSecond:4];
    [given([self.dateManager currentDate]) willReturn:[gregorianCalendar dateFromComponents:dateComponents]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

@end
