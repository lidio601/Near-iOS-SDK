//
//  NITNetworkManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITJSONAPI;

@interface NITNetworkManager : NSObject

+ (void)makeRequestWithURLRequest:(NSURLRequest* _Nonnull)request completionHandler:(void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error))completionHandler;
+ (void)makeRequestWithURLRequest:(NSURLRequest* _Nonnull)request jsonApicompletionHandler:(void (^_Nonnull)(NITJSONAPI * _Nullable json, NSError * _Nullable error))completionHandler;

@end
