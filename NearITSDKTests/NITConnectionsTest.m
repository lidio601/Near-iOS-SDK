//
//  NITConnectionsTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>

#define API_KEY @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI3MDQ4MTU4NDcyZTU0NWU5ODJmYzk5NDcyYmI5MTMyNyIsImlhdCI6MTQ4OTQ5MDY5NCwiZXhwIjoxNjE1NzY2Mzk5LCJkYXRhIjp7ImFjY291bnQiOnsiaWQiOiJlMzRhN2Q5MC0xNGQyLTQ2YjgtODFmMC04MWEyYzkzZGQ0ZDAiLCJyb2xlX2tleSI6ImFwcCJ9fX0.2GvA499N8c1Vui9au7NzUWM8B10GWaha6ASCCgPPlR8"

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
    [headers setObject:[NSString stringWithFormat:@"bearer %@", API_KEY] forKey:@"Authorization"];
    [headers setObject:@"application/vnd.api+json" forKey:@"Content-Type"];
    [headers setObject:@"application/vnd.api+json" forKey:@"Accept"];
    [headers setObject:@"2" forKey:@"X-API-Version"];
    
    self.headers = headers;
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
    XCTestExpectation *profileExpectation = [self expectationWithDescription:@"Profile created"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://dev-api.nearit.com/recipes"]];
    [self fillHeadersWithRequest:request];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if (json) {
            NSLog(@"JSON List recipes: %@", json);
        }
        
        [profileExpectation fulfill];
    }];
    [task resume];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Expectation: %@", [error description]);
    }];
}

@end
