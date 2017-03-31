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
#define PROFILE_ID @"profileId"
#define INSTALLATIONID @"installationid"
#define DEVICETOKEN @"devicetoken"

static NITConfiguration *defaultConfiguration;

@interface NITConfiguration()

@property (nonatomic, strong) NSString * _Nonnull apiKey;
@property (nonatomic, strong) NSString * _Nonnull appId;
@property (nonatomic, strong) NSString * _Nonnull profileId;
@property (nonatomic, strong) NSString * _Nullable installationId;
@property (nonatomic, strong) NSString * _Nullable deviceToken;

@end

@implementation NITConfiguration

@synthesize apiKey = _apiKey;
@synthesize appId = _appId;
@synthesize profileId = _profileId;
@synthesize installationId = _installationId;
@synthesize deviceToken = _deviceToken;

+ (NITConfiguration * _Nonnull)defaultConfiguration {
    if (defaultConfiguration == nil) {
        defaultConfiguration = [NITConfiguration new];
    }
    return defaultConfiguration;
}

- (NSString *)apiKey {
    if (_apiKey == nil) {
        self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:APIKEY];
    }
    return _apiKey;
}

// TODO: Develop a multi apiKey configuration (useful for testing)
- (void)setApiKey:(NSString * _Nonnull)apiKey {
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:APIKEY];
}

- (NSString *)appId {
    if (_appId == nil) {
        self.appId = [[NSUserDefaults standardUserDefaults] stringForKey:APPID];
    }
    return _appId;
}

- (void)setAppId:(NSString * _Nonnull)appId {
    _appId = appId;
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:APPID];
}

- (NSString *)profileId {
    if(_profileId == nil) {
        self.profileId = [[NSUserDefaults standardUserDefaults] stringForKey:PROFILE_ID];
    }
    return _profileId;
}

- (void)setProfileId:(NSString *)profileId {
    _profileId = profileId;
    [[NSUserDefaults standardUserDefaults] setObject:profileId forKey:PROFILE_ID];
}

- (NSString *)installationId {
    if(_installationId == nil) {
        self.installationId = [[NSUserDefaults standardUserDefaults] stringForKey:INSTALLATIONID];
    }
    return _installationId;
}

- (void)setInstallationId:(NSString *)installationId {
    _installationId = installationId;
    [[NSUserDefaults standardUserDefaults] setObject:installationId forKey:INSTALLATIONID];
}

- (NSString *)deviceToken {
    if(_deviceToken == nil) {
        self.deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICETOKEN];
    }
    return _deviceToken;
}

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DEVICETOKEN];
}

// TODO: Develop e clear configuration (useful for testing)

@end
