//
//  NITTestBeacon.h
//  NearITSDK
//
//  Created by Francesco Leoni on 19/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface NITTestBeacon : NSObject

@property (nonatomic, strong) NSUUID *testProximityUUID;
@property (nonatomic, strong) NSNumber *testMajor;
@property (nonatomic, strong) NSNumber *testMinor;
@property (nonatomic) CLProximity testProximity;

@end
