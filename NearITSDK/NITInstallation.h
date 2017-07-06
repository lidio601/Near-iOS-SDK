//
//  NITInstallation.h
//  NearITSDK
//
//  Created by Francesco Leoni on 23/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITNetworkManaging.h"
#import <CoreBluetooth/CoreBluetooth.h>

@class NITConfiguration;
@class Reachability;

@interface NITInstallation : NSObject

@property (nonatomic) CBManagerState bluetoothState;

- (instancetype _Nonnull)initWithConfiguration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager reachability:(Reachability* _Nonnull)reachability;

- (void)registerInstallation;
- (void)shouldRegisterInstallation;
- (BOOL)isQueued;

@end
