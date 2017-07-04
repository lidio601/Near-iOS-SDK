//
//  NITStubGeopolisRadar.m
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITStubGeopolisRadar.h"
#import <OCMockitoIOS/OCMockitoIOS.h>

@interface NITStubGeopolisRadar()

@property (nonatomic, strong) NSTimer *locationTimer;

- (void)locationTimerFired:(NSTimer*)timer;

@end

@implementation NITStubGeopolisRadar

- (instancetype)initWithDelegate:(id<NITGeopolisRadarDelegate>)delegate nodesManager:(NITGeopolisNodesManager *)nodesManager locationManager:(CLLocationManager *)locationManager {
    self = [super initWithDelegate:delegate nodesManager:nodesManager locationManager:locationManager];
    if (self) {
        self.authorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    }
    return self;
}

- (CLAuthorizationStatus)locationAuthorizationStatus {
    return self.authorizationStatus;
}

- (NSTimer*)makeLocationTimer {
    if (self.stubLocationTimer) {
        return self.stubLocationTimer;
    }
    return mock([NSTimer class]);
}

- (void)fireLocationTimer {
    [self locationTimerFired:self.locationTimer];
}

@end
