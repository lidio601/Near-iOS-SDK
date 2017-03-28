//
//  NITReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITReaction.h"
#import "NITManager.h"
#import "NITNetworkManager.h"

@interface NITReaction()

@end

@implementation NITReaction

- (instancetype)init {
    self = [self initWithCacheManager:[NITCacheManager sharedInstance]];
    return self;
}

- (instancetype)initWithCacheManager:(NITCacheManager*)cacheManager {
    self = [super init];
    if (self) {
        self.cacheManager = cacheManager;
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

- (void)refreshConfig {
    
}

@end
