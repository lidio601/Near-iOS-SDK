//
//  NITManager+Tests.h
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITManager.h"
#import "NITNetworkManaging.h"

@class NITConfiguration;
@class CLLocationManager;

@interface NITManager (Tests)

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey configuration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager locationManager:(CLLocationManager* _Nullable)locationManager;

@end
