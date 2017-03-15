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
- (void)setApiKey:(NSString * _Nonnull)apiKey;
- (void)setAppId:(NSString * _Nonnull)appId;

@end
