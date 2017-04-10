//
//  NITNetworkManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

@class NITJSONAPI;

@interface NITNetworkManager : NSObject<NITNetworkManaging>

- (void)makeRequestWithURLRequest:(NSURLRequest * _Nonnull)request completionHandler:(void (^_Nonnull)(NSData * _Nullable, NSError * _Nullable))completionHandler;

@end
