//
//  NITNetworkManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITNetworkManager : NSObject

+ (void)makeRequestWithURLRequest:(NSURLRequest* _Nonnull)request completionHandler:(void (^_Nonnull)(NSData* _Nullable data, NSError* _Nullable error))completionHandler;

@end
