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
@property (nonatomic, strong) NSOperationQueue *queue;
@property (atomic, strong) NSMutableArray<NITTrackRequest*> *requests;
@property (atomic) BOOL busy;
@property (nonatomic) NSInteger maxRetry;

@end

@implementation NITTrackManager

- (instancetype)initWithNetworkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager *)cacheManager reachability:(Reachability *)reachability notificationCenter:(NSNotificationCenter *)notificationCenter operationQueue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        self.networkManager = networkManager;
        self.cacheManager = cacheManager;
        self.reachability = reachability;
        self.notificationCenter = notificationCenter;
        self.queue = queue;
        NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:TrackCacheKey];
        if (cachedRequests) {
            self.requests = [[NSMutableArray alloc] initWithArray:cachedRequests];
        } else {
            self.requests = [[NSMutableArray alloc] init];
        }
        self.busy = NO;
        self.maxRetry = 2;
        
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
    if ([self.requests count] == 0) {
        return;
    } else if (!self.busy) {
        self.busy = YES;
    }
    [self.queue addOperationWithBlock:^{
        if (self.reachability.currentReachabilityStatus != NotReachable) {
            NSArray<NITTrackRequest*> *requestsCopy = [self.requests copy];
            NSMutableArray<NITTrackRequest*> *requestsToRemove = [[NSMutableArray alloc] init];
            
            dispatch_group_t group = dispatch_group_create();
            for (NITTrackRequest *request in requestsCopy) {
                if (self.reachability.currentReachabilityStatus != NotReachable) {
                    dispatch_group_enter(group);
                    [self.networkManager makeRequestWithURLRequest:request.request jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
                        if (error == nil) {
                            [requestsToRemove addObject:request];
                        }
                        dispatch_group_leave(group);
                    }];
                }
            }
            dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for(NITTrackRequest *request in requestsToRemove) {
                    [self.requests removeObject:request];
                }
                [self persistTrackings];
                self.busy = NO;
            });
        } else {
            self.busy = NO;
        }
    }];
    [self.queue waitUntilAllOperationsAreFinished];
    if (self.reachability.currentReachabilityStatus != NotReachable) {
        if ([self.requests count] > 0) {
            [self sendTrackings];
        }
    }
}

- (void)persistTrackings {
    [self.cacheManager saveWithObject:[NSArray arrayWithArray:self.requests] forKey:TrackCacheKey];
}

- (void)applicationDidBeacomActive:(NSNotification*)notification {
    [self sendTrackings];
}

@end
