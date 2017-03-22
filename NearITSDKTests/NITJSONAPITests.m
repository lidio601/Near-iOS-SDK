//
//  NITJSONAPITests.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"

@interface NITJSONAPITests : XCTestCase

@end

@implementation NITJSONAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreation {
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.ID = @"10";
    resource.type = @"profile";
    [resource addAttributeObject:@"Marco" forKey:@"name"];
    [jsonApi setDataWithResourceObject:resource];
    
    NSDictionary *dict = [jsonApi toDictionary];
    NSDictionary *data = [dict objectForKey:@"data"];
    XCTAssertNotNil(data, @"data is nil");
    NSDictionary *type = [data objectForKey:@"type"];
    XCTAssertNotNil(type, @"type is nil");
    NSDictionary *attributes = [data objectForKey:@"attributes"];
    XCTAssertNotNil(attributes, @"attributes is nil");
}

- (void)testRead {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"jsonapi_sample1" ofType:@"json"];
    XCTAssertNotNil(path, @"path is nil");
    NSString *jsonContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertNotNil(jsonContent, @"jsonContent is nil");
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    XCTAssertNotNil(json, @"json dictionary is nil");
    
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithDictionary:json];
    NITJSONAPIResource *resource = [jsonApi firstResourceObject];
    XCTAssertNotNil(resource, @"First resource object is nil");
    XCTAssertTrue([resource.type isEqualToString:@"peoples"], @"Type is not equal to 'peoples'");
    XCTAssertEqual([resource attributesCount], 2, @"Attributes count is wrong");
}

- (void)testWithFile {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"jsonapi_sample1" ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    NITJSONAPIResource *resource = [jsonApi firstResourceObject];
    XCTAssertNotNil(resource, @"First resource object is nil");
    XCTAssertTrue([resource.type isEqualToString:@"peoples"], @"Type is not equal to 'peoples'");
    XCTAssertEqual([resource attributesCount], 2, @"Attributes count is wrong");
}

@end
