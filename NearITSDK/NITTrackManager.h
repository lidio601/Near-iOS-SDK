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
@class NITDateManager;

@interface NITTrackManager : NSObject

- (instancetype)initWithNetworkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager*)cacheManager reachability:(Reachability*)reachability notificationCenter:(NSNotificationCenter*)notificationCenter operationQueue:(NSOperationQueue*)queue dateManager:(NITDateManager*)dateManager;
- (void)addTrackWithRequest:(NSURLRequest*)request;

@end
