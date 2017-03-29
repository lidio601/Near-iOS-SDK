//
//  NITInstallation.m
//  NearITSDK
//
//  Created by Francesco Leoni on 23/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITInstallation.h"
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITConfiguration.h"
#import "NITConstants.h"

static NITInstallation *sharedInstallation;

@implementation NITInstallation

+ (NITInstallation *)sharedInstance {
    if (sharedInstallation == nil) {
        sharedInstallation = [NITInstallation new];
    }
    return sharedInstallation;
}

- (void)registerInstallationWithCompletionHandler:(void (^)(NSString * _Nullable installationId, NSError * _Nullable error))handler {
    
    NSString *realInstallationId = [[self configuration] installationId];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    
    [jsonApi setDataWithResourceObject:[self installationResourceWithInstallationId:realInstallationId]];
    
    if (realInstallationId) {
        [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider updateInstallationWithJsonApi:jsonApi installationId:realInstallationId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
            [self handleResponseWithJsonApi:json error:error completionHandler:^(NSString * _Nullable installationId, NSError * _Nullable error) {
                if (handler) {
                    handler(installationId, error);
                }
            }];
        }];
    } else {
        [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider newInstallationWithJsonApi:jsonApi] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
            [self handleResponseWithJsonApi:json error:error completionHandler:^(NSString * _Nullable installationId, NSError * _Nullable error) {
                if (handler) {
                    handler(installationId, error);
                }
            }];
        }];
    }
}

- (NITJSONAPIResource*)installationResourceWithInstallationId:(NSString*)installationId {
    NITConfiguration *config = [self configuration];
    
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    if(installationId) {
        resource.ID = installationId;
    } else {
        resource.ID = @"";
    }
    resource.type = @"installations";
    [resource addAttributeObject:@"ios" forKey:@"platform"];
    NSOperatingSystemVersion opVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
    [resource addAttributeObject:[NSString stringWithFormat:@"%ld.%ld", (long)opVersion.majorVersion, (long)opVersion.minorVersion] forKey:@"platform_version"];
    [resource addAttributeObject:@"0.1.0" forKey:@"sdk_version"];
    [resource addAttributeObject:config.appId forKey:@"app_id"];
    [resource addAttributeObject:config.profileId forKey:@"profile_id"];
    if (config.deviceToken) {
        [resource addAttributeObject:config.deviceToken forKey:@"device_identifier"];
    }
    
    // FIXME: Check real status
    [resource addAttributeObject:[NSNumber numberWithBool:NO] forKey:@"bluetooth"];
    [resource addAttributeObject:[NSNumber numberWithBool:NO] forKey:@"location"];
    
    return resource;
}

- (void)handleResponseWithJsonApi:(NITJSONAPI*)json error:(NSError*)error completionHandler:(void (^)(NSString * _Nullable installationId, NSError * _Nullable error))handler {
    NITConfiguration *config = [self configuration];
    if(error) {
        if(handler) {
            handler(nil, error);
        }
    } else {
        NITJSONAPIResource *resource = [json firstResourceObject];
        if (resource.ID) {
            if (handler) {
                config.installationId = resource.ID;
                handler(resource.ID, nil);
            }
        } else {
            NSError *newError = [[NSError alloc] initWithDomain:NITInstallationErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey:@"Invalid installation found"}];
            handler(nil, newError);
        }
    }
}

- (NITConfiguration*)configuration {
    return [NITConfiguration defaultConfiguration];
}

@end