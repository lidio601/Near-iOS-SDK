//
//  NITConfiguration.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITConfiguration.h"

#define APIKEY @"apiKey"

static NITConfiguration *defaultConfiguration;

@interface NITConfiguration()

@property (nonatomic) NSString * _Nonnull apiKey;

@end

@implementation NITConfiguration

@synthesize apiKey = _apiKey;

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

@end
