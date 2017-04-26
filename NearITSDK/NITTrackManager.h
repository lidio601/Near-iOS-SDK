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
@class Reachability;
@class NSNotificationCenter;

@interface NITTrackManager : NSObject

- (instancetype)initWithNetworkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager*)cacheManager reachability:(Reachability*)reachability notificationCenter:(NSNotificationCenter*)notificationCenter operationQueue:(NSOperationQueue*)queue;
- (void)addTrackWithRequest:(NSURLRequest*)request;
- (void)sendTrackings;

@end
