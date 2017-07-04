//
//  NITStubGeopolisRadar.h
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisRadar.h"
#import <CoreLocation/CoreLocation.h>

@interface NITStubGeopolisRadar : NITGeopolisRadar

@property (nonatomic) CLAuthorizationStatus authorizationStatus;

- (CLAuthorizationStatus)locationAuthorizationStatus;

@end
