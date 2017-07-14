//
//  NITCacheManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITCacheManager;

@protocol NITCacheManagerDelegate <NSObject>

- (void)cacheManager:(NITCacheManager* _Nonnull)cacheManager didSaveKey:(NSString* _Nonnull)key;

@end

@interface NITCacheManager : NSObject

@property (nonatomic, weak) id<NITCacheManagerDelegate> _Nullable delegate;

+ (instancetype _Nonnull)sharedInstance;
- (instancetype _Nonnull)initWithAppId:(NSString* _Nonnull)appId;

- (void)setAppId:(NSString * _Nonnull)appId;
- (NSString* _Nonnull)appDirectory;
- (void)saveWithArray:(NSArray* _Nonnull)array forKey:(NSString* _Nonnull)key;
- (void)saveWithObject:(id<NSCoding> _Nonnull)object forKey:(NSString* _Nonnull)key;
- (NSArray* _Nullable)loadArrayForKey:(NSString* _Nonnull)key;
- (NSDictionary* _Nullable)loadDictionaryForKey:(NSString* _Nonnull)key;
- (id _Nullable)loadObjectForKey:(NSString* _Nonnull)key;
- (NSString* _Nullable)loadStringForKey:(NSString* _Nonnull)key;
- (NSNumber* _Nullable)loadNumberForKey:(NSString* _Nonnull)key;
- (BOOL)removeKey:(NSString* _Nonnull)key;
- (BOOL)existsItemForKey:(NSString* _Nonnull)key;
- (void)removeAllItemsWithCompletionHandler:(void(^_Nullable)(void))handler;
- (NSInteger)numberOfStoredKeys;

@end
