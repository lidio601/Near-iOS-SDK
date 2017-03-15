//
//  NITConfiguration.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITConfiguration.h"

#define APIKEY @"apikey"
#define APPID @"appid"

static NITConfiguration *defaultConfiguration;

@interface NITConfiguration()

@property (nonatomic, strong) NSString * _Nonnull apiKey;
@property (nonatomic, strong) NSString * _Nonnull appId;

@end

@implementation NITConfiguration

@synthesize apiKey = _apiKey;
@synthesize appId = _appId;

+ (NITConfiguration * _Nonnull)defaultConfiguration {
    if (defaultConfiguration == nil) {
        defaultConfiguration = [NITConfiguration new];
    }
    return defaultConfiguration;
}

- (NSString *)apiKey {
    if (self.apiKey == nil) {
        self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:APIKEY];
    }
    return self.apiKey;
}

- (void)setApiKey:(NSString * _Nonnull)apiKey {
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:APIKEY];
}

- (NSString *)appId {
    if (self.appId == nil) {
        self.appId = [[NSUserDefaults standardUserDefaults] stringForKey:APPID];
    }
    return self.appId;
}

- (void)setAppId:(NSString * _Nonnull)appId {
    _appId = appId;
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:APPID];
}

@end
