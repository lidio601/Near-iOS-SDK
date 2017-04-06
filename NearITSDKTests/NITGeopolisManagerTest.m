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
#import "NITNetworkMock.h"
#import "NITJSONAPIResource.h"
#import "NITJSONAPI.h"
#import "NITNode.h"
#import "Constants.h"
#import "NITBeaconProximityManager.h"
#import "NITCacheManager.h"

@interface NITGeopolisManagerTest : NITTestCase

@end

@implementation NITGeopolisManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[NITConfiguration defaultConfiguration] setApiKey:APIKEY];
    [[NITConfiguration defaultConfiguration] setAppId:APPID];
    
    [NITNetworkMock sharedInstance].enabled = YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNodesTraverse {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        
        NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
        [nodesManager setNodesWithJsonApi:json];
        
        NSArray<NITJSONAPIResource*> *resources = [json allResources];
        __block NSInteger trueCounter = 0;
        
        [nodesManager traverseNodesWithBlock:^(NITNode * _Nonnull node) {
            NSLog(@"Node => %@", node.ID);
            for (NITResource *res in resources) {
                if([res.ID isEqualToString:node.ID]) {
                    trueCounter++;
                    break;
                }
            }
        }];
        
        XCTAssertTrue(trueCounter == [resources count], @"Not a valid traverse");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testHandleEmptyConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"empty_config"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    
    XCTAssertTrue([nodes count] == 0);
    XCTAssertTrue([[nodesManager roots] count] == 0);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
}

- (void)testHandleSingleGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"single_gf"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITGeopolisManager *geopolisManager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    [geopolisManager startForUnitTest];
    
    XCTAssertTrue([nodes count] == 1);
    XCTAssertTrue([[nodesManager roots] count] == 1);
    NITNode *aNode = [nodesManager nodeWithID:@"d7881a25-fc82-49ec-836d-d47276e38a55"];
    XCTAssertNotNil(aNode);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    [geopolisManager stepInRegion:[aNode createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 1);
    [geopolisManager stepOutRegion:[aNode createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 1);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
}

- (void)testHandleMultiGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"gf_array"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITGeopolisManager *geopolisManager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    [geopolisManager startForUnitTest];
    
    XCTAssertTrue([nodes count] == 4);
    XCTAssertTrue([[nodesManager roots] count] == 4);
    XCTAssertNotNil([nodesManager nodeWithID:@"f4a62f53-5130-479d-ba6b-151255307dab"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"]);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"f4a62f53-5130-479d-ba6b-151255307dab"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 4);
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 4);
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"770fc5ef-fcb3-44e1-945d-a5c9ce16f1e3"] createRegion]];
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
}

- (void)testHandleMultiLevelGFConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"multi_level_gf"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITGeopolisManager *geopolisManager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    [geopolisManager startForUnitTest];
    
    XCTAssertTrue([nodes count] == 10);
    XCTAssertTrue([[nodesManager roots] count] == 10);
    XCTAssertNotNil([nodesManager nodeWithID:@"48d37439-8181-4f4c-8028-584ff6ca79a9"]);
    XCTAssertNotNil([nodesManager nodeWithID:@"214cf1d1-19bb-46fa-aa46-1c8e115db6c1"]);
    XCTAssertNil([nodesManager nodeWithID:@"dummy_id"]);
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"48d37439-8181-4f4c-8028-584ff6ca79a9"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 10);
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"48d37439-8181-4f4c-8028-584ff6ca79a9"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 10);
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"e5d67e06-57e9-4c97-bf5d-2f7c3c4510f4"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 15);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"e5d67e06-57e9-4c97-bf5d-2f7c3c4510f4"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 10);
}

- (void)testHandleGFAndBeaconConfig {
    NITJSONAPI *jsonApi = [self jsonApiWithContentsOfFile:@"beacon_areas_in_bg"];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NSArray<NITNode*> *nodes = [nodesManager setNodesWithJsonApi:jsonApi];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITGeopolisManager *geopolisManager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    [geopolisManager startForUnitTest];
    
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
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"528ac400-6272-4992-afba-672c037a12a0"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 10);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"528ac400-6272-4992-afba-672c037a12a0"] createRegion]];
    
    // entering a root node with 5 children
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 15);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    
    // exiting a root node that had children
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 10);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    
    // entering a node with 4 sibiligs and 1 child
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"4435d9fb-c0fe-48a7-811b-87769e38b84d"] createRegion]];
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"6e076bcb-f583-4643-a192-122f98138530"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 6);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    
    // entering a node with only beacon region nodes
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 8);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    
    // entering a node beacon region with an identifier
    [geopolisManager stepInRegion:[[nodesManager nodeWithID:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 7);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 1);
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"28160b69-52a8-4f96-8fe2-aaa36c9bd794"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 8);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
    
    [geopolisManager stepOutRegion:[[nodesManager nodeWithID:@"e2c3174c-bfb9-4a16-aa28-b05fe310e8ad"] createRegion]];
    XCTAssertTrue([[geopolisManager monitoredRegions] count] == 6);
    XCTAssertTrue([[geopolisManager rangedRegions] count] == 0);
}

- (void)testGeopolisCacheNotEmpty {
    [[NITNetworkMock sharedInstance] registerData:[NSData data] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/geopolis/nodes?filter"]) {
            return YES;
        }
        return NO;
    }];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"beacon_areas_in_bg" ofType:@"json"];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:nil];
    
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCache"];
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
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
    
    [[NITNetworkMock sharedInstance] clearTests];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheEmpty {
    [[NITNetworkMock sharedInstance] registerData:[NSData data] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/geopolis/nodes?filter"]) {
            return YES;
        }
        return NO;
    }];
    
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheNotEmpty"];
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    
    XCTestExpectation *geopolisExp = [self expectationWithDescription:@"Geopolis"];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNotNil(error);
        [geopolisExp fulfill];
    }];
    
    [[NITNetworkMock sharedInstance] clearTests];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheSave {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"beacon_areas_in_bg" ofType:@"json"];
    
    [[NITNetworkMock sharedInstance] registerData:[NSData dataWithContentsOfFile:path] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/geopolis/nodes?filter"]) {
            return YES;
        }
        return NO;
    }];
    
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheSave"];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 0);
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    
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
    
    [[NITNetworkMock sharedInstance] clearTests];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testGeopolisCacheSaveOverwrite {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"beacon_areas_in_bg" ofType:@"json"];
    
    [[NITNetworkMock sharedInstance] registerData:[NSData dataWithContentsOfFile:path] withTest:^BOOL(NSURLRequest * _Nonnull request) {
        if([request.URL.absoluteString containsString:@"/plugins/geopolis/nodes?filter"]) {
            return YES;
        }
        return NO;
    }];
    
    path = [bundle pathForResource:@"gf_array" ofType:@"json"];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:nil];
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"testGeopolisCacheSaveOverwrite"];
    [cacheManager saveWithObject:jsonApi forKey:@"GeopolisNodesJSON"];
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertTrue([cacheManager numberOfStoredKeys] == 1);
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    
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
    
    [[NITNetworkMock sharedInstance] clearTests];
    
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

@end
