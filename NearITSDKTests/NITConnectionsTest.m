//
//  NITConnectionsTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"
#import "NITNetworkManager.h"
#import "NITNetworkProvider.h"
#import "NITConfiguration.h"
#import "NITNode.h"
#import "NITBeaconNode.h"
#import "NITGeofenceNode.h"
#import "NITRecipe.h"
#import "NITPulseBundle.h"
#import "NITInstallation.h"
#import "NITUserProfile.h"

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJlMzRhN2Q5MC0xNGQyLTQ2YjgtODFmMC04MWEyYzkzZGQ0ZDAiLCJyb2xlX2tleSI6ImFwcCJ9fX0.2GvA499N8c1Vui9au7NzUWM8B10GWaha6ASCCgPPlR8"
#define APPID @"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"
#define PROFILEID @"6a2490f4-28b9-4e36-b0f6-2c97c86b0002"
#define INSTALLATIONID @"fb56d2f1-0ef6-4333-b576-3efa8701b13d"
#define BASE_URL @"https://dev-api.nearit.com"
#define WAIT_TIME_EXPECTATION 6.0

@interface NITConnectionsTest : XCTestCase

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDictionary *headers;

@end

@implementation NITConnectionsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setObject:[NSString stringWithFormat:@"bearer %@", APIKEY] forKey:@"Authorization"];
    [headers setObject:@"application/vnd.api+json" forKey:@"Content-Type"];
    [headers setObject:@"application/vnd.api+json" forKey:@"Accept"];
    [headers setObject:@"2" forKey:@"X-API-Version"];
    
    self.headers = headers;
    
    [[NITConfiguration defaultConfiguration] setApiKey:APIKEY];
    [[NITConfiguration defaultConfiguration] setAppId:APPID];
    [[NITConfiguration defaultConfiguration] setProfileId:PROFILEID];
    [[NITConfiguration defaultConfiguration] setInstallationId:INSTALLATIONID];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)fillHeadersWithRequest:(NSMutableURLRequest*)request {
    for(NSString *key in self.headers) {
        NSString *field = [self.headers objectForKey:key];
        [request setValue:field forHTTPHeaderField:key];
    }
}

- (void)testListRecipes {
    XCTestExpectation *recipeExpectation = [self expectationWithDescription:@"List recipes"];
    
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:@"/recipes/process"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [self fillHeadersWithRequest:request];
    
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"evaluation";
    NSMutableDictionary<NSString*, NSString*> *core = [[NSMutableDictionary alloc] init];
    [core setObject:PROFILEID forKey:@"profile_id"];
    [core setObject:INSTALLATIONID forKey:@"installation_id"];
    [core setObject:APPID forKey:@"app_id"];
    [resource addAttributeObject:core forKey:@"core"];
    [jsonApi setDataWithResourceObject:resource];
    NSDictionary *json = [jsonApi toDictionary];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    XCTAssertNotNil(jsonData);
    [request setHTTPBody:jsonData];
    
    [NITNetworkManager makeRequestWithURLRequest:request jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(json, @"json is nil");
        
        NITJSONAPIResource *firstResourceObject = [json firstResourceObject];
        XCTAssertNotNil(firstResourceObject, @"first resource object is nil");
        XCTAssertTrue([firstResourceObject.type isEqualToString:@"recipes"], @"type is not recipes");
        
        [json registerClass:[NITRecipe class] forType:@"recipes"];
        
        NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
        XCTAssertTrue([recipes count] > 0);
        
        NITRecipe *recipe = [recipes objectAtIndex:0];
        XCTAssertNotNil(recipe.reactionPluginId);
        
        [recipeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:^(NSError * _Nullable error) {
        NSLog(@"Expectation: %@", [error description]);
    }];
}

- (void)testNewProfile {
    XCTestExpectation *profileExpectation = [self expectationWithDescription:@"Profile created"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider newProfileWithAppId:APPID] completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(error);
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (json) {
            NSLog(@"JSON Profile: %@", json);
        }
        
        [profileExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testGeopolisNode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        
        [json registerClass:[NITGeofenceNode class] forType:@"geofence_nodes"];
        [json registerClass:[NITBeaconNode class] forType:@"beacon_nodes"];
        
        NSArray *nodes = [json parseToArrayOfObjects];
        
        XCTAssertTrue([nodes count] > 0, @"nodes is empty");
        
        NITNode *node = [nodes objectAtIndex:0];
        XCTAssertTrue([node.identifier length] > 0, @"Node's identifier is empty");
        XCTAssertTrue([node.children count] > 0, @"Children is 0");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testGeopolisNodeJson {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(error);
         
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"JSON Geopolis: %@", json);
        NSLog(@"JSON String Geopolis: %@", jsonString);
         
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testRegisterInstallation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [[NITInstallation sharedInstance] registerInstallationWithCompletionHandler:^(NSString * _Nullable installationId, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(installationId);
        NSLog(@"Installation Id: %@", installationId);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testContents {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider contents] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(json);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testCustomJSONs {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider customJSONs] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(json);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testProcessRecipe {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    NSString *recipeId = @"1e11aae1-98cc-4f96-af84-1af70f57c5f9";
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider processRecipeWithId:recipeId] jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(json);
        if (json) {
            [json registerClass:[NITRecipe class] forType:@"recipes"];
            NSArray<NITRecipe*> *recipes = [json parseToArrayOfObjects];
            XCTAssertTrue([recipes count] > 0);
            if ([recipes count] > 0) {
                NITRecipe *recipe = [recipes objectAtIndex:0];
                XCTAssertTrue([recipe.ID isEqualToString:recipeId]);
            }
        }
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:WAIT_TIME_EXPECTATION handler:nil];
}

- (void)testSetUserData {
    [NITUserProfile setUserDataWithKey:@"firstname" value:@"John" completionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
