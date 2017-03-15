//
//  NITGeopolisManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager.h"
#import <CoreLocation/CoreLocation.h>

@interface NITGeopolisManager()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NITGeopolisManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (void)refreshConfig {
    
}

@end
