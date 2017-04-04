//
//  NITRecipe.m
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipe.h"
#import "NITUtils.h"

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
    // TODO: Timetable and Day valid
    return (self.scheduling == nil || [self.scheduling isEqual:[NSNull null]]) || ([self isDateValid:now]);
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
        valid &= [self isGreatherOrEqualDMYWithFromDate:now referenceDate:fromDate];
    }
    if (to != nil && ![to isEqual:[NSNull null]]) {
        NSDate *toDate = [dateFormatter dateFromString:to];
        valid &= [self isGreatherOrEqualDMYWithFromDate:toDate referenceDate:now];
    }
    
    return valid;
}

- (BOOL)isGreatherOrEqualDMYWithFromDate:(NSDate*)fromDate referenceDate:(NSDate*)refDate {
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
