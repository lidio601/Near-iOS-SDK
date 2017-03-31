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
    
    id from = [date objectForKey:@"from"];
    id to = [date objectForKey:@"to"];
    
    // FIXME: Check hours, seconds between date
    
    if (from != nil && ![from isEqual:[NSNull null]]) {
        NSDate *fromDate = [dateFormatter dateFromString:from];
        NSComparisonResult result = [fromDate compare:now];
        if(result == NSOrderedSame || result == NSOrderedAscending) {
            valid &= YES;
        } else {
            valid &= NO;
        }
    }
    if (to != nil && ![to isEqual:[NSNull null]]) {
        NSDate *toDate = [dateFormatter dateFromString:to];
        NSComparisonResult result = [toDate compare:now];
        if(result == NSOrderedSame || result == NSOrderedDescending) {
            valid &= YES;
        } else {
            valid &= NO;
        }
    }
    
    return valid;
}

@end
