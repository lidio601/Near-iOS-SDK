//
//  NITInstallation.h
//  NearITSDK
//
//  Created by Francesco Leoni on 23/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"

@class NITConfiguration;

@interface NITInstallation : NSObject

- (instancetype _Nonnull)initWithConfiguration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager;

- (void)registerInstallationWithCompletionHandler:(void (^_Nullable)(NSString* _Nullable installationId, NSError* _Nullable error))handler;

@end
