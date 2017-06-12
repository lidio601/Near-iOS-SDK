//
//  NITRecipeHistoryTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITCacheManager.h"
#import "NITDateManager.h"
#import "NITRecipeHistory.h"
#import "NITRecipe.h"

#define TEST_RECIPE_ID @"test_recipe_id"
#define LOGMAP_CACHE_KEY @"RecipeHistoryLogMap"
#define LATESTLOG_CACHE_KEY @"RecipeHistoryLatestLog"

@interface NITRecipeHistoryTest : NITTestCase

@property (nonatomic, strong) NITCacheManager *cacheManager;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITRecipeHistory *recipeHistory;
@property (nonatomic, strong) NITRecipe *testRecipe;

@end

@implementation NITRecipeHistoryTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.cacheManager = mock([NITCacheManager class]);
    self.dateManager = mock([NITDateManager class]);
    self.recipeHistory = [[NITRecipeHistory alloc] initWithCacheManager:self.cacheManager dateManager:self.dateManager];
    self.testRecipe = [[NITRecipe alloc] init];
    self.testRecipe.ID = TEST_RECIPE_ID;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoHistoryHasDefaultValues {
    XCTAssertTrue([[self.recipeHistory latestLog] isEqual:[NSNumber numberWithInt:0]]);
    XCTAssertFalse([self.recipeHistory isRecipeInLogWithId:TEST_RECIPE_ID]);
}

- (void)testRecipeShownHistoryUpdated {
    NSString *anotherRecipeId = @"another_recipe_id";
    NITRecipe *anotherRecipe = [[NITRecipe alloc] init];
    anotherRecipe.ID = anotherRecipeId;
    // when we mark a recipe as shown
    [self.recipeHistory markRecipeAsShownWithId:self.testRecipe.ID];
    // then its timestamp is put in history
    XCTAssertTrue([self.recipeHistory isRecipeInLogWithId:self.testRecipe.ID]);
    XCTAssertFalse([self.recipeHistory isRecipeInLogWithId:anotherRecipeId]);
    // when we mark another recipe as shown
    [self.recipeHistory markRecipeAsShownWithId:anotherRecipe.ID];
    // then its timestamp is added to history
    XCTAssertTrue([self.recipeHistory isRecipeInLogWithId:self.testRecipe.ID]);
    XCTAssertTrue([self.recipeHistory isRecipeInLogWithId:anotherRecipeId]);
}

- (void)testRecipeIsShownUpdateLatestLogEntry {
    NSNumber *expected = [NSNumber numberWithInt:100];
    [given([self.dateManager currentDate]) willReturn:[NSDate dateWithTimeIntervalSince1970:expected.doubleValue]];
    // when we mark a recipe as shown
    [self.recipeHistory markRecipeAsShownWithId:TEST_RECIPE_ID];
    NSNumber *actualTime = [self.recipeHistory latestLog];
    // then the latest log entry is updated
    XCTAssertTrue([actualTime isEqual:expected]);
    XCTAssertTrue([self.recipeHistory isRecipeInLogWithId:TEST_RECIPE_ID]);
    XCTAssertTrue([[self.recipeHistory latestLogEntryWithId:TEST_RECIPE_ID] isEqual:expected]);
}

- (void)testHistoryIsMadeIsActuallyPersisted {
    NSNumber *latestLog = [NSNumber numberWithInt:1496769570];
    NSMutableDictionary<NSString*, NSNumber*> *log = [[NSMutableDictionary alloc] init];
    [log setObject:latestLog forKey:TEST_RECIPE_ID];
    [given([self.cacheManager loadDictionaryForKey:LOGMAP_CACHE_KEY]) willReturn:log];
    [given([self.cacheManager loadNumberForKey:LATESTLOG_CACHE_KEY]) willReturn:latestLog];
    
    XCTAssertTrue([[self.recipeHistory latestLog] isEqual:latestLog]);
    XCTAssertTrue([self.recipeHistory isRecipeInLogWithId:TEST_RECIPE_ID]);
    XCTAssertTrue([[self.recipeHistory latestLogEntryWithId:TEST_RECIPE_ID] isEqual:latestLog]);
}

@end
