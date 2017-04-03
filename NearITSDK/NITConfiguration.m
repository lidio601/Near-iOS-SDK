//
//  NITConfiguration.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITConfiguration.h"
#import "NITUtils.h"

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

- (NSString*)paramKeyWithKey:(NSString*)key {
    if (_appId) {
        NSString *param = [key stringByAppendingString:[NSString stringWithFormat:@"-%@", _appId]];
        return param;
    }
    return @"NearNothing";
}

- (NSString *)apiKey {
    if (_apiKey == nil) {
        _apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:[self paramKeyWithKey:APIKEY]];
    }
    return _apiKey;
}

- (void)setApiKey:(NSString * _Nonnull)apiKey {
    _apiKey = apiKey;
    _appId = [NITUtils fetchAppIdFromApiKey:apiKey];
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:[self paramKeyWithKey:APIKEY]];
    [[NSUserDefaults standardUserDefaults] setObject:_appId forKey:[self paramKeyWithKey:APPID]];
}

- (NSString *)appId {
    if (_appId == nil) {
        _appId = [[NSUserDefaults standardUserDefaults] stringForKey:[self paramKeyWithKey:APPID]];
    }
    return _appId;
}

- (void)setAppId:(NSString * _Nonnull)appId {
    _appId = appId;
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:APPID];
}

- (NSString *)profileId {
    if(_profileId == nil) {
        _profileId = [[NSUserDefaults standardUserDefaults] stringForKey:PROFILE_ID];
    }
    return _profileId;
}

- (void)setProfileId:(NSString *)profileId {
    _profileId = profileId;
    [[NSUserDefaults standardUserDefaults] setObject:profileId forKey:PROFILE_ID];
}

- (NSString *)installationId {
    if(_installationId == nil) {
        _installationId = [[NSUserDefaults standardUserDefaults] stringForKey:INSTALLATIONID];
    }
    return _installationId;
}

- (void)setInstallationId:(NSString *)installationId {
    _installationId = installationId;
    [[NSUserDefaults standardUserDefaults] setObject:installationId forKey:INSTALLATIONID];
}

- (NSString *)deviceToken {
    if(_deviceToken == nil) {
        _deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICETOKEN];
    }
    return _deviceToken;
}

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DEVICETOKEN];
}

- (void)clear {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:[self paramKeyWithKey:APIKEY]];
    [ud removeObjectForKey:[self paramKeyWithKey:APPID]];
    [ud removeObjectForKey:[self paramKeyWithKey:PROFILE_ID]];
    [ud removeObjectForKey:[self paramKeyWithKey:INSTALLATIONID]];
    [ud removeObjectForKey:[self paramKeyWithKey:DEVICETOKEN]];
    _apiKey = nil;
    _appId = nil;
    _profileId = nil;
    _installationId = nil;
    _deviceToken = nil;
}

@end
