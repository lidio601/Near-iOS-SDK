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
              @"reaction_plugin_id" : @"reactionPluginId"};
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

@end
