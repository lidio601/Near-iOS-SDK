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

@interface NITScheduleValidator()

@property (nonatomic, strong) NITDateManager *dateManager;

@end

@implementation NITScheduleValidator

- (instancetype)initWithDateManager:(NITDateManager *)dateManager {
    if (self) {
        self.dateManager = dateManager;
    }
    return self;
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
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    id from = [date objectForKey:@"from"];
    id to = [date objectForKey:@"to"];
    
    if (from != nil && ![from isEqual:[NSNull null]]) {
        NSDate *fromDate = [dateFormatter dateFromString:from];
        valid &= [self isGreaterOrEqualDMYWithFromDate:now referenceDate:fromDate];
    }
    if (to != nil && ![to isEqual:[NSNull null]]) {
        NSDate *toDate = [dateFormatter dateFromString:to];
        valid &= [self isGreaterOrEqualDMYWithFromDate:toDate referenceDate:now];
    }
    
    return valid;
}

- (BOOL)isTimetableValidWithScheduling:(NSDictionary<NSString*, id>*)scheduling date:(NSDate*)now {
    NSDictionary<NSString*, id> *timetable = [scheduling objectForKey:@"timetable"];
    if (timetable == nil || [timetable isEqual:[NSNull null]]) {
        return YES;
    }
    BOOL valid = YES;
    
    NSString *fromHour = [timetable objectForKey:@"from"];
    NSString *toHour = [timetable objectForKey:@"to"];
    
    if (fromHour != nil && ![fromHour isEqual:[NSNull null]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *fromHourDate = [dateFormatter dateFromString:fromHour];
        fromHourDate = [fromHourDate dateByAddingTimeInterval:-1 * [NSTimeZone localTimeZone].daylightSavingTimeOffset];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSString *newFromHour = [dateFormatter stringFromDate:fromHourDate];
        
        valid &= [self isGreaterOrEqualHMSWithHour:[self hourComponentsWithDate:now] referenceHour:[self hourComponentsWithString:newFromHour]];
    }
    if (toHour != nil && ![toHour isEqual:[NSNull null]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        dateFormatter.dateFormat = @"HH:mm:ss";
        NSDate *toHourDate = [dateFormatter dateFromString:toHour];
        toHourDate = [toHourDate dateByAddingTimeInterval:-1 * [NSTimeZone localTimeZone].daylightSavingTimeOffset];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        NSString *newToHour = [dateFormatter stringFromDate:toHourDate];
        
        valid &= [self isGreaterOrEqualHMSWithHour:[self hourComponentsWithString:newToHour] referenceHour:[self hourComponentsWithDate:now]];
    }
    
    return valid;
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
    NSDateComponents *nowComponents = [calendar components:NSCalendarUnitWeekday fromDate:now];
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

- (BOOL)isGreaterOrEqualDMYWithFromDate:(NSDate*)fromDate referenceDate:(NSDate*)refDate {
    BOOL valid = YES;
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents *fromComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fromDate];
    NSDateComponents *refComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:refDate];
    if (fromComponents.year == refComponents.year) {
        if (fromComponents.month == refComponents.month) {
            if (fromComponents.day >= refComponents.day) {
                valid &= YES;
            } else {
                valid &= NO;
            }
        } else if (fromComponents.month > refComponents.month) {
            valid &= YES;
        } else {
            valid &= NO;
        }
    } else if (fromComponents.year > refComponents.year) {
        valid &= YES;
    } else {
        valid &= NO;
    }
    return valid;
}

- (BOOL)isGreaterOrEqualHMSWithHour:(NSDateComponents*)hour referenceHour:(NSDateComponents*)refHour {
    BOOL valid = YES;
    if (hour.hour == refHour.hour) {
        if (hour.minute == refHour.minute) {
            if (hour.second >= refHour.second) {
                valid &= YES;
            } else {
                valid &= NO;
            }
        } else if (hour.minute > refHour.minute) {
            valid &= YES;
        } else {
            valid &= NO;
        }
    } else if (hour.hour > refHour.hour) {
        valid &= YES;
    } else {
        valid &= NO;
    }
    return valid;
}

- (NSDateComponents*)hourComponentsWithDate:(NSDate*)now {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:now];
}

- (NSDateComponents*)hourComponentsWithString:(NSString*)hour {
    NSDateComponents *hourComponents = [[NSDateComponents alloc] init];
    hourComponents.hour = 0;
    hourComponents.minute = 0;
    hourComponents.second = 0;
    NSArray<NSString*> *items = [hour componentsSeparatedByString:@":"];
    if ([items count] >= 1) {
        hourComponents.hour = [[items objectAtIndex:0] integerValue];
    }
    if ([items count] >= 2) {
        hourComponents.minute = [[items objectAtIndex:1] integerValue];
    }
    if ([items count] >= 3) {
        hourComponents.second = [[items objectAtIndex:2] integerValue];
    }
    
    return hourComponents;
}

@end
