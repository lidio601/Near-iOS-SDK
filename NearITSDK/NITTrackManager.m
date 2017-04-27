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
#import "NITDateManager.h"
#import <UIKit/UIKit.h>

NSString* const TrackCacheKey = @"Trackings";
#define LOGTAG @"TrackManager"

@interface NITTrackManager()

@property (nonatomic, strong) id<NITNetworkManaging> networkManager;
@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSNotificationCenter *notificationCenter;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (atomic, strong) NSMutableArray<NITTrackRequest*> *requests;
@property (atomic) BOOL busy;

@end

@implementation NITTrackManager

- (instancetype)initWithNetworkManager:(id<NITNetworkManaging>)networkManager cacheManager:(NITCacheManager *)cacheManager reachability:(Reachability *)reachability notificationCenter:(NSNotificationCenter *)notificationCenter operationQueue:(NSOperationQueue *)queue dateManager:(NITDateManager *)dateManager {
    self = [super init];
    if (self) {
        self.networkManager = networkManager;
        self.cacheManager = cacheManager;
        self.reachability = reachability;
        self.notificationCenter = notificationCenter;
        self.queue = queue;
        self.dateManager = dateManager;
        NSArray<NITTrackRequest*> *cachedRequests = [self.cacheManager loadArrayForKey:TrackCacheKey];
        if (cachedRequests) {
            self.requests = [[NSMutableArray alloc] initWithArray:cachedRequests];
        } else {
            self.requests = [[NSMutableArray alloc] init];
        }
        self.busy = NO;
        
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
    trackRequest.date = [self currentDate];
    [self.requests addObject:trackRequest];
    [self persistTrackings];
    [self sendTrackings];
}

- (void)sendTrackings {
    NSArray<NITTrackRequest*> *availableRequests = [self availableRequests];
    if ([availableRequests count] == 0) {
        return;
    } else if (!self.busy) {
        self.busy = YES;
    } else {
        return;
    }
    NITLogD(LOGTAG, @"Available trackings to send (%d)", [availableRequests count]);
    [self.queue addOperationWithBlock:^{
        if (self.reachability.currentReachabilityStatus != NotReachable) {
            NSMutableArray<NITTrackRequest*> *requestsToRemove = [[NSMutableArray alloc] init];
            NSMutableArray<NITTrackRequest*> *requestsToRetry = [[NSMutableArray alloc] init];
            
            dispatch_group_t group = dispatch_group_create();
            for (NITTrackRequest *request in availableRequests) {
                if (self.reachability.currentReachabilityStatus != NotReachable) {
                    dispatch_group_enter(group);
                    [self.networkManager makeRequestWithURLRequest:request.request jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
                        if (error == nil) {
                            NITLogD(LOGTAG, @"Tracking sended");
                            [requestsToRemove addObject:request];
                        } else {
                            NITLogD(LOGTAG, @"Tracking failure");
                            [requestsToRetry addObject:request];
                        }
                        dispatch_group_leave(group);
                    }];
                }
            }
            dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for(NITTrackRequest *request in requestsToRemove) {
                    [self.requests removeObject:request];
                }
                for(NITTrackRequest *request in requestsToRetry) {
                    NSUInteger index = [self.requests indexOfObject:request];
                    if (index != NSNotFound) {
                        NITTrackRequest *request = [self.requests objectAtIndex:index];
                        if (request) {
                            [request increaseRetryWithTimeInterval:5.0];
                        }
                    }
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
        if ([[self availableRequests] count] > 0) {
            [self sendTrackings];
        }
    }
}

- (NSArray<NITTrackRequest*>*)availableRequests {
    NSMutableArray<NITTrackRequest*> *availableRequests = [[NSMutableArray alloc] init];
    NSArray<NITTrackRequest*> *requests = [self.requests copy];
    for(NITTrackRequest *request in requests) {
        if ([request availableForNextRetryWithDate:[self currentDate]]) {
            [availableRequests addObject:request];
        }
    }
    return [NSArray arrayWithArray:availableRequests];
}

- (void)persistTrackings {
    [self.cacheManager saveWithObject:[NSArray arrayWithArray:self.requests] forKey:TrackCacheKey];
}

- (void)applicationDidBeacomActive:(NSNotification*)notification {
    [self sendTrackings];
}

- (NSDate*)currentDate {
    return [self.dateManager currentDate];
}

@end
