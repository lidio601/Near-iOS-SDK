//
//  NITGeopolisManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 17/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
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

@interface NITGeopolisManagerTest : XCTestCase

@end

@implementation NITGeopolisManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[NITConfiguration defaultConfiguration] setApiKey:APIKEY];
    [[NITConfiguration defaultConfiguration] setAppId:APPID];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManager {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(45.672349, 9.675623999999999) radius:200 identifier:@"4a15c14b-4c7b-495f-a058-41670bb76595"];
    
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] init];
    [manager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        
        [manager startForUnitTest];
        [manager testStepInRegion:region];
        XCTAssertTrue([manager hasCurrentNode], @"There is not a current node");
        [manager stop];
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
    
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

- (void)testGeopolisNodes {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"beacon_areas_in_bg" ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    
    NITNodesManager *nodesManager = [[NITNodesManager alloc] init];
    [nodesManager setNodesWithJsonApi:jsonApi];
    
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager];
    [manager startForUnitTest];
    NSError *errorNodes;
    [manager testAllNodes:&errorNodes];
    XCTAssertNil(errorNodes);
    [manager stop];
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