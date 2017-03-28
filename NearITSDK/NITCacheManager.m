//
//  NITCacheManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITCacheManager.h"

static NITCacheManager *defaultCache;

@interface NITCacheManager()

@property (nonatomic, strong) NSString *appId;

@end

@implementation NITCacheManager

+ (instancetype)sharedInstance {
    if (defaultCache == nil) {
        defaultCache = [[NITCacheManager alloc] init];
    }
    return defaultCache;
}

- (instancetype)initWithAppId:(NSString*)appId {
    self = [super init];
    if (self) {
        self.appId = appId;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithAppId:@"NO-APP-ID"];
    return self;
}

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        return [paths objectAtIndex:0];
    }
    return nil;
}

- (NSString*)appDirectory {
    NSString *path = [NITCacheManager applicationDocumentsDirectory];
    path = [path stringByAppendingPathComponent:@"com.nearit.sdk.cache"];
    path = [path stringByAppendingPathComponent:self.appId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

- (void)saveWithArray:(NSArray*)array forKey:(NSString*)key {
    NSString *filePath = [[self appDirectory] stringByAppendingPathComponent:key];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        [data writeToFile:filePath atomically:NO];
    });
}

- (NSArray*)loadArrayForKey:(NSString*)key {
    NSString *filePath = [[self appDirectory] stringByAppendingPathComponent:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data == nil) {
        return nil;
    }
    id array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([array isKindOfClass:[NSArray class]]) {
        return (NSArray*)array;
    }
    return nil;
}

- (BOOL)removeKey:(NSString*)key {
    NSString *filePath = [[self appDirectory] stringByAppendingPathComponent:key];
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (BOOL)existsItemForKey:(NSString*)key {
    NSString *filePath = [[self appDirectory] stringByAppendingPathComponent:key];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end
