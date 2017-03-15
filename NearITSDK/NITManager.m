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

@implementation NITManager

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey {
    self = [super init];
    if (self) {
        [[NITConfiguration defaultConfiguration] setApiKey:apiKey];
        [[NITConfiguration defaultConfiguration] setAppId:[NITUtils fetchAppIdFromApiKey:apiKey]];
        
        [NITUserProfile createNewProfileWithCompletionHandler:^{ //Now is a sample
            
        }];
    }
    return self;
}

- (void)refreshConfig {
    
}

@end
