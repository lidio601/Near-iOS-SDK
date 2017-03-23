//
//  NITRecipe.m
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITRecipe.h"

@implementation NITRecipe

- (NSDictionary *)attributesMap {
    return @{ @"pulse_plugin_id" : @"pulsePluginId",
              @"pulse_bundle" : @"pulseBundle",
              @"pulse_action" : @"pulseAction"};
}

- (BOOL)isEvaluatedOnline {
    id online = [self.labels objectForKey:@"online"];
    if(online != nil && [online isKindOfClass:[NSNumber class]]) {
        NSNumber *onlineBool = (NSNumber*)online;
        return [onlineBool boolValue];
    }
    return NO;
}

@end
