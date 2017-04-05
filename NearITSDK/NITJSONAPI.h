//
//  NITJSONAPI.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NITJSONAPIResource;

@interface NITJSONAPI : NSObject<NSCoding>

- (instancetype _Nonnull)init;
- (instancetype _Nullable)initWithContentsOfFile:(NSString* _Nonnull)path error:(NSError* _Nullable * _Nullable)anError;
- (instancetype _Nonnull)initWithDictionary:(NSDictionary* _Nonnull)json;

- (void)setDataWithResourceObject:(NITJSONAPIResource* _Nonnull)resourceObject;
- (NITJSONAPIResource* _Nullable)firstResourceObject;
- (NSDictionary* _Nonnull)toDictionary;
- (void)registerClass:(Class _Nonnull)cls forType:(NSString* _Nonnull)type;
- (NSArray* _Nonnull)parseToArrayOfObjects;
- (NSArray<NITJSONAPIResource*>* _Nonnull)allResources;
- (NSArray<NITJSONAPIResource*>* _Nonnull)rootResources;
- (NSData* _Nullable)dataValue;
+ (NITJSONAPI* _Nonnull)jsonApiWithAttributes:(NSDictionary* _Nonnull)attributes type:(NSString* _Nonnull)type;

@end
