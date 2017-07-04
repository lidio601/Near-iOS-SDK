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

- (void)testGeopolisRadarStartAuthorizedAlways {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    radar.authorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    [radar start];
    // Should start
    XCTAssertTrue(radar.isStarted);
    
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
}

- (void)testGeopolisRadarStartNotAuthorized {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    radar.authorizationStatus = kCLAuthorizationStatusNotDetermined;
    [radar start];
    // Should not start
    XCTAssertFalse(radar.isStarted);
}

- (void)testGeopolisRadarStartEmptyNodes {
    NITGeopolisNodesManager *nodesManager = mock([NITGeopolisNodesManager class]);
    [given([nodesManager roots]) willReturn:@[]];
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:nodesManager locationManager:self.locationManager];
    [radar start];
    // Should not start
    XCTAssertFalse(radar.isStarted);
}

@end
