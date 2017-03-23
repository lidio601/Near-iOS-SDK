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

- (NSString* _Nullable)apiKey;
- (NSString* _Nullable)appId;
- (NSString* _Nullable)profileId;
- (void)setApiKey:(NSString * _Nonnull)apiKey;
- (void)setAppId:(NSString * _Nonnull)appId;
- (void)setProfileId:(NSString * _Nonnull)profileId;
- (NSString* _Nullable)installationId;
- (void)setInstallationId:(NSString* _Nonnull)installationId;

@end
