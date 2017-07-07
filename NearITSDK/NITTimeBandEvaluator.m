//
//  NITTimeBandEvaluator.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTimeBandEvaluator.h"
#import "NITDateManager.h"

@interface NITTimeBandEvaluator()

@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NSTimeZone *timeZone;

@end

@implementation NITTimeBandEvaluator

- (instancetype)initWithDateManager:(NITDateManager *)dateManager {
    self = [super init];
    if (self) {
        self.dateManager = dateManager;
        self.timeZone = [NSTimeZone localTimeZone];
    }
    return self;
}

- (BOOL)isInTimeBandWithFromHour:(NSString*)fromHour toHour:(NSString*)toHour {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:self.timeZone];
    NSDate *now = [self.dateManager currentDate];
    NSDateComponents *nowComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    
    BOOL valid = YES;
    if (fromHour) {
        NSDate *fromDate = [self dateWithHour:fromHour referenceDateComponents:nowComponents calendar:calendar];
        NSComparisonResult fromResult = [fromDate compare:now];
        if (fromResult == NSOrderedAscending || fromResult == NSOrderedSame) {
            valid &= YES;
        } else {
            valid = NO;
        }
    }
    
    if (toHour) {
        NSDate *toDate = [self dateWithHour:toHour referenceDateComponents:nowComponents calendar:calendar];
        NSComparisonResult toResult = [toDate compare:now];
        if (toResult == NSOrderedDescending || toResult == NSOrderedSame) {
            valid &= YES;
        } else {
            valid = NO;
        }
    }
    
    return valid;
}

- (NSDate*)dateWithHour:(NSString*)hour referenceDateComponents:(NSDateComponents*)reference calendar:(NSCalendar*)calendar {
    NSDateComponents *newComponents = [[NSDateComponents alloc] init];
    [newComponents setDay:reference.day];
    [newComponents setMonth:reference.month];
    [newComponents setYear:reference.year];
    [newComponents setSecond:0];
    
    NSArray<NSString*> *split = [hour componentsSeparatedByString:@":"];
    if ([split count] >= 2) {
        NSString *hourSplit = [split objectAtIndex:0];
        NSString *minutesSplit = [split objectAtIndex:1];
        [newComponents setHour:[hourSplit integerValue]];
        [newComponents setMinute:[minutesSplit integerValue]];
        if ([split count] > 2) {
            NSString *secondsSplit = [split objectAtIndex:2];
            [newComponents setSecond:[secondsSplit integerValue]];
        }
    }
    
    return [calendar dateFromComponents:newComponents];
}

@end
