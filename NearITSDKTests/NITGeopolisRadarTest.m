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
#import "NITBeaconProximityManager.h"

#define ID_R1 @"R1"
#define ID_R2 @"R2"
#define ID_A1 @"A1"
#define ID_B1 @"B1"
#define ID_B2 @"B2"

@interface NITGeopolisRadar (Tests)

- (BOOL)stepResponse;

@end

@interface NITGeopolisRadarTest : NITTestCase

@property (nonatomic, strong) id<NITGeopolisRadarDelegate> delegate;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManagerOne;
@property (nonatomic, strong) NITGeopolisNodesManager *nodesManager22;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NITFakeLocationManager *fakeLocationManager;
@property (nonatomic, strong) NITBeaconProximityManager *beaconProximity;

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
    self.beaconProximity = mock([NITBeaconProximityManager class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// MARK: - Start

- (void)testStartAuthorizedAlways {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
    radar.authorizationStatus = kCLAuthorizationStatusAuthorizedAlways;
    [radar start];
    // Should start
    XCTAssertTrue(radar.isStarted);
    
    [verifyCount(self.locationManager, times(1)) startMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) requestStateForRegion:anything()];
}

- (void)testStartNotAuthorized {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
    radar.authorizationStatus = kCLAuthorizationStatusNotDetermined;
    [radar start];
    // Should not start
    XCTAssertFalse(radar.isStarted);
}

- (void)testStartEmptyNodes {
    NITGeopolisNodesManager *nodesManager = mock([NITGeopolisNodesManager class]);
    [given([nodesManager roots]) willReturn:@[]];
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:nodesManager locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
    [radar stop];
    
    XCTAssertFalse(radar.isStarted);
    [verifyCount(self.locationManager, times(2)) stopMonitoringForRegion:anything()];
    [verifyCount(self.locationManager, times(1)) stopRangingBeaconsInRegion:anything()];
}

// MARK: - Location timer

- (void)testLocationTimerStopForMaxRetry {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
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

// MARK: - Beacons ranging

- (void)testRangingSimpleChangingProximity {
    NITStubGeopolisRadar *radar = [[NITStubGeopolisRadar alloc] initWithDelegate:self.delegate nodesManager:self.nodesManagerOne locationManager:self.locationManager beaconProximityManager:self.beaconProximity];
    CLBeaconRegion *region = [self makeMockBeaconRegionWithIdentifier:ID_B1];
    
    NITBeaconNode *beacon1 = mock([NITBeaconNode class]);
    [given(beacon1.identifier) willReturn:ID_B1];
    [given(beacon1.minor) willReturn:[NSNumber numberWithInt:200]];
    [given([beacon1 createRegion]) willReturn:[self makeMockBeaconRegionWithIdentifier:ID_B1]];
    
    CLBeacon *realBeacon1 = mock([CLBeacon class]);
    [given(realBeacon1.proximity) willReturnInteger:CLProximityNear];
    [given(realBeacon1.minor) willReturn:[NSNumber numberWithInt:200]];
    
    CLBeacon *realBeacon2 = mock([CLBeacon class]);
    [given(realBeacon2.proximity) willReturnInteger:CLProximityImmediate];
    [given(realBeacon2.minor) willReturn:[NSNumber numberWithInt:300]];
    
    [given([self.nodesManagerOne nodeWithID:ID_B1]) willReturn:beacon1];
    [given([self.nodesManagerOne rangedNodesOnEnterWithId:ID_B1]) willReturn:@[beacon1]];
    [given([self.nodesManagerOne beaconNodeWithBeacon:sameInstance(realBeacon1) inChildren:anything()]) willReturn:beacon1];
    [given([self.nodesManagerOne beaconNodeWithBeacon:sameInstance(realBeacon2) inChildren:anything()]) willReturn:nil];
    
    [given([self.beaconProximity proximityWithBeaconIdentifier:ID_B1 regionIdentifier:anything()]) willReturnInteger:CLProximityUnknown];
    
    // Should call near event
    [radar simulateDidRangeBeacons:@[realBeacon1, realBeacon2] region:region];
    [verifyCount(self.delegate, times(1)) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventNear];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventImmediate];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventFar];
    
    // Should not call any event, beacuse "realBeacon1" has the same proximity as before
    [given([self.beaconProximity proximityWithBeaconIdentifier:ID_B1 regionIdentifier:anything()]) willReturnInteger:CLProximityNear];
    [radar simulateDidRangeBeacons:@[realBeacon1, realBeacon2] region:region];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventNear];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventImmediate];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventFar];
    
    // Should call immediate, beacause "realBeacon1" has changed proximity
    [given([self.beaconProximity proximityWithBeaconIdentifier:ID_B1 regionIdentifier:anything()]) willReturnInteger:CLProximityNear];
    [given(realBeacon1.proximity) willReturnInteger:CLProximityImmediate];
    [radar simulateDidRangeBeacons:@[realBeacon1, realBeacon2] region:region];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventNear];
    [verifyCount(self.delegate, times(1)) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventImmediate];
    [verifyCount(self.delegate, never()) geopolisRadar:anything() didTriggerWithNode:anything() event:NITRegionEventFar];
}

// MARK: - Utils

- (CLRegion*)makeMockRegionWithIdentifier:(NSString*)identifier {
    CLRegion *region = mock([CLRegion class]);
    [given([region identifier]) willReturn:identifier];
    return region;
}

- (CLBeaconRegion*)makeMockBeaconRegionWithIdentifier:(NSString*)identifier {
    CLBeaconRegion *region = mock([CLBeaconRegion class]);
    [given([region identifier]) willReturn:identifier];
    return region;
}

@end
