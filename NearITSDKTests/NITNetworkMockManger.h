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

typedef NITJSONAPI* (^NITMockBlock)(NSURLRequest *request);

@interface NITNetworkMockManger : NSObject<NITNetworkManaging>

@property (nonatomic, strong) NITMockBlock mock;

@end
