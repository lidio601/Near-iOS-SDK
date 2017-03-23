//
//  NITManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITManager.h"
#import "NITConfiguration.h"
#import "NITUserProfile.h"
#import "NITUtils.h"
#import "NITGeopolisManager.h"

@interface NITManager()

@property (nonatomic, strong) NITGeopolisManager *geopolisManager;

@end

@implementation NITManager

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey {
    self = [super init];
    if (self) {
        [[NITConfiguration defaultConfiguration] setApiKey:apiKey];
        [[NITConfiguration defaultConfiguration] setAppId:[NITUtils fetchAppIdFromApiKey:apiKey]];
        
        [self pluginSetup];
        
        [NITUserProfile createNewProfileWithCompletionHandler:^(NSString * _Nullable profileId, NSError * _Nullable error) {
            
        }];
    }
    return self;
}

- (void)pluginSetup {
    self.geopolisManager = [[NITGeopolisManager alloc] init];
}

- (void)refreshConfig {
    [self.geopolisManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

@end
