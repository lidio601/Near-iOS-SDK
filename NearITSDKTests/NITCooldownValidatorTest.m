//
//  NITCooldownValidatorTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITCooldownValidator.h"
#import "NITRecipe.h"
#import "NITRecipeHistory.h"
#import "NITCacheManager.h"
#import "NITDateManager.h"

@interface NITCooldownValidatorTest : NITTestCase

@property (nonatomic, strong) NITRecipeHistory *recipeHistory;
@property (nonatomic, strong) NITDateManager *dateManager;
@property (nonatomic, strong) NITCooldownValidator *cooldownValidator;
@property (nonatomic, strong) NITRecipe *criticalRecipe;
@property (nonatomic, strong) NITRecipe *nonCriticalRecipe;
@property (nonatomic, strong) NSDate *now;

@end

@implementation NITCooldownValidatorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dateManager = mock([NITDateManager class]);
    self.now = [NSDate date];
    [given([self.dateManager currentDate]) willReturn:self.now];
    self.recipeHistory = mock([NITRecipeHistory class]);
    self.cooldownValidator = [[NITCooldownValidator alloc] initWithRecipeHistory:self.recipeHistory dateManager:self.dateManager];
    self.criticalRecipe = [self buildRecipeWithId:@"critical" cooldown:[self buildCooldownWithGlobalCD:0 selfCD:0]];
    self.nonCriticalRecipe = [self buildRecipeWithId:@"pedestrian" cooldown:[self buildCooldownWithGlobalCD:[NSNumber numberWithInt:24 * 60 * 60] selfCD:[NSNumber numberWithInt:24 * 60 * 60]]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHistoryIsEmptyEnableRecipe {
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.criticalRecipe]);
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testRecipeWithSelfCooldownShownCantBeShownAgain {
    [given([self.recipeHistory isRecipeInLogWithId:self.nonCriticalRecipe.ID]) willReturnBool:YES];
    NSDate *offset = [self.now dateByAddingTimeInterval:-1 * 60 * 60]; // -1 hours
    [given([self.recipeHistory latestLogEntryWithId:self.nonCriticalRecipe.ID]) willReturn:[NSNumber numberWithDouble:[offset timeIntervalSince1970]]];
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.criticalRecipe]);
    XCTAssertFalse([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testRecipeHasNoCooldownCanBeShownAgain {
    NSDate *offset = [self.now dateByAddingTimeInterval:-1];
    [given([self.recipeHistory isRecipeInLogWithId:self.criticalRecipe.ID]) willReturnBool:YES];
    [given([self.recipeHistory latestLogEntryWithId:self.criticalRecipe.ID]) willReturn:[NSNumber numberWithDouble:[offset timeIntervalSince1970]]];
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.criticalRecipe]);
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testRecipeIsShownGlobalCooldownApplies {
    NSDate *offset = [self.now dateByAddingTimeInterval:-1 * 60 * 60]; // -1 hours
    [given([self.recipeHistory latestLog]) willReturn:[NSNumber numberWithDouble:[offset timeIntervalSince1970]]];
    XCTAssertFalse([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.criticalRecipe]);
}

- (void)testCooldwonMissingShowRecipe {
    NSNumber *nowTime = [NSNumber numberWithDouble:[self.now timeIntervalSince1970]];
    [given([self.recipeHistory latestLog]) willReturn:nowTime];
    [given([self.recipeHistory isRecipeInLogWithId:self.nonCriticalRecipe.ID]) willReturnBool:YES];
    [given([self.recipeHistory latestLogEntryWithId:self.nonCriticalRecipe.ID]) willReturn:nowTime];
    // and a recipe without the cooldown section
    self.nonCriticalRecipe.cooldown = nil;
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testMissingSelfCooldownConsiderItZero {
    NSNumber *nowTime = [NSNumber numberWithDouble:[self.now timeIntervalSince1970]];
    // there's recent history for a recipe
    [given([self.recipeHistory isRecipeInLogWithId:self.nonCriticalRecipe.ID]) willReturnBool:YES];
    [given([self.recipeHistory latestLogEntryWithId:self.nonCriticalRecipe.ID]) willReturn:nowTime];
    // and the recipe has no self-cooldown
    self.nonCriticalRecipe.cooldown = [self buildCooldownWithGlobalCD:[NSNumber numberWithInt:0] selfCD:nil];
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testMissingGlobalCooldownConsiderItZero {
    NSNumber *nowTime = [NSNumber numberWithDouble:[self.now timeIntervalSince1970]];
    // there's recent history for a recipe
    [given([self.recipeHistory latestLog]) willReturn:nowTime];
    // and the recipe has no self-cooldown
    self.nonCriticalRecipe.cooldown = [self buildCooldownWithGlobalCD:nil selfCD:[NSNumber numberWithInt:0]];
    XCTAssertTrue([self.cooldownValidator isValidWithRecipe:self.nonCriticalRecipe]);
}

- (void)testRecipeIsNeverToBeShownAgain {
    // when a one time only recipe is shown
    NITRecipe *onlyOnceRecipe = [self buildRecipeWithId:@"never again" cooldown:[self buildCooldownWithGlobalCD:[NSNumber numberWithInt:0] selfCD:kCooldwonNeverRepeat]];
    [given([self.dateManager currentDate]) willReturn:self.now];
    [given([self.recipeHistory isRecipeInLogWithId:onlyOnceRecipe.ID]) willReturnBool:YES];
    NSNumber *offset = [NSNumber numberWithDouble:[[self.now dateByAddingTimeInterval: -1 * 60 * 60] timeIntervalSince1970]];
    [given([self.recipeHistory latestLogEntryWithId:onlyOnceRecipe.ID]) willReturn:offset];
    // it is not shown again
    XCTAssertFalse([self.cooldownValidator isValidWithRecipe:onlyOnceRecipe]);
    // not even in the far far future
    NSDate *futureDate = [self.now dateByAddingTimeInterval:60 * 60 * 24 * 365 * 10]; //10 years
    [given([self.dateManager currentDate]) willReturn:futureDate];
    XCTAssertFalse([self.cooldownValidator isValidWithRecipe:onlyOnceRecipe]);
}

// MARK: - Utility

- (NITRecipe*)buildRecipeWithId:(NSString*)recipeId cooldown:(NSDictionary<NSString*, id>*)cooldown {
    NITRecipe *recipe = [[NITRecipe alloc] init];
    recipe.ID = recipeId;
    recipe.cooldown = cooldown;
    return recipe;
}

- (NSDictionary<NSString*, id>*)buildCooldownWithGlobalCD:(NSNumber*)globalCD selfCD:(NSNumber*)selfCD {
    NSMutableDictionary<NSString*, id> *cooldown = [[NSMutableDictionary alloc] init];
    if (globalCD) {
        [cooldown setObject:globalCD forKey:@"global_cooldown"];
    }
    if (selfCD) {
        [cooldown setObject:selfCD forKey:@"self_cooldown"];
    }
    return [NSDictionary dictionaryWithDictionary:cooldown];
}

@end
