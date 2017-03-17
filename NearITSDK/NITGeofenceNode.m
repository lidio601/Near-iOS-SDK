//
//  NITGeofenceNode.m
//  NearITSDK
//
//  Created by Francesco Leoni on 17/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeofenceNode.h"
#import <CoreLocation/CoreLocation.h>

@implementation NITGeofenceNode

- (CLRegion *)createRegion {
    return [[CLCircularRegion alloc] initWithCenter:[self center] radius:[self.radius doubleValue] identifier:self.ID];
}

- (CLLocationCoordinate2D)center {
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

@end
