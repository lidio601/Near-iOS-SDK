//
//  NITBeaconProximityManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITBeaconProximityManager.h"

@interface NITBeaconProximityManager()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<NITBeaconProximityItem*>*> *proximities;

@end

@implementation NITBeaconProximityManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.proximities = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addRegionWithIdentifier:(NSString *)identifier {
    [self.proximities setObject:[[NSMutableArray alloc] init] forKey:identifier];
}

- (void)removeRegionWithIdentifier:(NSString *)identifier {
    [self.proximities removeObjectForKey:identifier];
}

- (void)addProximityWithBeaconIdentifier:(NSString*)beaconIdentifier regionIdentifier:(NSString*)regionIdentifier proximity:(CLProximity)proximity {
    if (proximity == CLProximityUnknown) {
        return;
    }
    
    NSMutableArray<NITBeaconProximityItem*>* items = [self.proximities objectForKey:regionIdentifier];
    if (items == nil) {
        return;
    }
    
    NITBeaconProximityItem *item = [[NITBeaconProximityItem alloc] init];
    item.identifier = beaconIdentifier;
    NSInteger index = [items indexOfObject:item];
    if (index != NSNotFound) {
        item = [items objectAtIndex:index];
        item.proximity = proximity;
    } else {
        item.proximity = proximity;
        [items addObject:item];
    }
}

- (CLProximity)proximityWithBeaconIdentifier:(NSString*)beaconIdentifier regionIdentifier:(NSString*)regionIdentifier {
    NSMutableArray<NITBeaconProximityItem*>* items = [self.proximities objectForKey:regionIdentifier];
    if (items == nil) {
        return CLProximityUnknown;
    }
    
    NITBeaconProximityItem *item = [[NITBeaconProximityItem alloc] init];
    item.identifier = beaconIdentifier;
    NSInteger index = [items indexOfObject:item];
    if (index != NSNotFound) {
        item = [items objectAtIndex:index];
        return item.proximity;
    } else {
        return CLProximityUnknown;
    }
}

- (void)evaluateDisappearedWithBeaconIdentifiers:(NSArray<NSString*>*)identifiers regionIdentifier:(NSString*)regionIdentifier {
    NSMutableArray<NITBeaconProximityItem*>* items = [self.proximities objectForKey:regionIdentifier];
    if (items == nil) {
        return;
    }
    
    NSMutableArray<NITBeaconProximityItem*>* itemsToRemove = [[NSMutableArray alloc] init];
    for(NITBeaconProximityItem *item in items) {
        if(![identifiers containsObject:item.identifier]) {
            [itemsToRemove addObject:item];
        }
    }
    
    for(NITBeaconProximityItem *item in itemsToRemove) {
        [items removeObject:item];
    }
}

- (NSInteger)regionProximitiesCount {
    return [self.proximities count];
}

- (NSInteger)beaconItemsCountWithRegionIdentifier:(NSString *)identifier {
    return [[self.proximities objectForKey:identifier] count];
}

@end

@implementation NITBeaconProximityItem

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[NITBeaconProximityItem class]]) {
        NITBeaconProximityItem *item = (NITBeaconProximityItem*)object;
        if ([item.identifier.lowercaseString isEqualToString:self.identifier.lowercaseString]) {
            return YES;
        }
    }
    return NO;
}

@end
