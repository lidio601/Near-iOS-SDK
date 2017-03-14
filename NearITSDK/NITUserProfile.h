//
//  NITUserProfile.h
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITUserProfile : NSObject

+ (void)createNewProfileWithCompletionHandler:(void (^)(void))handler;

@end
