//
//  NITNotificationProcessorTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 27/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITTestCase.h"
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITNotificationProcessor.h"
#import "NITRecipesManager.h"
#import "NITRecipe.h"
#import "NITSimpleNotificationReaction.h"
#import "NITSimpleNotification.h"
#import "NITContentReaction.h"
#import "NITContent.h"

#define SIMPLE_NOT_REACTION @"simple-notification"
#define CONTENT_REACTION @"content-notification"

typedef void (^ReactionBlock)(id content, NSError *error);
typedef void (^ProcessRecipeBlock)(NITRecipe * _Nullable recipe, NSError * _Nullable error);

@interface NITNotificationProcessorTest : NITTestCase

@property (nonatomic, strong) NITNotificationProcessor *processor;
@property (nonatomic, strong) NITRecipesManager *recipesManager;
@property (nonatomic, strong) NITSimpleNotificationReaction *simpleReaction;
@property (nonatomic, strong) NITContentReaction *contentReaction;
@property (nonatomic, strong) NSMutableDictionary<NSString*, id> *userInfo;

@property (nonatomic, strong) NSString *dummyRecipeId;
@property (nonatomic, strong) NSString *dummyReactionPluginId;
@property (nonatomic, strong) NSString *dummyReactionBundleId;

@end

@implementation NITNotificationProcessorTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.recipesManager = mock([NITRecipesManager class]);
    self.userInfo = [[NSMutableDictionary alloc] init];
    
    self.dummyRecipeId = @"dummy_recipe_id";
    self.dummyReactionBundleId = @"dummy_reaction_bundle_id";
    
    self.simpleReaction = mock([NITSimpleNotificationReaction class]);
    [givenVoid([self.simpleReaction contentWithRecipe:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        ReactionBlock block = [invocation mkt_arguments][1];
        NITSimpleNotification *simple = [[NITSimpleNotification alloc] init];
        simple.message = @"Hello World!";
        block(simple, nil);
        return nil;
    }];
    [givenVoid([self.simpleReaction contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        ReactionBlock block = [invocation mkt_arguments][2];
        NSError *error = [[NSError alloc] init];
        block(nil, error);
        return nil;
    }];
    [given([self.simpleReaction contentWithJsonReactionBundle:anything() recipeId:anything()]) willReturn:nil];
    
    self.contentReaction = mock([NITContentReaction class]);
    [givenVoid([self.contentReaction contentWithRecipe:anything() completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        ReactionBlock block = [invocation mkt_arguments][1];
        NITContent *content = [[NITContent alloc] init];
        block(content, nil);
        return nil;
    }];
    [givenVoid([self.contentReaction contentWithReactionBundleId:anything() recipeId:self.dummyRecipeId completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        ReactionBlock block = [invocation mkt_arguments][2];
        NITContent *content = [[NITContent alloc] init];
        block(content, nil);
        return nil;
    }];
    NITContent *emptyContent = [[NITContent alloc] init];
    [given([self.contentReaction contentWithJsonReactionBundle:anything() recipeId:anything()]) willReturn:emptyContent];
    
    self.processor = [[NITNotificationProcessor alloc] initWithRecipesManager:self.recipesManager reactions:@{SIMPLE_NOT_REACTION : self.simpleReaction, CONTENT_REACTION : self.contentReaction}];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMissingRecipeId {
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable object, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNotNil(error);
        XCTAssertTrue(error.code == 102);
        
        [expectation fulfill];
    }];
    XCTAssertFalse(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testOldFormatNotification {
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self setRecipesManagerProcessRecipeWithReactionPluginId:SIMPLE_NOT_REACTION];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        [verifyCount(self.recipesManager, times(1)) processRecipe:anything() completion:anything()];
        [verifyCount(self.simpleReaction, times(1)) contentWithRecipe:anything() completionHandler:anything()];
        XCTAssertTrue([content isKindOfClass:[NITSimpleNotification class]]);
        if ([content isKindOfClass:[NITSimpleNotification class]]) {
            NITSimpleNotification *simple = (NITSimpleNotification*)content;
            XCTAssertTrue([simple.message isEqualToString:@"Hello World!"]);
        }
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testReactionBundleId {
    self.dummyReactionPluginId = CONTENT_REACTION;
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    
    [self setRecipesManagerProcessRecipeWithReactionPluginId:CONTENT_REACTION];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        [verifyCount(self.contentReaction, times(1)) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        [verifyCount(self.recipesManager, never()) processRecipe:anything() completion:anything()];
        XCTAssertTrue([content isKindOfClass:[NITContent class]]);
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testReactionBundle {
    self.dummyReactionPluginId = CONTENT_REACTION;
    NSString *reactionBundle = @"eJyVksFOhDAQhu88BXLemhZKS/fqxQcwMdFsNgMzKBGBQNGYDe9udxdYUBP10gwz80+/+cvB8/0AwUKw9Q8udl8FujggrTFM8oxlCjiTqckZhAkwKV1FCWEojIPNWdFSCbaoq+65aLp5kCtAj0W9SFzuqvqyHJPDZmovXuGJuh/7H+eMv6ieOuxHQ0fiUb1ZV8/bSJ1AjJKz2HEzmUeagcmBiVipLCQSZDBYCIc53n2j7JuyBvx1K2+hmhmzurJU2YkyAGvbIu0trW1rmv34CpEEjYYzIdFxqzRhici5OyDMTIQokc8bT9OPwptz6N9SWdb+fd2WeBWsjXZXdCtn/+XS7osfI/ACpiWwhHs48YRcaMYjFso7wbdSbIW+jpRS8cNFcfpbvs15K5DqfVlUL+t8/V5RO3bnoAUoUizlRjCZELFUG3dg4kxSOtIiChbA+Dcyb3rIwRs+AYn3vrc=";
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    [self.userInfo setObject:reactionBundle forKey:NOTPROC_REACTION_BUNDLE];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([recipeId isEqualToString:self.dummyRecipeId]);
        [verifyCount(self.contentReaction, times(1)) contentWithJsonReactionBundle:anything() recipeId:anything()];
        [verifyCount(self.contentReaction, never()) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        [verifyCount(self.recipesManager, never()) processRecipe:anything() completion:anything()];
        XCTAssertTrue([content isKindOfClass:[NITContent class]]);
        
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testSimpleNotificationWithReactionPluginId {
    self.dummyReactionPluginId = SIMPLE_NOT_REACTION;
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    [self.userInfo setObject:@{@"alert" : @"APS Hello World!"} forKey:@"aps"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        [verifyCount(self.recipesManager, never()) processRecipe:anything() completion:anything()];
        [verifyCount(self.simpleReaction, never()) contentWithRecipe:anything() completionHandler:anything()];
        [verifyCount(self.simpleReaction, never()) contentWithJsonReactionBundle:anything() recipeId:anything()];
        [verifyCount(self.simpleReaction, never()) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        XCTAssertTrue([content isKindOfClass:[NITSimpleNotification class]]);
        if ([content isKindOfClass:[NITSimpleNotification class]]) {
            NITSimpleNotification *simple = (NITSimpleNotification*)content;
            XCTAssertTrue([simple.message isEqualToString:@"APS Hello World!"]);
        }
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testInvalidJsonInReactionBundle {
    self.dummyReactionPluginId = CONTENT_REACTION;
    NSString *reactionBundle = @"eJzzSM3JyVcozy/KSVFIKs1LyUlVBABG5Ab4";
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    [self.userInfo setObject:reactionBundle forKey:NOTPROC_REACTION_BUNDLE];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([recipeId isEqualToString:self.dummyRecipeId]);
        [verifyCount(self.contentReaction, never()) contentWithJsonReactionBundle:anything() recipeId:anything()];
        [verifyCount(self.contentReaction, times(1)) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        [verifyCount(self.recipesManager, never()) processRecipe:anything() completion:anything()];
        XCTAssertTrue([content isKindOfClass:[NITContent class]]);
        
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testInvalidReactionBundleId {
    self.dummyReactionPluginId = CONTENT_REACTION;
    self.dummyRecipeId = @"dummy_2";
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    
    [self setRecipesManagerProcessRecipeWithReactionPluginId:CONTENT_REACTION];
    
    [givenVoid([self.contentReaction contentWithReactionBundleId:anything() recipeId:self.dummyRecipeId completionHandler:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        ReactionBlock block = [invocation mkt_arguments][2];
        NSError *error = [[NSError alloc] init];
        block(nil, error);
        return nil;
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertTrue([recipeId isEqualToString:self.dummyRecipeId]);
        [verifyCount(self.contentReaction, never()) contentWithJsonReactionBundle:anything() recipeId:anything()];
        [verifyCount(self.contentReaction, times(1)) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        [verifyCount(self.contentReaction, times(1)) contentWithRecipe:anything() completionHandler:anything()];
        [verifyCount(self.recipesManager, times(1)) processRecipe:anything() completion:anything()];
        XCTAssertTrue([content isKindOfClass:[NITContent class]]);
        
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testSimpleNotificationWithoutAps {
    self.dummyReactionPluginId = SIMPLE_NOT_REACTION;
    
    [self.userInfo setObject:self.dummyRecipeId forKey:NOTPROC_RECIPE_ID];
    [self.userInfo setObject:self.dummyReactionBundleId forKey:NOTPROC_REACTION_BUNDLE_ID];
    [self.userInfo setObject:self.dummyReactionPluginId forKey:NOTPROC_REACTION_PLUGIN_ID];
    [self setRecipesManagerProcessRecipeWithReactionPluginId:self.dummyReactionPluginId];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"process"];
    BOOL processable = [self.processor processNotificationWithUserInfo:self.userInfo completion:^(id  _Nullable content, NSString * _Nullable recipeId, NSError * _Nullable error) {
        XCTAssertNil(error);
        [verifyCount(self.recipesManager, times(1)) processRecipe:anything() completion:anything()];
        [verifyCount(self.simpleReaction, times(1)) contentWithRecipe:anything() completionHandler:anything()];
        [verifyCount(self.simpleReaction, never()) contentWithJsonReactionBundle:anything() recipeId:anything()];
        [verifyCount(self.simpleReaction, times(1)) contentWithReactionBundleId:anything() recipeId:anything() completionHandler:anything()];
        XCTAssertTrue([content isKindOfClass:[NITSimpleNotification class]]);
        if ([content isKindOfClass:[NITSimpleNotification class]]) {
            NITSimpleNotification *simple = (NITSimpleNotification*)content;
            XCTAssertTrue([simple.message isEqualToString:@"Hello World!"]);
        }
        [expectation fulfill];
    }];
    
    XCTAssertTrue(processable);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

// MARK: - Utils

- (void)setRecipesManagerProcessRecipeWithReactionPluginId:(NSString*)reactionPluginId {
    [givenVoid([self.recipesManager processRecipe:anything() completion:anything()]) willDo:^id _Nonnull(NSInvocation * _Nonnull invocation) {
        NITRecipe *recipe = [[NITRecipe alloc] init];
        NSString *recipeId = [invocation mkt_arguments][0];
        recipe.ID = recipeId;
        recipe.reactionPluginId = reactionPluginId;
        
        ProcessRecipeBlock block = [invocation mkt_arguments][1];
        block(recipe, nil);
        return nil;
    }];
}

@end
