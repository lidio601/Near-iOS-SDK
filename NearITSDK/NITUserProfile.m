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

@interface NITUserProfile()

@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) NITNetworkManager *networkManager;

@end

@implementation NITUserProfile

- (instancetype)initWithConfiguration:(NITConfiguration *)configuration networkManager:(id<NITNetworkManaging>)networkManager installation:(NITInstallation*)installation {
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.networkManager = networkManager;
        self.installation = installation;
    }
    return self;
}

- (void)createNewProfileWithCompletionHandler:(void (^)(NSString *profileId, NSError *error))handler {
    if (self.configuration.profileId) {
        if (handler) {
            handler(self.configuration.profileId, nil);
        }
        return;
    }
    
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] newProfileWithAppId:self.configuration.appId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if(error) {
            if (handler) {
                handler(nil, error);
            }
        } else {
            NITJSONAPIResource *resource = [json firstResourceObject];
            if (resource.ID) {
                self.configuration.profileId = resource.ID;
                if (handler) {
                    [self.installation registerInstallation];
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

- (void)setUserDataWithKey:(NSString*)key value:(NSString*)value completionHandler:(void (^)(NSError* error))handler {
    if (self.configuration.profileId == nil) {
        [self createNewProfileWithCompletionHandler:nil];
        if (handler) {
            NSError *newError = [[NSError alloc] initWithDomain:NITUserProfileErrorDomain code:3 userInfo:@{NSLocalizedDescriptionKey : @"Profile not found"}];
            handler(newError);
        }
        return;
    }
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:key forKey:@"key"];
    if (value) {
        [attributes setObject:value forKey:@"value"];
    } else {
        [attributes setObject:[NSNull null] forKey:@"value"];
    }
    NITJSONAPI *jsonApi = [NITJSONAPI jsonApiWithAttributes:attributes type:@"data_points"];
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] setUserDataWithJsonApi:jsonApi profileId:self.configuration.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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

- (void)setBatchUserDataWithDictionary:(NSDictionary<NSString*, id>*)valuesDictiornary completionHandler:(void (^)(NSError* error))handler {
    if (self.configuration.profileId == nil) {
        [self createNewProfileWithCompletionHandler:nil];
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
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] setUserDataWithJsonApi:jsonApi profileId:self.configuration.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
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

- (void)resetProfile {
    self.configuration.profileId = nil;
    [self.installation registerInstallation];
}

- (void)setProfileId:(NSString *)profileId {
    self.configuration.profileId = profileId;
    [self.installation registerInstallation];
}

@end
