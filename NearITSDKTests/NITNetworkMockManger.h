//
//  NITNetworkMockManger.h
//  NearITSDK
//
//  Created by Francesco Leoni on 10/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

@class NITJSONAPI;
@class NITNetworkResponse;

typedef NITJSONAPI* (^NITMockBlock)(NSURLRequest *request);
typedef NITNetworkResponse* (^NITMockResponseBlock)(NSURLRequest *request);

@interface NITNetworkResponse : NSObject

@property (nonatomic, strong) NITJSONAPI *jsonApi;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithJSONApi:(NITJSONAPI*)jsonApi;
- (instancetype)initWithError:(NSError*)error;

@end

@interface NITNetworkMockManger : NSObject<NITNetworkManaging>

@property (nonatomic, strong) NITMockBlock mock;
@property (nonatomic, strong) NITMockResponseBlock mockResponse;

- (void)setMock:(NITMockBlock)mock forKey:(NSString*)key;
- (void)removeMockForKey:(NSString*)key;
- (BOOL)isMockCalled;
- (BOOL)isMockCalledForKey:(NSString*)key;
- (NSInteger)numberOfCalls;

@end
