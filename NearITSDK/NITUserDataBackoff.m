//
//  NITUserDataBackoff.m
//  NearITSDK
//
//  Created by Francesco Leoni on 11/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITUserDataBackoff.h"
#import "NITConfiguration.h"
#import "NITCacheManager.h"
#import "NITJSONAPI.h"
#import "NITNetworkProvider.h"
#import "NITLog.h"

#define LOGTAG @"UserDataBackoff"
NSString* const UserDataBackoffCacheKey = @"UserDataBackoff";

@interface NITUserDataBackoff()

@property (nonatomic, strong) NITConfiguration *configuration;
@property (nonatomic, strong) id<NITNetworkManaging> networkManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NSMutableDictionary *userData;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) BOOL isQueued;
@property (nonatomic) BOOL hasTimer;

@end

@implementation NITUserDataBackoff

- (instancetype)initWithConfiguration:(NITConfiguration *)configuration networkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager * _Nonnull)cacheManager {
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.networkManager = networkManager;
        self.cacheManager = cacheManager;
        self.isBusy = NO;
        self.isQueued = NO;
        self.hasTimer = NO;
        NSDictionary *cachedUserData = [self.cacheManager loadDictionaryForKey:UserDataBackoffCacheKey];
        if (cachedUserData) {
            self.userData = [[NSMutableDictionary alloc] initWithDictionary:cachedUserData];
        } else {
            self.userData = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)setUserDataWithKey:(NSString *)key value:(NSString *)value {
    if (!self.hasTimer) {
        self.hasTimer = YES;
        [self performSelector:@selector(startSend) withObject:nil afterDelay:2.0];
    }
    
    self.isQueued = YES;
    [self.userData setObject:value forKey:key];
    [self.cacheManager saveWithObject:self.userData forKey:UserDataBackoffCacheKey];
}

- (void)startSend {
    [self shouldSendDataPoints];
    self.hasTimer = NO;
}

- (void)sendDataPoints {
    if (self.configuration.profileId == nil) {
        return;
    }
    if (self.isBusy) {
        return;
    }
    
    self.isBusy = YES;
    self.isQueued = NO;
    
    NSMutableArray *resources = [[NSMutableArray alloc] init];
    NSDictionary *userDataCopy = [self.userData copy];
    for (NSString *key in userDataCopy) {
        NSDictionary *resourceObj = @{ @"key" : key, @"value" : [userDataCopy objectForKey:key]};
        [resources addObject:resourceObj];
    }
    
    NITJSONAPI *jsonApi = [NITJSONAPI jsonApiWithArray:resources type:@"data_points"];
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] setUserDataWithJsonApi:jsonApi profileId:self.configuration.profileId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            NITLogW(LOGTAG, @"Send user data failure");
            self.isQueued = YES;
            if ([self.delegate respondsToSelector:@selector(userDataBackoffDidFailed:withError:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate userDataBackoffDidFailed:self withError:error];
                }];
            }
        } else {
            NITLogI(LOGTAG, @"Send user data success");
            for(NSString *key in userDataCopy.allKeys) {
                [self.userData removeObjectForKey:key];
            }
            if ([self.delegate respondsToSelector:@selector(userDataBackoffDidComplete:)]) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate userDataBackoffDidComplete:self];
                }];
            }
        }
        self.isBusy = NO;
    }];
}

- (void)shouldSendDataPoints {
    if (self.isQueued) {
        [self sendDataPoints];
    }
}

@end
