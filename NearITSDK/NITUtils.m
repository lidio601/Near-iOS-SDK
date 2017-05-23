//
//  NITUTils.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITUtils.h"

/// Utils for SDK
@implementation NITUtils

/**
* Fetch AppId from the ApiKey
* @param apiKey ApiKey provided by NearIt
* @return AppId decoded
*/
+ (NSString *)fetchAppIdFromApiKey:(NSString *)apiKey {
    NSArray<NSString*> *components = [apiKey componentsSeparatedByString:@"."];
    
    NSString *payload = [components objectAtIndex:1];
    
    NSInteger module = [payload length] % 4;
    if (module != 0) {
        while((4 - module) != 0) {
            payload = [payload stringByAppendingString:@"="];
            module++;
        }
    }
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:payload options:0];
    if (data == nil) {
        return @"";
    }
    
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    if (json) {
        NSDictionary *data = [json objectForKey:@"data"];
        NSDictionary *account = [data objectForKey:@"account"];
        NSString *appId = [account objectForKey:@"id"];
        if (appId) {
            return appId;
        }
    }
    return @"";
}

+ (NSString*)stringFromRegionEvent:(NITRegionEvent)event {
    switch (event) {
        case NITRegionEventEnterPlace:
            return @"enter_place";
        case NITRegionEventLeavePlace:
            return @"leave_place";
        case NITRegionEventEnterArea:
            return @"enter_area";
        case NITRegionEventLeaveArea:
            return @"leave_area";
        case NITRegionEventImmediate:
            return @"ranging.immediate";
        case NITRegionEventNear:
            return @"ranging.near";
        case NITRegionEventFar:
            return @"ranging.far";
        default:
            return @"";
    }
}

+ (NSString *)stringFromBluetoothState:(CBManagerState)state {
    switch (state) {
        case CBManagerStatePoweredOn:
            return @"PoweredOn";
            break;
            
        case CBManagerStatePoweredOff:
            return @"PoweredOff";
            break;
            
        default:
            return @"Undefined";
            break;
    }
}

@end
