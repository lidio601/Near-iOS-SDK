//
//  NITGeopolisRadarTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NITGeopolisRadar.h"
#import <CoreLocation/CoreLocation.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITGeopolisNodesManager.h"
#import "NITNode.h"
#import "NITStubGeopolisRadar.h"

@interface NITGeopolisRadarTest : NITTestCase

@property (nonatomic, strong) id<NITGeopolisRadarDelegate> delegate;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManagerOne;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager22;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation NITGeopolisRadarTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.delegate = mockProtocol(@protocol(NITGeopolisRadarDelegate));
    
    self.nodesManagerOne = mock([NITGeopolisNodesManager class]);
    NITNode *fakeNode = [[NITNode alloc] init];
    [given([self.nodesManagerOne roots]) willReturn:@[fakeNode]];
    
    self.nodesManager22 = [[NITGeopolisNodesManager alloc] init];
    NITJSONAPI *config22 = [self jsonApiWithContentsOfFile:@"config_22"];
    [self.nodesManager22 setNodesWithJsonApi:config22];
    
    self.locationManager = mock([CLLocationManager class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// MARK: - Start

- (void)testStartAuthorizedAlways {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    radar.authorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    [radar start];
    // Should start
    XCTAssertTrue(radar.isStarted);
    
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
}

- (void)testStartNotAuthorized {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    radar.authorizationStatus = kCLAuthorizationStatusNotDetermined;
    [radar start];
    // Should not start
    XCTAssertFalse(radar.isStarted);
}

- (void)testStartEmptyNodes {
    NITGeopolisNodesManager *nodesManager = mock([NITGeopolisNodesManager class]);
    [given([nodesManager roots]) willReturn:@[]];
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:nodesManager locationManager:self.locationManager];
    [radar start];
    // Should not start
    XCTAssertFalse(radar.isStarted);
}

// MARK: - Stop

- (void)testStop {
    CLRegion *regionMon1 = mock([CLRegion class]);
    CLRegion *regionMon2 = mock([CLRegion class]);
    CLBeaconRegion *regionRang = mock([CLBeaconRegion class]);
    NSSet<CLRegion*> *monitoredRegions = [[NSSet alloc] initWithObjects:regionMon1, regionMon2, nil];
    NSSet<CLRegion*> *rangedRegions = [[NSSet alloc] initWithObjects:regionRang, nil];
    [given([self.locationManager monitoredRegions]) willReturn:monitoredRegions];
    [given([self.locationManager rangedRegions]) willReturn:rangedRegions];
    
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    [radar stop];
    
    XCTAssertFalse(radar.isStarted);
    [verifyCount(self.locationManager, times(2)) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) stopRangingBeaconsInRegion:anything()];
}

// MARK: - Location timer

- (void)testLocationTimerStopForMaxRetry {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    NSTimer *mockTimer = mock([NSTimer class]);
    radar.stubLocationTimer = mockTimer;
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [radar start];
    
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [verifyCount(mockTimer, never()) invalidate];
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [verifyCount(mockTimer, never()) invalidate];
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, never()) requestLocation];
    [verifyCount(mockTimer, times(1)) invalidate];
}

@end
