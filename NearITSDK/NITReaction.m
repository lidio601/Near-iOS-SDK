//
//  NITReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITReaction.h"
#import "NITManager.h"

@interface NITReaction()

@end

@implementation NITReaction

- (instancetype)initWithCacheManager:(NITCacheManager*)cacheManager networkManager:(id<NITNetworkManaging>)networkManager {
    self = [super init];
    if (self) {
        self.cacheManager = cacheManager;
        self.networkManager = networkManager;
    }
    return self;
}

- (NSString *)pluginName {
    return @"";
}

/**
 * You can get the content (notification, poll...) of a recipe by calling it.
 */
- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id _Nonnull, NSError * _Nullable))handler {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)contentWithReactionBundleId:(NITRecipe *)recipe completionHandler:(void (^)(id _Nullable, NSError * _Nullable))handler {
    
}

- (id)contentWithJsonReactionBundle:(NSDictionary<NSString *,id> *)jsonReactionBundle recipeId:(NSString * _Nonnull)recipeId{
    return nil;
}

- (void)refreshConfigWithCompletionHandler:(void (^)(NSError * _Nullable))handler {
    if(handler) {
        handler(nil);
    }
}

@end
