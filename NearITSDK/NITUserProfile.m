//
//  NITUserProfile.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITUserProfile.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITConfiguration.h"
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"
#import "NITConstants.h"
#import "NITInstallation.h"

@implementation NITUserProfile

+ (void)createNewProfileWithCompletionHandler:(void (^)(NSString *profileId, NSError *error))handler {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NITNetworkManager *network = [[NITNetworkManager alloc] init];
    [network makeRequestWithURLRequest:[NITNetworkProvider newProfileWithAppId:config.appId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if(error) {
            if (handler) {
                handler(nil, error);
            }
        } else {
            NITJSONAPIResource *resource = [json firstResourceObject];
            if (resource.ID) {
                config.profileId = resource.ID;
                if (handler) {
                    [[NITInstallation sharedInstance] registerInstallationWithCompletionHandler:nil];
                    handler(resource.ID, nil);
                }
            } else {
                NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey : @"No valid resource object found"}];
                if (handler) {
                    handler(nil, newError);
                }
            }
        }
    }];
}

+ (void)setUserDataWithKey:(NSString*)key value:(NSString*)value completionHandler:(void (^)(NSError* error))handler {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    if (config.profileId == nil) {
        [NITUserProfile createNewProfileWithCompletionHandler:nil];
        if (handler) {
            NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:3 userInfo:@{NSLocalizedDescriptionKey : @"Profile not found"}];
            handler(newError);
        }
        return;
    }
    
    NSDictionary *attributes = @{ @"key" : key, @"value" : value };
    NITJSONAPI *jsonApi = [NITJSONAPI jsonApiWithAttributes:attributes type:@"data_points"];
    NITNetworkManager *network = [[NITNetworkManager alloc] init];
    [network makeRequestWithURLRequest:[NITNetworkProvider setUserDataWithJsonApi:jsonApi profileId:config.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            if (handler) {
                NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:4 userInfo:@{NSLocalizedDescriptionKey : @"Data point error", NSUnderlyingErrorKey:error}];
                handler(newError);
            }
        } else {
            if (handler) {
                handler(nil);
            }
        }
    }];
}

+ (void)setBatchUserDataWithDictionary:(NSDictionary<NSString*, id>*)valuesDictiornary completionHandler:(void (^)(NSError* error))handler {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    if (config.profileId == nil) {
        [NITUserProfile createNewProfileWithCompletionHandler:nil];
        if (handler) {
            NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:3 userInfo:@{NSLocalizedDescriptionKey : @"Profile not found"}];
            handler(newError);
        }
        return;
    }
    
    NSMutableArray *resources = [[NSMutableArray alloc] init];
    for (NSString *key in valuesDictiornary) {
        NSDictionary *resourceObj = @{ @"key" : key, @"value" : [valuesDictiornary objectForKey:key]};
        [resources addObject:resourceObj];
    }
    
    NITJSONAPI *jsonApi = [NITJSONAPI jsonApiWithArray:resources type:@"data_points"];
    NITNetworkManager *network = [[NITNetworkManager alloc] init];
    [network makeRequestWithURLRequest:[NITNetworkProvider setUserDataWithJsonApi:jsonApi profileId:config.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            if (handler) {
                NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:4 userInfo:@{NSLocalizedDescriptionKey : @"Data point error", NSUnderlyingErrorKey:error}];
                handler(newError);
            }
        } else {
            if (handler) {
                handler(nil);
            }
        }
    }];
}

+ (void)resetProfile {
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    config.profileId = nil;
    [[NITInstallation sharedInstance] registerInstallationWithCompletionHandler:nil];
}

@end
