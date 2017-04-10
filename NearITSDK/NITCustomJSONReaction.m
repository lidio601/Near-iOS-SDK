//
//  NITCustomJSONReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 31/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCustomJSONReaction.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITConstants.h"
#import "NITJSONAPI.h"
#import "NITCacheManager.h"
#import "NITRecipe.h"

#define CACHE_KEY @"CustomJSONReaction"

@interface NITCustomJSONReaction()

@property (nonatomic, strong) NSArray<NITCustomJSON*> *jsons;

@end

@implementation NITCustomJSONReaction

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id _Nullable, NSError * _Nullable))handler {
    if (self.jsons == nil) {
        self.jsons = [self.cacheManager loadArrayForKey:CACHE_KEY];
    }
    for(NITCustomJSON *json in self.jsons) {
        if([json.ID isEqualToString:recipe.reactionBundleId]) {
            handler(json, nil);
            return;
        }
    }
    [self requestSingleReactionWithBundleId:recipe.reactionBundleId completionHandler:^(id content, NSError *requestError) {
        if(handler) {
            handler(content, requestError);
        }
    }];
}

- (void)requestSingleReactionWithBundleId:(NSString*)bundleId completionHandler:(void (^)(id, NSError*))handler {
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] customJSONWithBundleId:bundleId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:121 userInfo:@{NSLocalizedDescriptionKey:@"Invalid json data", NSUnderlyingErrorKey: error}];
            handler(nil, anError);
        } else {
            [json registerClass:[NITCustomJSON class] forType:@"json_contents"];
            
            NSArray<NITCustomJSON*> *jsons = [json parseToArrayOfObjects];
            if([jsons count] > 0) {
                NITCustomJSON *json = [jsons objectAtIndex:0];
                handler(json, nil);
            } else {
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:121 userInfo:@{NSLocalizedDescriptionKey:@"Invalid json data"}];
                handler(nil, anError);
            }
        }
    }];
}

- (void)refreshConfigWithCompletionHandler:(void(^)(NSError * _Nullable error))handler {
    [self.networkManager makeRequestWithURLRequest:[[NITNetworkProvider sharedInstance] contents] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            self.jsons = [self.cacheManager loadArrayForKey:CACHE_KEY];
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:122 userInfo:@{NSLocalizedDescriptionKey:@"Invalid jsons data", NSUnderlyingErrorKey: error}];
            if(handler) {
                handler(anError);
            }
        } else {
            [json registerClass:[NITCustomJSON class] forType:@"json_contents"];
            
            self.jsons = [json parseToArrayOfObjects];
            [self.cacheManager saveWithArray:self.jsons forKey:CACHE_KEY];
            if (handler) {
                handler(nil);
            }
        }
    }];
}

@end
