//
//  NITBeaconProximityManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NITBeaconProximityManager : NSObject

- (void)addRegionWithIdentifier:(NSString * _Nonnull)identifier;
- (void)removeRegionWithIdentifier:(NSString * _Nonnull)identifier;
- (void)addProximityWithBeaconIdentifier:(NSString* _Nonnull)beaconIdentifier regionIdentifier:(NSString* _Nonnull)regionIdentifier proximity:(CLProximity)proximity;
- (CLProximity)proximityWithBeaconIdentifier:(NSString* _Nonnull)beaconIdentifier regionIdentifier:(NSString* _Nonnull)regionIdentifier;
- (void)evaluateDisappearedWithBeaconIdentifiers:(NSArray<NSString*>* _Nullable)identifiers regionIdentifier:(NSString* _Nonnull)regionIdentifier;
- (NSInteger)regionProximitiesCount;
- (NSInteger)beaconItemsCountWithRegionIdentifier:(NSString* _Nonnull)identifier;

@end

@interface NITBeaconProximityItem : NSObject

@property (nonatomic, strong) NSString* _Nonnull identifier;
@property (nonatomic) CLProximity proximity;

@end
