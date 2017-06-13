//
//  NITRecipesManagerTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import "NITRecipesManager.h"
#import "NITRecipeCooler.h"
#import "NITCacheManager.h"
#import "NITNetworkManager.h"
#import "NITNetworkMockManger.h"
#import "NITConfiguration.h"
#import "TestReachability.h"
#import "NITTrackManager.h"
#import "NITDateManager.h"
#import "NITRecipeHistory.h"
#import "NITRecipeValidationFilter.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

@interface NITRecipesManagerTest : NITTestCase<NITManaging>

@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) TestReachability *reachability;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITRecipeHistory *recipeHistory;
@property (nonatomic, strong) NITRecipeValidationFilter *recipeValidationFilter;

@end

@implementation NITRecipesManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.reachability = [[TestReachability alloc] init];
    self.reachability.testNetworkStatus = NotReachable;
    self.dateManager = [[NITDateManager alloc] init];
    NITCacheManager *cacheManager = mock([NITCacheManager class]);
    self.recipeHistory = [[NITRecipeHistory alloc] initWithCacheManager:cacheManager dateManager:self.dateManager];
    self.recipeValidationFilter = mock([NITRecipeValidationFilter class]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOnlineEvaluation {
    self.expectation = [self expectationWithDescription:@"expectation"];
    
    NITJSONAPI *recipesJson = [self jsonApiWithContentsOfFile:@"online_recipe"];
    
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:[[NSOperationQueue alloc] init] dateManager:[[NITDateManager alloc] init]];
    NITRecipesManager *recipesManager = [[NITRecipesManager alloc] initWithCacheManager:cacheManager networkManager:networkManager configuration:[[NITConfiguration alloc] init] trackManager:trackManager recipeHistory:self.recipeHistory recipeValidationFilter:self.recipeValidationFilter];
    [recipesManager setRecipesWithJsonApi:recipesJson];
    recipesManager.manager = self;
    
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_online_recipe"];
    };
    
    [recipesManager gotPulseWithPulsePlugin:@"geopolis" pulseAction:@"leave_place" pulseBundle:@"9712e11a-ef3a-4b34-bdf6-413a84146f2e"];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testOnlinePulseEvaluation {
    self.expectation = [self expectationWithDescription:@"expectation"];
    
    NITJSONAPI *recipesJson = [self jsonApiWithContentsOfFile:@"online_recipe"];
    
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:[[NSOperationQueue alloc] init] dateManager:[[NITDateManager alloc] init]];
    NITRecipesManager *recipesManager = [[NITRecipesManager alloc] initWithCacheManager:cacheManager networkManager:networkManager configuration:[[NITConfiguration alloc] init] trackManager:trackManager recipeHistory:self.recipeHistory recipeValidationFilter:self.recipeValidationFilter];
    [recipesManager setRecipesWithJsonApi:recipesJson];
    recipesManager.manager = self;
    
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return [self jsonApiWithContentsOfFile:@"response_pulse_evaluation"];
    };
    
    [recipesManager gotPulseWithPulsePlugin:@"beacon_forest" pulseAction:@"always_evaluated" pulseBundle:@"e11f58db-054e-4df1-b09b-d0cbe2676031"];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

- (void)testRecipesManagerCacheNotEmpty {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"recipes" ofType:@"json"];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:nil];
    [jsonApi registerClass:[NITRecipe class] forType:@"recipes"];
    
    NITNetworkMockManger *networkManager = [[NITNetworkMockManger alloc] init];
    networkManager.mock = ^NITJSONAPI *(NSURLRequest *request) {
        return nil;
    };
    NITCacheManager *cacheManager = [[NITCacheManager alloc] initWithAppId:[self name]];
    NITTrackManager *trackManager = [[NITTrackManager alloc] initWithNetworkManager:networkManager cacheManager:cacheManager reachability:self.reachability notificationCenter:[NSNotificationCenter defaultCenter] operationQueue:[[NSOperationQueue alloc] init] dateManager:[[NITDateManager alloc] init]];
    NITRecipesManager *recipesManager = [[NITRecipesManager alloc] initWithCacheManager:cacheManager networkManager:networkManager configuration:[[NITConfiguration alloc] init] trackManager:trackManager recipeHistory:self.recipeHistory recipeValidationFilter:self.recipeValidationFilter];
    [cacheManager saveWithObject:[jsonApi parseToArrayOfObjects] forKey:@"Recipes"];
    [NSThread sleepForTimeInterval:0.5];
    
    XCTestExpectation *recipesExp = [self expectationWithDescription:@"Recipes"];
    [recipesManager refreshConfigWithCompletionHandler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([recipesManager recipesCount] == 6);
        [recipesExp fulfill];
    }];
    
    XCTestExpectation *cacheExp = [self expectationWithDescription:@"Cache"];
    [cacheManager removeAllItemsWithCompletionHandler:^{
        [cacheExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:nil];
}

// MARK: - NITManaging delegate

- (void)recipesManager:(NITRecipesManager *)recipesManager gotRecipe:(NITRecipe *)recipe {
    if ([self.name containsString:@"testOnlineEvaluation"]) {
        XCTAssertNotNil(recipe);
        [self.expectation fulfill];
    } else if([self.name containsString:@"testOnlinePulseEvaluation"]) {
        XCTAssertNotNil(recipe);
        XCTAssertTrue([recipe.pulseBundle.ID isEqualToString:@"e11f58db-054e-4df1-b09b-d0cbe2676031"]);
        [self.expectation fulfill];
    }
}

@end
