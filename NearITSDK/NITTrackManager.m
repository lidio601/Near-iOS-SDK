//
//  NITTrackManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTrackManager.h"
#import "NITCacheManager.h"
#import "Reachability.h"
#import "NITTrackRequest.h"
#import "NITLog.h"
#import <UIKit/UIKit.h>

NSString* const TrackCacheKey = @"Trackings";

@interface NITTrackManager()

@property (nonatomic, strong) id<NITNetworkManaging> networkManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSMutableArray<NITTrackRequest*> *requests;

@end

@implementation NITTrackManager

- (instancetype)initWithNetworkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager *)cacheManager reachability:(Reachability *)reachability notificationCenter:(NSNotificationCenter *)notificationCenter {
    self = [super init];
    if (self) {
        self.networkManager = networkManager;
        self.cacheManager = cacheManager;
        self.reachability = reachability;
        self.notificationCenter = notificationCenter;
        self.requests = [[NSMutableArray alloc] init];
        
        [self.notificationCenter addObserver:self selector:@selector(applicationDidBeacomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

- (void)addTrackWithRequest:(NSURLRequest *)request {
    NITTrackRequest *trackRequest = [[NITTrackRequest alloc] init];
    trackRequest.request = request;
    trackRequest.date = [NSDate date];
    [self.requests addObject:trackRequest];
    [self persistTrackings];
    [self sendTrackings];
}

- (void)sendTrackings {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.reachability.currentReachabilityStatus != NotReachable) {
            for (NITTrackRequest *request in self.requests) {
                [self.networkManager makeRequestWithURLRequest:request.request jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
                    if (error == nil) {
                        [self.requests removeObject:request];
                    }
                }];
            }
            [self persistTrackings];
        }
    });
}

- (void)persistTrackings {
    [self.cacheManager saveWithObject:self.requests forKey:TrackCacheKey];
}

- (void)applicationDidBeacomActive:(NSNotification*)notification {
    [self sendTrackings];
}

@end
