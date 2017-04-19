//
//  NITGeopolisManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 17/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"
#import <CoreLocation/CoreLocation.h>
#import "NITConfiguration.h"
#import "NITGeopolisManager.h"
#import "NITGeopolisManager+Tests.h"
#import "NITNodesManager.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITJSONAPIResource.h"
#import "NITJSONAPI.h"
#import "NITNode.h"
#import "Constants.h"
#import "NITBeaconProximityManager.h"
#import "NITCacheManager.h"
#import "NITNetworkMockManger.h"
#import "NITLog.h"
#import "NITGeopolisNodesManager.h"
#import "NITFakeLocationManager.h"

@interface NITGeopolisManagerTest : NITTestCase

@end

@implementation NITGeopolisManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[NITConfiguration defaultConfiguration] setApiKey:APIKEY];
    [[NITConfiguration defaultConfiguration] setAppId:APPID];
    [[NITConfiguration defaultConfiguration] setProfileId:@"fake-profile-id"];
    [[NITConfiguration defaultConfiguration] setInstallationId:@"fake-installation-id"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// MARK: - Test configurations

- (void)testHandleEmptyConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"empty_config"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 0);
    XCTAssertTrue([[nodesManager roots] count] == 0);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
}

- (void)testHandleSingleGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"single_gf"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 1);
    XCTAssertTrue([[nodesManager roots] count] == 1);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"d7881a25-fc82-49ec-836d-d47276e38a55"]);
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"d7881a25-fc82-49ec-836d-d47276e38a55"] count] == 1);
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"d7881a25-fc82-49ec-836d-d47276e38a55"] count] == 1);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"d7881a25-fc82-49ec-836d-d47276e38a55"] count] == 0);
}

- (void)testHandleMultiGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"gf_array"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 4);
    XCTAssertTrue([[nodesManager roots] count] == 4);
    XCTAssertNotNil([nodesManager nodeWithID:@"f4a62f53-5130-479d-ba6b-151255307dab"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"]);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"f4a62f53-5130-479d-ba6b-151255307dab"] count] == 4);
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"] count] == 4);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"] count] == 0);
}

- (void)testHandleMultiLevelGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"multi_level_gf"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 10);
    XCTAssertTrue([[nodesManager roots] count] == 10);
    XCTAssertNotNil([nodesManager nodeWithID:@"48d37439-8181-4f4c-8028-584ff6ca79a9"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"214cf1d1-19bb-46fa-aa46-1c8e115db6c1"]);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"48d37439-8181-4f4c-8028-584ff6ca79a9"] count] == 10);
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"48d37439-8181-4f4c-8028-584ff6ca79a9"] count] == 10);
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"e5d67e06-57e9-4c97-bf5d-2f7c3c4510f4"] count] == 15);
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"e5d67e06-57e9-4c97-bf5d-2f7c3c4510f4"] count] == 10);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"e5d67e06-57e9-4c97-bf5d-2f7c3c4510f4"] count] == 0);
}

- (void)testHandleGFAndBeaconConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"beacon_areas_in_bg"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 10);
    XCTAssertTrue([[nodesManager roots] count] == 10);
    XCTAssertNotNil([nodesManager nodeWithID:@"d142ce27-f22a-4462-b23e-715331d01e1b"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"6e076bcb-f583-4643-a192-122f98138530"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"ca7bb03e-beef-4554-bd9e-035f06374d4b"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"1a8613a4-134b-4504-b0c8-62d47422afdf"]);
    
    // entering a root node with no children
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"528ac400-6272-4992-afba-672c037a12a0"] count] == 10);
    // entering a root node with 5 children
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] count] == 15);
    // exiting a root node that had children
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] count] == 10);
    // entering a node with 4 sibiligs and 1 child
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"6e076bcb-f583-4643-a192-122f98138530"] count] == 6);
    // exiting from that node
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"6e076bcb-f583-4643-a192-122f98138530"] count] == 15);
    // entering a node with no sibilings and 7 children
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"] count] == 8);
    // exiting from that node
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"] count] == 6);
    // entering a node with 6 sibilings and beacon children
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"] count] == 7);
    // exiting from that node
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"] count] == 8);
    // entering a beacon node, special case
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"ca7bb03e-beef-4554-bd9e-035f06374d4b"] count] == 0);
    // exiting from that node
    XCTAssertTrue([[nodesManager statelessMonitoredNoesOnExitWithId:@"ca7bb03e-beef-4554-bd9e-035f06374d4b"] count] == 0);
    // ranging nodes of nodes with no beacon chidren
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] count] == 0);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"6e076bcb-f583-4643-a192-122f98138530"] count] == 0);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"] count] == 0);
    // ranging nodes of a node with 2 beacon children
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"] count] == 1);
    // ranging nodes of a beacon, special case
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"ca7bb03e-beef-4554-bd9e-035f06374d4b"] count] == 1);
}

- (void)testConfig22Stateless {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 2);
    XCTAssertTrue([[nodesManager roots] count] == 2);
    XCTAssertNotNil([nodesManager nodeWithID:@"r1"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"r2"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"n1r1"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"n2r1"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"n1n1r1"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"n1n1n1r1"]);
    XCTAssertNil([nodesManager nodeWithID:@"r3r1"]);
    
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"r1"] count] == 4);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"r1"] count] == 0);
    
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"n1r1"] count] == 3);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"n1r1"] count] == 0);
    
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"n1n1r1"] count] == 3);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"n1n1r1"] count] == 0);
    
    XCTAssertTrue([[nodesManager statelessMonitoredNodesOnEnterWithId:@"n1n1n1r1"] count] == 2);
    XCTAssertTrue([[nodesManager statelessRangedNodesOnEnterWithId:@"n1n1n1r1"] count] == 1);
}

- (void)testConfig22Simple {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    NSArray<NITNode*> *monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"r1"];
    XCTAssertTrue([monitoredNodes count] == 4);
    BOOL check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"r2", @"n1r1", @"n2r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n2r1"];
    XCTAssertTrue([monitoredNodes count] == 2);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1r1", @"n2r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnExitWithId:@"n2r1"];
    XCTAssertTrue([monitoredNodes count] == 4);
    check = [self checkIfArrayOfNodesContainsIds:@[@"r1", @"r2", @"n1r1", @"n2r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n1r1"];
    XCTAssertTrue([monitoredNodes count] == 3);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1r1", @"n2r1", @"n1n1r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n1n1r1"];
    XCTAssertTrue([monitoredNodes count] == 3);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1n1r1", @"n1n1n1r1", @"n2n1n1r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    NSArray<NITNode*> *rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n1n1n1r1"];
    XCTAssertTrue([monitoredNodes count] == 2);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1n1n1r1", @"n2n1n1r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 1);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1n1n1r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    // Enter a simple beacon
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n1n1n1n1r1"];
    XCTAssertTrue([monitoredNodes count] == 2);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1n1n1r1", @"n2n1n1r1"] array:monitoredNodes];
    XCTAssertTrue(check);
    
    rangedNodes = [nodesManager rangedNodesOnExitWithId:@"n1n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 0);
}

- (void)testConfig22SimpleOnlyRanged {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    NSArray<NITNode*> *rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n2r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    rangedNodes = [nodesManager rangedNodesOnExitWithId:@"n2r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 0);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 1);
    BOOL check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"n1n1n1r1", nil] array:rangedNodes];
    XCTAssertTrue(check);
    
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n2n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 2);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n2n1n1r1"] array:rangedNodes];
    XCTAssertTrue(check);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n1n1n1r1", @"n2n1n1r1"] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    rangedNodes = [nodesManager rangedNodesOnExitWithId:@"n1n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 1);
    check = [self checkIfArrayOfNodesContainsIds:@[@"n2n1n1r1"] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    rangedNodes = [nodesManager rangedNodesOnExitWithId:@"n2n1n1r1"];
    XCTAssertTrue([rangedNodes count] == 0);
}

- (void)testConfig22Siblings {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    NSArray<NITNode*> *monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"r1"];
    NSArray<NITNode*> *rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"r1"];
    XCTAssertTrue([monitoredNodes count] == 4);
    XCTAssertTrue([rangedNodes count] == 0);
    BOOL check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"r2", @"n1r1", @"n2r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n1r1"];
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n1r1"];
    XCTAssertTrue([monitoredNodes count] == 3);
    XCTAssertTrue([rangedNodes count] == 0);
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"n1r1", @"n2r1", @"n1n1r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnEnterWithId:@"n2r1"];
    rangedNodes = [nodesManager rangedNodesOnEnterWithId:@"n2r1"];
    XCTAssertTrue([monitoredNodes count] == 2);
    XCTAssertTrue([rangedNodes count] == 0);
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"n1r1", @"n2r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnExitWithId:@"n2r1"];
    XCTAssertTrue([monitoredNodes count] == 3);
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"n1r1", @"n2r1", @"n1n1r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
    
    monitoredNodes = [nodesManager monitoredNodesOnExitWithId:@"n1r1"];
    XCTAssertTrue([monitoredNodes count] == 4);
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"r2", @"n1r1", @"n2r1", nil] array:monitoredNodes];
    XCTAssertTrue(check);
}

// MARK: - Test GeopolisNodesManager currentNodes

- (void)testGeopolisNodesManagerConfig22CurrentNodesSimple {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    [nodesManager monitoredNodesOnEnterWithId:@"r1"];
    BOOL check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    [nodesManager monitoredNodesOnEnterWithId:@"n1r1"];
    [nodesManager monitoredNodesOnEnterWithId:@"n2r1"];
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"n1r1", @"n2r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    [nodesManager monitoredNodesOnExitWithId:@"n1r1"];
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"n2r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    [nodesManager monitoredNodesOnExitWithId:@"n2r1"];
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
}

- (void)testGeopolisNodesManagerConfig22CurrentNodesParentExit {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    [nodesManager monitoredNodesOnEnterWithId:@"r1"];
    BOOL check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    [nodesManager monitoredNodesOnEnterWithId:@"n1r1"];
    [nodesManager monitoredNodesOnEnterWithId:@"n2r1"];
    check = [self checkIfArrayOfNodesContainsIds:[NSArray arrayWithObjects:@"r1", @"n1r1", @"n2r1", nil] array:[nodesManager currentNodes]];
    XCTAssertTrue(check);
    
    [nodesManager monitoredNodesOnExitWithId:@"r1"];
    XCTAssertTrue([[nodesManager currentNodes] count] == 0);
}

// MARK: - Other tests

- (void)testGeopolisNodesManager {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    XCTAssertTrue([nodes count] == 2);
    XCTAssertTrue([[nodesManager roots] count] == 2);
}

- (void)testGeopolisCacheNotEmpty {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"beacon_areas_in_bg" ofType:@"json"];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:nil];
    
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCache"];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager networkManager:networkManager configuration:[NITConfiguration defaultConfiguration] locationManager:nil];
    [cacheManager saveWithObject:jsonApi forKey:@"GeopolisNodesJSON"];
    [NSThread sleepForTimeInterval:0.5];
    
    XCTestExpectation *geopolisExp = [self expectationWithDescription:@"Geopolis"];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        NSArray<NITNode*> *roots = [nodesManager roots];
        XCTAssertTrue([roots count] == 10);
        [geopolisExp fulfill];
    }];
    
    XCTestExpectation *cacheExp = [self expectationWithDescription:@"Cache"];
    [cacheManager removeAllItemsWithCompletionHandler:^{
        [cacheExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheEmpty {
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheNotEmpty"];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager networkManager:networkManager configuration:[NITConfiguration defaultConfiguration] locationManager:nil];
    
    XCTestExpectation *geopolisExp = [self expectationWithDescription:@"Geopolis"];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNotNil(error);
        [geopolisExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheSave {
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheSave"];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 0);
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"beacon_areas_in_bg"];
    };
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager networkManager:networkManager configuration:[NITConfiguration defaultConfiguration] locationManager:nil];
    
    XCTestExpectation *geopolisExp = [self expectationWithDescription:@"Geopolis"];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        [NSThread sleepForTimeInterval:0.5];
        XCTAssertTrue([cacheManager numberOfStoredKeys] == 1);
        
        XCTAssertNil(error);
        NSArray<NITNode*> *roots = [nodesManager roots];
        XCTAssertTrue([roots count] == 10);
        [geopolisExp fulfill];
    }];
    
    XCTestExpectation *cacheExp = [self expectationWithDescription:@"Cache"];
    [cacheManager removeAllItemsWithCompletionHandler:^{
        [cacheExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheSaveOverwrite {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"gf_array"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheSaveOverwrite"];
    [cacheManager saveWithObject:jsonApi forKey:@"GeopolisNodesJSON"];
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 1);
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"beacon_areas_in_bg"];
    };
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager networkManager:networkManager configuration:[NITConfiguration defaultConfiguration] locationManager:nil];
    
    XCTestExpectation *geopolisExp = [self expectationWithDescription:@"Geopolis"];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        [NSThread sleepForTimeInterval:0.5];
        XCTAssertTrue([cacheManager numberOfStoredKeys] == 1);
        
        XCTAssertNil(error);
        NSArray<NITNode*> *roots = [nodesManager roots];
        XCTAssertTrue([roots count] == 10);
        NITJSONAPI *savedJson = [cacheManager loadObjectForKey:@"GeopolisNodesJSON"];
        XCTAssertTrue([[savedJson rootResources] count] == [roots count]);
        [geopolisExp fulfill];
    }];
    
    XCTestExpectation *cacheExp = [self expectationWithDescription:@"Cache"];
    [cacheManager removeAllItemsWithCompletionHandler:^{
        [cacheExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testBeaconProximity {
    NITBeaconProximityManager *beaconProximity = [[NITBeaconProximityManager alloc] init];
    
    NSString *region1 = @"region1";
    
    [beaconProximity addRegionWithIdentifier:region1];
    [beaconProximity addRegionWithIdentifier:@"region2"];
    
    XCTAssertTrue([beaconProximity regionProximitiesCount] == 2, @"Region count is wrong");
    XCTAssertTrue([beaconProximity beaconItemsCountWithRegionIdentifier:region1] == 0);
    
    [beaconProximity addProximityWithBeaconIdentifier:@"beacon1" regionIdentifier:region1 proximity:CLProximityNear];
    [beaconProximity addProximityWithBeaconIdentifier:@"beacon2" regionIdentifier:region1 proximity:CLProximityImmediate];
    [beaconProximity addProximityWithBeaconIdentifier:@"beacon3" regionIdentifier:region1 proximity:CLProximityUnknown];
    [beaconProximity addProximityWithBeaconIdentifier:@"beacon4" regionIdentifier:region1 proximity:CLProximityFar];
    
    XCTAssertTrue([beaconProximity beaconItemsCountWithRegionIdentifier:region1] == 3);
    XCTAssertTrue([beaconProximity proximityWithBeaconIdentifier:@"beacon2" regionIdentifier:region1] == CLProximityImmediate);
    
    [beaconProximity addProximityWithBeaconIdentifier:@"beacon2" regionIdentifier:region1 proximity:CLProximityNear];
    
    XCTAssertTrue([beaconProximity proximityWithBeaconIdentifier:@"beacon2" regionIdentifier:region1] == CLProximityNear);
    
    NSArray<NSString*>* identifiers = @[@"beacon4"];
    [beaconProximity evaluateDisappearedWithBeaconIdentifiers:identifiers regionIdentifier:region1];
    XCTAssertTrue([beaconProximity beaconItemsCountWithRegionIdentifier:region1] == 1);
    XCTAssertTrue([beaconProximity proximityWithBeaconIdentifier:@"beacon2" regionIdentifier:region1] == CLProximityUnknown);
    XCTAssertTrue([beaconProximity proximityWithBeaconIdentifier:@"beacon4" regionIdentifier:region1] == CLProximityFar);
}

// MARK: - Fake Location Manager test

- (void)testFakeLocationManager {
    NITFakeLocationManager *fakeLocationManager = [[NITFakeLocationManager alloc] init];
    
    CLCircularRegion *regionCircular1 = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(45.2, 9.0) radius:200 identifier:@"regionCircular1"];
    [fakeLocationManager startMonitoringForRegion:regionCircular1];
    XCTAssertTrue([[fakeLocationManager monitoredRegions] count] == 1);
    
    CLBeaconRegion *beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"ffffffff-1234-aaaa-1a2b-a1b2c3d4e5f6"] major:520 identifier:@"beaconRegion1"];
    [fakeLocationManager startRangingBeaconsInRegion:beaconRegion1];
    XCTAssertTrue([[fakeLocationManager rangedRegions] count] == 1);
    
    [fakeLocationManager stopMonitoringForRegion:regionCircular1];
    XCTAssertTrue([[fakeLocationManager monitoredRegions] count] == 0);
    
    [fakeLocationManager stopRangingBeaconsInRegion:beaconRegion1];
    XCTAssertTrue([[fakeLocationManager rangedRegions] count] == 0);
}

- (void)testFakeLocationManagerInGeopolis {
    NITFakeLocationManager *fakeLocationManager = [[NITFakeLocationManager alloc] init];
    
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"config_22"];
    NITGeopolisNodesManager *nodesManager = [[NITGeopolisNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 0);
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    
    NITGeopolisManager *geopolisManager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager networkManager:networkManager configuration:[NITConfiguration defaultConfiguration] locationManager:fakeLocationManager];
    [geopolisManager startForUnitTest];
    
    NSSet<CLRegion*> *regions = [fakeLocationManager monitoredRegions];
    XCTAssertTrue([regions count] == 2);
    BOOL check = [self checkIfArrayOfRegionsContainsIds:@[@"r1", @"r2"] array:[regions allObjects]];
    XCTAssertTrue(check);
    
    CLRegion *region = [[nodesManager nodeWithID:@"r1"] createRegion];
    [geopolisManager stepInRegion:region];
    regions = [fakeLocationManager monitoredRegions];
    XCTAssertTrue([regions count] == 4);
    check = [self checkIfArrayOfRegionsContainsIds:@[@"r1", @"r2", @"n1r1", @"n2r1"] array:[regions allObjects]];
    XCTAssertTrue(check);
    
    [geopolisManager stepOutRegion:region];
    regions = [fakeLocationManager monitoredRegions];
    XCTAssertTrue([regions count] == 2);
    check = [self checkIfArrayOfRegionsContainsIds:@[@"r1", @"r2"] array:[regions allObjects]];
    XCTAssertTrue(check);
    
    [geopolisManager stop];
    regions = [fakeLocationManager monitoredRegions];
    XCTAssertTrue([regions count] == 0);
}

// MARK: - Utils

- (BOOL)checkIfArrayOfNodesContainsIds:(NSArray<NSString*>*)ids array:(NSArray<NITNode*>*)nodes {
    NSInteger trueCount = 0;
    for (NITNode *node in nodes) {
        for(NSString *ID in ids) {
            if ([node.ID.lowercaseString isEqualToString:ID.lowercaseString]) {
                trueCount++;
                break;
            }
        }
    }
    return trueCount == [ids count];
}

- (BOOL)checkIfArrayOfRegionsContainsIds:(NSArray<NSString*>*)ids array:(NSArray<CLRegion*>*)regions {
    NSInteger trueCount = 0;
    for (CLRegion *region in regions) {
        for(NSString *ID in ids) {
            if ([region.identifier.lowercaseString isEqualToString:ID.lowercaseString]) {
                trueCount++;
                break;
            }
        }
    }
    return trueCount == [ids count];
}

@end
