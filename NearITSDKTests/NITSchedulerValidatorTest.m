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
@property (nonatomic, strong) NSString *realDefaultTimeZoneAbbreviation;

@end

@implementation NITSchedulerValidatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testRecipe = [[NITRecipe alloc] init];
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
    NSDate *now = [NSDate date];
    [given([self.dateManager currentDate]) willReturn:now];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval: DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testSchedulingCoversEverytime {
    NSArray *scheduling = [[self jsonWithContentsOfFile:@"schedule_complete_coverage_validity"] objectForKey:@"scheduling"];
    self.testRecipe.scheduling = scheduling;
    
    NSDate *now = [NSDate date];
    [given([self.dateManager currentDate]) willReturn:now];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval: DAY_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    [given([self.dateManager currentDate]) willReturn:[now dateByAddingTimeInterval:-YEAR_SECONDS * 10]];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
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

/* - (void)testSchedulingIsMissing {
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testSchedulingIsForThisMonth {
    // when a recipe is scheduled for the month of january 2017
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2017];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startPeriod = [gregorianCalendar dateFromComponents:components];
    [components setDay:31];
    NSDate *endPeriod = [gregorianCalendar dateFromComponents:components];
    self.testRecipe.scheduling = [self buildSchedulingWithStartDate:startPeriod endDate:endPeriod startTime:nil endTime:nil];
    [given([self.dateManager currentDate]) willReturn:startPeriod];
    // then it is valid on the start date
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:endPeriod];
    // then also on the end date
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [components setDay:15];
    NSDate *middle = [gregorianCalendar dateFromComponents:components];
    [given([self.dateManager currentDate]) willReturn:middle];
    // then is valid in the middle of the period
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testWhenNotScheduledForToday {
    // when a recipe is scheduled for the month of january 2017
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2017];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startPeriod = [gregorianCalendar dateFromComponents:components];
    [components setDay:31];
    NSDate *endPeriod = [gregorianCalendar dateFromComponents:components];
    self.testRecipe.scheduling = [self buildSchedulingWithStartDate:startPeriod endDate:endPeriod startTime:nil endTime:nil];
    // then it is not valid the day before the start
    [given([self.dateManager currentDate]) willReturn:[startPeriod dateByAddingTimeInterval:-1 * 60]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    // then is not valid the day after the end
    [given([self.dateManager currentDate]) willReturn:[endPeriod dateByAddingTimeInterval:60 * 60 * 24]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    // then is not valid a month after the end
    [given([self.dateManager currentDate]) willReturn:[endPeriod dateByAddingTimeInterval:60 * 60 * 24 * 30]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    // then is not valid a year before
    [given([self.dateManager currentDate]) willReturn:[startPeriod dateByAddingTimeInterval:-1 * 60 * 60 * 24 * 365]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testScheduledDateTimeZone {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:2017];
    [components setMonth:1];
    [components setDay:1];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startPeriod = [gregorianCalendar dateFromComponents:components];
    NSDate *endPeriod = [gregorianCalendar dateFromComponents:components];
    self.testRecipe.scheduling = [self buildSchedulingWithStartDate:startPeriod endDate:endPeriod startTime:nil endTime:nil];

    NSTimeZone *cet = [NSTimeZone timeZoneWithAbbreviation:@"CEST"];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:1483225200]; // 2017-01-01 01:00 local time (Sunday)
    [self.scheduleValidator setTimeZone:cet];
    [given([self.dateManager currentDate]) willReturn:newDate];
    
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    NSTimeZone *pdt = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    newDate = [NSDate dateWithTimeIntervalSince1970:1483322400]; // 2017-01-01 19:00 local time (Sunday)
    [self.scheduleValidator setTimeZone:pdt];
    [given([self.dateManager currentDate]) willReturn:newDate];
    
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testScheduledDayTimeZone {
    self.testRecipe.scheduling = @{@"days" : @[ @"sun", @"fri" ]};
    
    NSTimeZone *cet = [NSTimeZone timeZoneWithAbbreviation:@"CEST"];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:1483225200]; // 2017-01-01 01:00 local time (Sunday)
    [self.scheduleValidator setTimeZone:cet];
    [given([self.dateManager currentDate]) willReturn:newDate];
    
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    NSTimeZone *pdt = [NSTimeZone timeZoneWithAbbreviation:@"PDT"];
    newDate = [NSDate dateWithTimeIntervalSince1970:1483322400]; // 2017-01-01 19:00 local time (Sunday)
    [self.scheduleValidator setTimeZone:pdt];
    [given([self.dateManager currentDate]) willReturn:newDate];
    
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}

- (void)testRecipeIsScheduledATimeOfDay {
    // when a recipe is scheduled for this time of day
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorianCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:2000];
    [components setHour:8];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startTime = [gregorianCalendar dateFromComponents:components];
    [components setHour:20];
    NSDate *endTime = [gregorianCalendar dateFromComponents:components];
    self.testRecipe.scheduling = [self buildSchedulingWithStartDate:nil endDate:nil startTime:startTime endTime:endTime];
    
    // then is valid during the period
    [given([self.dateManager currentDate]) willReturn:startTime];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:endTime];
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:[startTime dateByAddingTimeInterval:60 * 60 * 3]]; // +3 hours
    XCTAssertTrue([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    
    // then is not valid outside of the period
    [given([self.dateManager currentDate]) willReturn:[startTime dateByAddingTimeInterval:-1]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:[endTime dateByAddingTimeInterval:1]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:[startTime dateByAddingTimeInterval:-1 * 60 * 60]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
    [given([self.dateManager currentDate]) willReturn:[endTime dateByAddingTimeInterval:60 * 60]];
    XCTAssertFalse([self.scheduleValidator isValidWithRecipe:self.testRecipe]);
}
 
*/

// MARK: - Utility

- (NSDictionary<NSString*, id>*)buildSchedulingWithStartDate:(NSDate*)startDate endDate:(NSDate*)endDate startTime:(NSDate*)startTime endTime:(NSDate*)endTime {
    NSMutableDictionary<NSString*, id> *scheduling = [[NSMutableDictionary alloc] init];
    if (startDate || endDate) {
        [scheduling setObject:[self buildSchedulingBlockForDateWithStart:startDate end:endDate] forKey:@"date"];
    }
    if (startTime || endTime) {
        [scheduling setObject:[self buildSchedulingBlockForTimeWithStart:startTime end:endTime] forKey:@"timetable"];
    }
    return [NSDictionary dictionaryWithDictionary:scheduling];
}

- (NSDictionary<NSString*, id>*)buildSchedulingBlockForDateWithStart:(NSDate*)start end:(NSDate*)end {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSMutableDictionary<NSString*, id> *date = [[NSMutableDictionary alloc] init];
    if (start) {
        [date setObject:[dateFormatter stringFromDate:start] forKey:@"from"];
    }
    if (end) {
        [date setObject:[dateFormatter stringFromDate:end] forKey:@"to"];
    }
    
    return [NSDictionary dictionaryWithDictionary:date];
}

- (NSDictionary<NSString*, id>*)buildSchedulingBlockForTimeWithStart:(NSDate*)start end:(NSDate*)end {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    dateFormatter.dateFormat = @"HH:mm";
    NSMutableDictionary<NSString*, id> *timetable = [[NSMutableDictionary alloc] init];
    if (start) {
        [timetable setObject:[dateFormatter stringFromDate:start] forKey:@"from"];
    }
    if (end) {
        [timetable setObject:[dateFormatter stringFromDate:end] forKey:@"to"];
    }
    return [NSDictionary dictionaryWithDictionary:timetable];
}

@end
