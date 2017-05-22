//
//  NITRecipe.m
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipe.h"
#import "NITUtils.h"

NSString* const NITRecipeNotified = @"notified";
NSString* const NITRecipeEngaged = @"engaged";

@implementation NITRecipe

- (NSDictionary *)attributesMap {
    return @{ @"pulse_plugin_id" : @"pulsePluginId",
              @"pulse_bundle" : @"pulseBundle",
              @"pulse_action" : @"pulseAction",
              @"reaction_plugin_id" : @"reactionPluginId",
              @"reaction_action" : @"reactionAction",
              @"reaction_bundle" : @"reactionBundle",
              @"reaction_bundle_id" : @"reactionBundleId" };
}

- (BOOL)isEvaluatedOnline {
    id online = [self.labels objectForKey:@"online"];
    if(online != nil && [online isKindOfClass:[NSNumber class]]) {
        NSNumber *onlineBool = (NSNumber*)online;
        return [onlineBool boolValue];
    }
    return NO;
}

-(BOOL)isForeground {
    NSString *eventFar = [NITUtils stringFromRegionEvent:NITRegionEventFar];
    NSString *eventNear = [NITUtils stringFromRegionEvent:NITRegionEventNear];
    NSString *eventImmediate = [NITUtils stringFromRegionEvent:NITRegionEventImmediate];
    if ([self.pulseAction.ID isEqualToString:eventFar] || [self.pulseAction.ID isEqualToString:eventNear] || [self.pulseAction.ID isEqualToString:eventImmediate]) {
        return YES;
    }
    return NO;
}

- (NSString *)notificationTitle {
    id title = [self.notification objectForKey:@"title"];
    if (title && [title isKindOfClass:[NSString class]]) {
        return (NSString*)title;
    }
    return nil;
}

- (NSString *)notificationBody {
    id body = [self.notification objectForKey:@"body"];
    if (body && [body isKindOfClass:[NSString class]]) {
        return (NSString*)body;
    }
    return nil;
}

- (BOOL)isScheduledNow:(NSDate*)now {
    return (self.scheduling == nil || [self.scheduling isEqual:[NSNull null]]) || ([self isDateValid:now] && [self isTimetableValid:now] && [self isDaysValid:now]);
}

- (BOOL)isDateValid:(NSDate*)now {
    BOOL valid = YES;
    NSDictionary<NSString*, id> *date = [self.scheduling objectForKey:@"date"];
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

- (BOOL)isTimetableValid:(NSDate*)now {
    NSDictionary<NSString*, id> *timetable = [self.scheduling objectForKey:@"timetable"];
    if (timetable == nil || [timetable isEqual:[NSNull null]]) {
        return YES;
    }
    BOOL valid = YES;
    
    NSString *fromHour = [timetable objectForKey:@"from"];
    NSString *toHour = [timetable objectForKey:@"to"];
    
    if (fromHour != nil && ![fromHour isEqual:[NSNull null]]) {
        valid &= [self isGreaterOrEqualHMSWithHour:[self hourComponentsWithDate:now] referenceHour:[self hourComponentsWithString:fromHour]];
    }
    if (toHour != nil && ![toHour isEqual:[NSNull null]]) {
        valid &= [self isGreaterOrEqualHMSWithHour:[self hourComponentsWithString:toHour] referenceHour:[self hourComponentsWithDate:now]];
    }
    
    return valid;
}

- (BOOL)isDaysValid:(NSDate*)now {
    NSArray<NSString*> *days = [self.scheduling objectForKey:@"days"];
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

// MARK: - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.notification = [aDecoder decodeObjectForKey:@"notification"];
        self.labels = [aDecoder decodeObjectForKey:@"labels"];
        self.scheduling = [aDecoder decodeObjectForKey:@"scheduling"];
        self.cooldown = [aDecoder decodeObjectForKey:@"cooldown"];
        self.pulsePluginId = [aDecoder decodeObjectForKey:@"pulsePluginId"];
        self.reactionPluginId = [aDecoder decodeObjectForKey:@"reactionPluginId"];
        self.reactionBundleId = [aDecoder decodeObjectForKey:@"reactionBundleId"];
        self.pulseBundle = [aDecoder decodeObjectForKey:@"pulseBundle"];
        self.pulseAction = [aDecoder decodeObjectForKey:@"pulseAction"];
        self.reactionAction = [aDecoder decodeObjectForKey:@"reactionAction"];
        self.reactionBundle = [aDecoder decodeObjectForKey:@"reactionBundle"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.notification forKey:@"notification"];
    [aCoder encodeObject:self.labels forKey:@"labels"];
    [aCoder encodeObject:self.scheduling forKey:@"scheduling"];
    [aCoder encodeObject:self.cooldown forKey:@"cooldown"];
    [aCoder encodeObject:self.pulsePluginId forKey:@"pulsePluginId"];
    [aCoder encodeObject:self.reactionPluginId forKey:@"reactionPluginId"];
    [aCoder encodeObject:self.reactionBundleId forKey:@"reactionBundleId"];
    [aCoder encodeObject:self.pulseBundle forKey:@"pulseBundle"];
    [aCoder encodeObject:self.pulseAction forKey:@"pulseAction"];
    [aCoder encodeObject:self.reactionAction forKey:@"reactionAction"];
    [aCoder encodeObject:self.reactionBundle forKey:@"reactionBundle"];
}

@end
