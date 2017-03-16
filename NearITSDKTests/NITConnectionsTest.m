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

#define APIKEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJlMzRhN2Q5MC0xNGQyLTQ2YjgtODFmMC04MWEyYzkzZGQ0ZDAiLCJyb2xlX2tleSI6ImFwcCJ9fX0.2GvA499N8c1Vui9au7NzUWM8B10GWaha6ASCCgPPlR8"
#define APPID @"e34a7d90-14d2-46b8-81f0-81a2c93dd4d0"
#define BASE_URL @"https://dev-api.nearit.com"

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
    
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:@"/recipes"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self fillHeadersWithRequest:request];
    
    [NITNetworkManager makeRequestWithURLRequest:request jsonApicompletionHandler:^(NITJSONAPI * _Nullable json, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertNotNil(json, @"json is nil");
        
        NITJSONAPIResource *firstResourceObject = [json firstResourceObject];
        XCTAssertNotNil(firstResourceObject, @"first resource object is nil");
        XCTAssertTrue([firstResourceObject.type isEqualToString:@"recipes"], @"type is not recipes");
        
        [recipeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
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
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
        
    }];
}

- (void)testGeopolisNode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Expectation"];
    
    [NITNetworkManager makeRequestWithURLRequest:[NITNetworkProvider geopolisNodes] completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        XCTAssertNil(error);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"JSON Geopolis: %@", json);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end
