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
#import "NITGeofenceNode.h"
#import "NITBeaconNode.h"
#import "NITStubGeopolisRadar.h"
#import "NITFakeLocationManager.h"

#define ID_R1 @"R1"
#define ID_R2 @"R2"
#define ID_A1 @"A1"

@interface NITGeopolisRadar (Tests)

- (BOOL)stepResponse;

@end

@interface NITGeopolisRadarTest : NITTestCase

@property (nonatomic, strong) id<NITGeopolisRadarDelegate> delegate;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManagerOne;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager22;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITFakeLocationManager *fakeLocationManager;

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
    self.fakeLocationManager = [[NITFakeLocationManager alloc] init];
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
    
    NITNode *node = mock([NITGeofenceNode class]);
    [given(node.ID) willReturn:ID_R1];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    [given([node createRegion]) willReturn:region];
    [given([self.nodesManagerOne roots]) willReturn:@[node]];
    
    [verifyCount(self.locationManager, never()) requestLocation];
    [radar start];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    
    // 1st fire
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [verifyCount(mockTimer, never()) invalidate];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    
    // 2nd fire
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [verifyCount(mockTimer, never()) invalidate];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    
    // 3rd fire (stop)
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, never()) requestLocation];
    [verifyCount(mockTimer, times(1)) invalidate];
    [verifyCount(self.locationManager, never()) requestStateForRegion:anything()];
}

- (void)testLocationTimerStopForGeofenceInside {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    NSTimer *mockTimer = mock([NSTimer class]);
    radar.stubLocationTimer = mockTimer;
    
    NITNode *node = mock([NITGeofenceNode class]);
    [given(node.ID) willReturn:ID_R1];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    [given([node createRegion]) willReturn:region];
    [given([self.nodesManagerOne roots]) willReturn:@[node]];
    
    [verifyCount(self.locationManager, never()) requestLocation];
    [radar start];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    
    // 1st fire, should continue
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, times(1)) requestLocation];
    [verifyCount(mockTimer, never()) invalidate];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    
    [radar simulateDidDetermineStateWithRegion:[self makeMockRegionWithIdentifier:ID_R1] state:CLRegionStateInside];
    
    // 2nd fire, should stop for Geofence enter (timer invalidate)
    [radar fireLocationTimer];
    [verifyCount(self.locationManager, never()) requestLocation];
    [verifyCount(mockTimer, times(1)) invalidate];
    [verifyCount(self.locationManager, never()) requestStateForRegion:anything()];
}

// MARK: - Location Manager

- (void)testSimpleGeofenceDidDetermineInside {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    XCTAssertFalse([radar stepResponse]);
    
    NITNode *mon1 = mock([NITGeofenceNode class]);
    [given(mon1.ID) willReturn:ID_R1];
    [given([mon1 createRegion]) willReturn:[self makeMockRegionWithIdentifier:ID_R1]];
    [given([self.nodesManagerOne nodeWithID:ID_R1]) willReturn:mon1];
    [given([self.nodesManagerOne monitoredNodesOnEnterWithId:ID_R1]) willReturn:@[mon1]];
    [given([self.nodesManagerOne rangedNodesOnEnterWithId:ID_R1]) willReturn:nil];
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateInside];
    XCTAssertTrue([radar stepResponse]);
    
    [verifyCount(self.nodesManagerOne, times(1)) monitoredNodesOnEnterWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, times(1)) rangedNodesOnEnterWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, never()) monitoredNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, never()) rangedNodesOnExitWithId:ID_R1];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    
    // Should trigger "enter place" because is the first determine state
    [verifyCount(self.delegate, times(1)) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(mon1) event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
    
    // The second determine state on the same region should not call any trigger
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateInside];
    XCTAssertTrue([radar stepResponse]);
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(mon1) event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
}

- (void)testSimpleAreaDidDetermineInside {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_A1];
    
    NITNode *bNode1 = mock([NITBeaconNode class]);
    [given(bNode1.ID) willReturn:ID_A1];
    [given([bNode1 createRegion]) willReturn:[self makeMockRegionWithIdentifier:ID_A1]];
    [given([self.nodesManagerOne nodeWithID:ID_A1]) willReturn:bNode1];
    [given([self.nodesManagerOne monitoredNodesOnEnterWithId:ID_A1]) willReturn:@[bNode1]];
    [given([self.nodesManagerOne rangedNodesOnEnterWithId:ID_A1]) willReturn:nil];
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateInside];
    
    [verifyCount(self.nodesManagerOne, times(1)) monitoredNodesOnEnterWithId:ID_A1];
    [verifyCount(self.nodesManagerOne, times(1)) rangedNodesOnEnterWithId:ID_A1];
    [verifyCount(self.nodesManagerOne, never()) monitoredNodesOnExitWithId:ID_A1];
    [verifyCount(self.nodesManagerOne, never()) rangedNodesOnExitWithId:ID_A1];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    
    // Should trigger "enter area" because is the first determine state
    [verifyCount(self.delegate, times(1)) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(bNode1) event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
    
    // The second determine state on the same region should not call any trigger
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateInside];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
}

- (void)testSimpleGeofenceDidDetermineOutside {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    XCTAssertFalse([radar stepResponse]);
    
    NITNode *mon1 = mock([NITGeofenceNode class]);
    [given(mon1.ID) willReturn:ID_R1];
    [given([mon1 createRegion]) willReturn:[self makeMockRegionWithIdentifier:ID_R1]];
    [given([self.nodesManagerOne nodeWithID:ID_R1]) willReturn:mon1];
    [given([self.nodesManagerOne monitoredNodesOnExitWithId:ID_R1]) willReturn:@[mon1]];
    [given([self.nodesManagerOne rangedNodesOnExitWithId:ID_R1]) willReturn:nil];
    [given([self.locationManager monitoredRegions]) willReturn:nil];
    
    // Test region outside without monitored regions, should "never" call
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateOutside];
    XCTAssertTrue([radar stepResponse]);
    
    [verifyCount(self.nodesManagerOne, never()) monitoredNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, never()) rangedNodesOnExitWithId:ID_R1];
    [verifyCount(self.locationManager, never()) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, never()) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    
    // Did determine Outside should not trigger anything
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(mon1) event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
    
    NSSet<CLRegion*> *monitoredRegions = [[NSSet alloc] initWithObjects:region, nil];
    [given([self.locationManager monitoredRegions]) willReturn:monitoredRegions];
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateOutside];
    XCTAssertTrue([radar stepResponse]);
    
    [verifyCount(self.nodesManagerOne, times(1)) monitoredNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, times(1)) rangedNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, never()) monitoredNodesOnEnterWithId:anything()];
    [verifyCount(self.nodesManagerOne, never()) rangedNodesOnEnterWithId:anything()];
    
    // Should not call locationManager monitoring because monitoredRegions there is the same node returned by "monitoredNodesOnExitWithId"
    [verifyCount(self.locationManager, never()) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, never()) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    
    // Did determine Outside should not trigger anything
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(mon1) event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
    
    CLRegion *region2 = [self makeMockRegionWithIdentifier:ID_R2];
    monitoredRegions = [[NSSet alloc] initWithObjects:region, region2, nil];
    [given([self.locationManager monitoredRegions]) willReturn:monitoredRegions];
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateOutside];
    
    [verifyCount(self.nodesManagerOne, times(1)) monitoredNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, times(1)) rangedNodesOnExitWithId:ID_R1];
    [verifyCount(self.nodesManagerOne, never()) monitoredNodesOnEnterWithId:anything()];
    [verifyCount(self.nodesManagerOne, never()) rangedNodesOnEnterWithId:anything()];
    
    // Should call locationManager stop monitoring for region2
    [verifyCount(self.locationManager, never()) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, never()) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
    
    // Did determine Outside should not trigger anything
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:sameInstance(mon1) event:NITRegionEventLeavePlace];
    [verifyCount(self.delegate, never()) geopolisRadar:sameInstance(radar) didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterArea];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventEnterPlace];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventLeaveArea];
}

- (void)testGeofenceDidDetermineInsideDifferentRegionsSet {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    CLRegion *monRegion1 = [self makeMockRegionWithIdentifier:ID_R2];
    CLRegion *monRegion2 = [self makeMockRegionWithIdentifier:ID_A1];
    
    NITNode *mon1 = mock([NITGeofenceNode class]);
    [given(mon1.ID) willReturn:ID_R1];
    [given([mon1 createRegion]) willReturn:[self makeMockRegionWithIdentifier:ID_R1]];
    [given([self.nodesManagerOne nodeWithID:ID_R1]) willReturn:mon1];
    [given([self.nodesManagerOne monitoredNodesOnEnterWithId:ID_R1]) willReturn:@[mon1]];
    [given([self.nodesManagerOne rangedNodesOnEnterWithId:ID_R1]) willReturn:nil];
    NSSet<CLRegion*> *monitoredRegions = [[NSSet alloc] initWithObjects:monRegion1, monRegion2, nil];
    [given([self.locationManager monitoredRegions]) willReturn:monitoredRegions];
    
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateInside];
    
    // Should stop the old monitoredRegions, and start the new one
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(2)) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
}

- (void)testGeofenceDidDetermineOutsideDifferentRegionsSet {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager];
    CLRegion *region = [self makeMockRegionWithIdentifier:ID_R1];
    CLRegion *monRegion1 = [self makeMockRegionWithIdentifier:ID_R2];
    CLRegion *monRegion2 = [self makeMockRegionWithIdentifier:ID_A1];
    
    NITNode *mon1 = mock([NITGeofenceNode class]);
    [given(mon1.ID) willReturn:ID_R1];
    [given([mon1 createRegion]) willReturn:[self makeMockRegionWithIdentifier:ID_R1]];
    
    NITNode *mon2 = mock([NITGeofenceNode class]);
    [given(mon2.ID) willReturn:@"new2"];
    [given([mon2 createRegion]) willReturn:[self makeMockRegionWithIdentifier:@"new2"]];
    
    [given([self.nodesManagerOne nodeWithID:ID_R1]) willReturn:mon1];
    [given([self.nodesManagerOne nodeWithID:@"new2"]) willReturn:mon2];
    [given([self.nodesManagerOne monitoredNodesOnExitWithId:ID_R1]) willReturn:@[mon1, mon2]];
    [given([self.nodesManagerOne rangedNodesOnExitWithId:ID_R1]) willReturn:nil];
    NSSet<CLRegion*> *monitoredRegions = [[NSSet alloc] initWithObjects:region, monRegion1, monRegion2, nil];
    [given([self.locationManager monitoredRegions]) willReturn:monitoredRegions];
    
    [radar simulateDidDetermineStateWithRegion:region state:CLRegionStateOutside];
    
    // Should start a new monitoring (only mon2) and stop the old two (monRegion1, monRegion2)
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(2)) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, never()) startRangingBeaconsInRegion:anything()];
    [verifyCount(self.locationManager, never()) stopMonitoringForRegion:anything()];
}

// MARK: - Utils

- (CLRegion*)makeMockRegionWithIdentifier:(NSString*)identifier {
    CLRegion *region = mock([CLRegion class]);
    [given([region identifier]) willReturn:identifier];
    return region;
}

@end
