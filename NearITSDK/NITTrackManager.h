//
//  NITTrackManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

@class NITCacheManager;
@class NITReachability;
@class NSNotificationCenter;
@class NITDateManager;
@class NITTrackManager;

extern NSString* _Nonnull const TrackCacheKey;

@protocol NITTrackManagerDelegate <NSObject>

- (void)trackManagerDidComplete:(NITTrackManager* _Nonnull)trackManager;

@end

@interface NITTrackManager : NSObject

@property (nonatomic, weak) id<NITTrackManagerDelegate> _Nullable delegate;

- (instancetype _Nonnull)initWithNetworkManager:(id<NITNetworkManaging> _Nonnull)networkManager cacheManager:(NITCacheManager* _Nonnull)cacheManager reachability:(NITReachability* _Nonnull)reachability notificationCenter:(NSNotificationCenter* _Nonnull)notificationCenter dateManager:(NITDateManager* _Nonnull)dateManager;
- (void)addTrackWithRequest:(NSURLRequest* _Nonnull)request;

@end
