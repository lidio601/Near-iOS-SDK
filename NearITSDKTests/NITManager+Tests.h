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
@class NITCacheManager;
@class CLLocationManager;
@class NITGeopolisManager;
@class NITRecipesManager;
@class CBCentralManager;

@interface NITManager (Tests)

- (instancetype _Nonnull)initWithApiKey:(NSString * _Nonnull)apiKey configuration:(NITConfiguration* _Nonnull)configuration networkManager:(id<NITNetworkManaging> _Nonnull)networkManager cacheManager:(NITCacheManager* _Nonnull)cacheManager locationManager:(CLLocationManager* _Nullable)locationManager bluetoothManager:(CBCentralManager* _Nonnull)bluetoothManager;
- (NITGeopolisManager *_Nonnull)geopolisManager;
- (NITRecipesManager * _Nonnull)recipesManager;

@end
