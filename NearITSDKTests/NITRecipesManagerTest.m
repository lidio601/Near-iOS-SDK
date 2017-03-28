//
//  NITRecipesManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"

@interface NITRecipesManagerTest : NITTestCase

@end

@implementation NITRecipesManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testScheduling {
    NITRecipe *recipe = [self recipeWithContentsOfFile:@"simple_recipe"];
    XCTAssertNotNil(recipe);
    if(recipe == nil) {
        return;
    }
    
    BOOL isScheduled = [recipe isScheduledNow:[NSDate dateWithTimeIntervalSince1970:1488459686]]; // Thu, 02 Mar 2017 13:01:26 GMT
    XCTAssertTrue(isScheduled);
    
    isScheduled = [recipe isScheduledNow:[NSDate dateWithTimeIntervalSince1970:1495458086]]; // Mon, 22 May 2017 13:01:26 GMT
    XCTAssertFalse(isScheduled);
}

@end
