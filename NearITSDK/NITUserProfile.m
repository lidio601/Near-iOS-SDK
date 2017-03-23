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
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider newProfileWithAppId:config.appId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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

@end
