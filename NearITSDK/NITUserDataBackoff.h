//
//  NITUserDataBackoff.h
//  NearITSDK
//
//  Created by Francesco Leoni on 11/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

extern NSString* _Nonnull const UserDataBackoffCacheKey;

@class NITConfiguration;
@class NITCacheManager;
@class NITUserDataBackoff;

@protocol NITUserDataBackoffDelegate <NSObject>

- (void)userDataBackoffDidComplete:(NITUserDataBackoff* _Nonnull)userDataBackoff;
- (void)userDataBackoffDidFailed:(NITUserDataBackoff* _Nonnull)userDataBackoff withError:(NSError* _Nonnull)error;

@end

@interface NITUserDataBackoff : NSObject

@property (nonatomic, weak) id<NITUserDataBackoffDelegate> _Nullable delegate;

- (instancetype _Nonnull )initWithConfiguration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager cacheManager:(NITCacheManager* _Nonnull)cacheManager;
- (void)setUserDataWithKey:(NSString* _Nonnull)key value:(NSString* _Nullable)value;
- (void)shouldSendDataPoints;

@end
