//
//  NITFeedbackReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITFeedbackReaction.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITFeedback.h"
#import "NITJSONAPI.h"
#import "NITConstants.h"
#import "NITRecipe.h"

#define CACHE_KEY @"ContentReaction"

@interface NITFeedbackReaction()

@property (nonatomic, strong) NSArray<NITFeedback*> *feedbacks;

@end

@implementation NITFeedbackReaction

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id _Nullable, NSError * _Nullable))handler {
    if (self.feedbacks == nil) {
        self.feedbacks = [self.cacheManager loadArrayForKey:CACHE_KEY];
    }
    for(NITFeedback *feedback in self.feedbacks) {
        if([feedback.ID isEqualToString:recipe.reactionBundleId]) {
            handler(feedback, nil);
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
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider feedbackWithBundleId:bundleId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:111 userInfo:@{NSLocalizedDescriptionKey:@"Invalid feedback data", NSUnderlyingErrorKey: error}];
            handler(nil, anError);
        } else {
            [json registerClass:[NITFeedback class] forType:@"feedbacks"];
            
            NSArray<NITFeedback*> *feedbacks = [json parseToArrayOfObjects];
            if ([feedbacks count] > 0) {
                NITFeedback *feedback = [feedbacks objectAtIndex:0];
                handler(feedback, nil);
            } else {
                NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:111 userInfo:@{NSLocalizedDescriptionKey:@"Invalid feedback data", NSUnderlyingErrorKey: error}];
                handler(nil, anError);
            }
        }
    }];
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))handler {
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider feedbacks] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        if (error) {
            self.feedbacks = [self.cacheManager loadArrayForKey:CACHE_KEY];
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:112 userInfo:@{NSLocalizedDescriptionKey:@"Invalid feedbacks data", NSUnderlyingErrorKey: error}];
            if(handler) {
                handler(anError);
            }
        } else {
            [json registerClass:[NITFeedback class] forType:@"feedbacks"];
            
            self.feedbacks = [json parseToArrayOfObjects];
            [self.cacheManager saveWithArray:self.feedbacks forKey:CACHE_KEY];
            if (handler) {
                handler(nil);
            }
        }
    }];
}

@end
