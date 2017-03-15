//
//  NITConfiguration.h
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITConfiguration : NSObject

+ (NITConfiguration * _Nonnull)defaultConfiguration;

- (void)setApiKey:(NSString * _Nonnull)apiKey;
- (void)setAppId:(NSString * _Nonnull)appId;

@end
