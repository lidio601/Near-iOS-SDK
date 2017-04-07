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
    return nil;
}

- (NSString *)apiKey {
    if (_apiKey == nil) {
        _apiKey = [self objectWithKey:APIKEY];
    }
    return _apiKey;
}

- (void)setApiKey:(NSString * _Nonnull)apiKey {
    _apiKey = apiKey;
    _appId = [NITUtils fetchAppIdFromApiKey:apiKey];
    [self saveParamWithKey:APIKEY value:apiKey];
    [self saveParamWithKey:APPID value:_appId];
}

- (NSString *)appId {
    if (_appId == nil) {
        _appId = [self objectWithKey:APPID];
    }
    return _appId;
}

- (void)setAppId:(NSString * _Nonnull)appId {
    _appId = appId;
    [self saveParamWithKey:APPID value:appId];
}

- (NSString *)profileId {
    if(_profileId == nil) {
        _profileId = [self objectWithKey:PROFILE_ID];
    }
    return _profileId;
}

- (void)setProfileId:(NSString *)profileId {
    _profileId = profileId;
    if (profileId) {
        [self saveParamWithKey:PROFILE_ID value:profileId];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self paramKeyWithKey:PROFILE_ID]];
    }
}

- (NSString *)installationId {
    if(_installationId == nil) {
        _installationId = [self objectWithKey:INSTALLATIONID];
    }
    return _installationId;
}

- (void)setInstallationId:(NSString *)installationId {
    _installationId = installationId;
    [self saveParamWithKey:INSTALLATIONID value:installationId];
}

- (NSString *)deviceToken {
    if(_deviceToken == nil) {
        _deviceToken = [self objectWithKey:DEVICETOKEN];
    }
    return _deviceToken;
}

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [self saveParamWithKey:DEVICETOKEN value:DEVICETOKEN];
}

- (void)saveParamWithKey:(NSString*)key value:(id)object {
    NSString *realKey = [self paramKeyWithKey:key];
    if (realKey) {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:realKey];
    }
}

- (id)objectWithKey:(NSString*)key {
    NSString *realKey = [self paramKeyWithKey:key];
    if (realKey) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    return nil;
}

- (void)clear {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:[self paramKeyWithKey:APIKEY]];
    [ud removeObjectForKey:[self paramKeyWithKey:APPID]];
    [ud removeObjectForKey:[self paramKeyWithKey:PROFILE_ID]];
    [ud removeObjectForKey:[self paramKeyWithKey:INSTALLATIONID]];
    [ud removeObjectForKey:[self paramKeyWithKey:DEVICETOKEN]];
    [ud synchronize];
    _apiKey = nil;
    _appId = nil;
    _profileId = nil;
    _installationId = nil;
    _deviceToken = nil;
}

@end
