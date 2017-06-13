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

@interface NITSchedulerValidatorTest : NITTestCase

@property (nonatomic, strong) NITScheduleValidator *scheduleValidator;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITRecipe *testRecipe;

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
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSchedulingIsMissing {
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

- (void)testRecipeIsScheduledATimeOfDay {
    // when a recipe is scheduled for this time of day
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
    dateFormatter.dateFormat = @"HH:mm:ss";
    NSMutableDictionary<NSString*, id> *timetable = [[NSMutableDictionary alloc] init];
    if (start) {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *startTime = [dateFormatter stringFromDate:start];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSDate *newStartTime = [dateFormatter dateFromString:startTime];
        [timetable setObject:[dateFormatter stringFromDate:newStartTime] forKey:@"from"];
    }
    if (end) {
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *endTime = [dateFormatter stringFromDate:end];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSDate *newEndTime = [dateFormatter dateFromString:endTime];
        [timetable setObject:[dateFormatter stringFromDate:newEndTime] forKey:@"to"];
    }
    return [NSDictionary dictionaryWithDictionary:timetable];
}

@end
