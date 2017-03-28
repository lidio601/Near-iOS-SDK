//
//  NITCacheManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITCacheManager : NSObject

- (instancetype _Nonnull)initWithAppId:(NSString* _Nonnull)appId;

- (NSString* _Nonnull)appDirectory;
- (void)saveWithArray:(NSArray* _Nonnull)array forKey:(NSString* _Nonnull)key;
- (NSArray* _Nullable)loadArrayForKey:(NSString* _Nonnull)key;
- (BOOL)removeKey:(NSString* _Nonnull)key;
- (BOOL)existsItemForKey:(NSString* _Nonnull)key;

@end
