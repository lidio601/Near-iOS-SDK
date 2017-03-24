//
//  NITNetworkMock.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^NITNetworkMockTestBlock)(NSURLRequest* _Nonnull);

@interface NITNetworkMock : NSObject

@property (nonatomic) BOOL enabled;

+ (NITNetworkMock* _Nonnull)sharedInstance;
- (void)registerData:(NSData* _Nonnull)data withTest:(NITNetworkMockTestBlock _Nonnull)test;
- (void)clearTests;
- (NSData* _Nullable)dataWithRequest:(NSURLRequest* _Nonnull)request;

@end
