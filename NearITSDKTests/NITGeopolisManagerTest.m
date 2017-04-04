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
#import "NITNetworkMock.h"
#import "NITJSONAPIResource.h"
#import "NITJSONAPI.h"
#import "NITNode.h"
#import "Constants.h"
#import "NITBeaconProximityManager.h"
#import "NITCacheManager.h"

@interface NITGeopolisManagerTest : XCTestCase

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
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:@"beacon_areas_in_bg"];
    
    NITGeopolisManager *manager = [[NITGeopolisManager alloc] initWithNodesManager:nodesManager cachaManager:cacheManager];
    [manager startForUnitTest];
    NSError *errorNodes;
    [manager testAllNodes:&errorNodes];
    XCTAssertNil(errorNodes);
    [manager stop];
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
