//
//  NITContentReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITContentReaction.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITContent.h"
#import "NITJSONAPI.h"
#import "NITConstants.h"
#import "NITRecipe.h"
#import "NITImage.h"

#define CACHE_KEY @"ContentReaction"

@interface NITContentReaction()

@property (nonatomic, strong) NSArray<NITContent*> *contents;

@end

@implementation NITContentReaction

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id _Nullable content, NSError * _Nullable error))handler {
    if (self.contents == nil) {
        self.contents = [self.cacheManager loadArrayForKey:CACHE_KEY];
    }
    for(NITContent *content in self.contents) {
        if([content.ID isEqualToString:recipe.reactionBundleId]) {
            handler(content, nil);
            return;
        }
    }
    [self requestSingleReactionWithBundleId:recipe.reactionBundleId completionHandler:^(id content, NSError *requestError) {
        if(handler) {
            handler(content, requestError);
        }
    }];
}

- (void)requestSingleReactionWithBundleId:(NSString*)bundleId completionHandler:(void (^)(id content, NSError *error))handler {
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider contentWithBundleId:bundleId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        
        if (error) {
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"Invalid content data", NSUnderlyingErrorKey: error}];
            handler(nil, anError);
        } else {
            [json registerClass:[NITContent class] forType:@"contents"];
            [json registerClass:[NITImage class] forType:@"images"];
            
            NSArray<NITContent*> *contents = [json parseToArrayOfObjects];
            if([contents count] > 0) {
                NITContent *content = [contents objectAtIndex:0];
                handler(content, nil);
            } else {
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"Invalid content data"}];
                handler(nil, anError);
            }
        }
    }];
}

- (void)refreshConfigWithCompletionHandler:(void(^)(NSError * _Nullable error))handler {
    [self.networkManager makeRequestWithURLRequest:[NITNetworkProvider contents] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            self.contents = [self.cacheManager loadArrayForKey:CACHE_KEY];
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:102 userInfo:@{NSLocalizedDescriptionKey:@"Invalid contents data", NSUnderlyingErrorKey: error}];
            if(handler) {
                handler(anError);
            }
        } else {
            [json registerClass:[NITContent class] forType:@"contents"];
            [json registerClass:[NITImage class] forType:@"images"];
            
            self.contents = [json parseToArrayOfObjects];
            [self.cacheManager saveWithArray:self.contents forKey:CACHE_KEY];
            if (handler) {
                handler(nil);
            }
        }
    }];
}

@end
