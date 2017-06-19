//
//  NITScheduleValidator.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITScheduleValidator.h"
#import "NITDateManager.h"
#import "NITRecipe.h"
#import "NITTimeBandEvaluator.h"

@interface NITScheduleValidator()

@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITTimeBandEvaluator *timeBandEvaluator;
@property (nonatomic, strong) NSTimeZone *timeZone;

@end

@implementation NITScheduleValidator

@synthesize timeZone = _timeZone;

- (instancetype)initWithDateManager:(NITDateManager *)dateManager {
    if (self) {
        self.dateManager = dateManager;
        self.timeBandEvaluator = [[NITTimeBandEvaluator alloc] initWithDateManager:dateManager];
        self.timeZone = [NSTimeZone localTimeZone];
    }
    return self;
}

- (void)setTimeZone:(NSTimeZone *)timeZone {
    _timeZone = timeZone;
    [self.timeBandEvaluator setTimeZone:timeZone];
}

- (BOOL)isValidWithRecipe:(NITRecipe *)recipe {
    NSDate *now = [self.dateManager currentDate];
    NSDictionary<NSString*, id> *scheduling = recipe.scheduling;
    return scheduling == nil || ([self isDateValidWithScheduling:scheduling date:now] && [self isTimetableValidWithScheduling:scheduling date:now] && [self isDaysValidWithScheduling:scheduling date:now]);
}

- (BOOL)isDateValidWithScheduling:(NSDictionary<NSString*, id>*)scheduling date:(NSDate*)now {
    BOOL valid = YES;
    NSDictionary<NSString*, id> *date = [scheduling objectForKey:@"date"];
    if(date == nil || [date isEqual:[NSNull null]]) {
        return YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSDate *checkDate = [now dateByAddingTimeInterval:self.timeZone.secondsFromGMT];
    id from = [date objectForKey:@"from"];
    id to = [date objectForKey:@"to"];
    
    if (from != nil && ![from isEqual:[NSNull null]]) {
        NSDate *fromDate = [dateFormatter dateFromString:[from stringByAppendingString:@" 00:00:00"]];
        NSComparisonResult fromResult = [fromDate compare:checkDate];
        if (fromResult == NSOrderedAscending || fromResult == NSOrderedSame) {
            valid &= YES;
        } else {
            valid = NO;
        }
    }
    
    if (to != nil && ![to isEqual:[NSNull null]]) {
        NSDate *toDate = [dateFormatter dateFromString:[to stringByAppendingString:@" 23:59:59"]];
        NSComparisonResult toResult = [toDate compare:checkDate];
        if (toResult == NSOrderedDescending || toResult == NSOrderedSame) {
            valid &= YES;
        } else {
            valid = NO;
        }
    }
    
    return valid;
}

- (BOOL)isTimetableValidWithScheduling:(NSDictionary<NSString*, id>*)scheduling date:(NSDate*)now {
    NSDictionary<NSString*, id> *timetable = [scheduling objectForKey:@"timetable"];
    if (timetable == nil || [timetable isEqual:[NSNull null]]) {
        return YES;
    }
    
    NSString *fromHour = [timetable objectForKey:@"from"];
    NSString *toHour = [timetable objectForKey:@"to"];
    
    return [self.timeBandEvaluator isInTimeBandWithFromHour:fromHour toHour:toHour];
}

- (BOOL)isDaysValidWithScheduling:(NSDictionary<NSString*, id>*)scheduling date:(NSDate*)now {
    NSArray<NSString*> *days = [scheduling objectForKey:@"days"];
    NSMutableArray<NSString*> *lowercaseDays = [[NSMutableArray alloc] initWithCapacity:[days count]];
    for(NSString *day in days) {
        [lowercaseDays addObject:[day lowercaseString]];
    }
    if (days == nil || [days isEqual:[NSNull null]]) {
        return YES;
    }
    NSString *dayName = [self nameOfDay:now];
    if ([lowercaseDays containsObject:dayName]) {
        return YES;
    }
    
    return NO;
}

// MARK: - Utility

- (NSString*)nameOfDay:(NSDate*)now {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *checkDate = [now dateByAddingTimeInterval:self.timeZone.secondsFromGMT];
    NSDateComponents *nowComponents = [calendar components:NSCalendarUnitWeekday fromDate:checkDate];
    switch (nowComponents.weekday) {
        case 1:
            return @"sun";
            break;
        case 2:
            return @"mon";
            break;
        case 3:
            return @"tue";
            break;
        case 4:
            return @"wed";
            break;
        case 5:
            return @"thu";
            break;
        case 6:
            return @"fri";
            break;
        case 7:
            return @"sat";
            break;
            
        default:
            return @"";
            break;
    }
}

@end
