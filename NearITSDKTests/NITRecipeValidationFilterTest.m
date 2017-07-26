//
//  NITRecipeValidationFilterTest.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "NITTestCase.h"
#import "NITRecipeValidationFilter.h"
#import "NITTestValidator.h"

@interface NITRecipeValidationFilterTest : NITTestCase

@property (nonatomic, strong) NITRecipeValidationFilter *validationFilter;
@property (nonatomic, strong) NITTestValidator *firstValidator;
@property (nonatomic, strong) NITTestValidator *secondValidator;
@property (nonatomic, strong) NITTestValidator *thirdValidator;

@end

@implementation NITRecipeValidationFilterTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.firstValidator = mock([NITTestValidator class]);
    self.secondValidator = mock([NITTestValidator class]);
    self.thirdValidator = mock([NITTestValidator class]);
    
    NSArray<id<NITValidating>> *validators = @[self.firstValidator, self.secondValidator, self.thirdValidator];
    self.validationFilter = [[NITRecipeValidationFilter alloc] initWithValidators:validators];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoRecipesArePassed {
    NSArray *filtered = [self.validationFilter filterRecipes:@[]];
    XCTAssertTrue([filtered count] == 0);
}

- (void)testAllValidatorsAlwayReturnTrue {
    [given([self.firstValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    [given([self.secondValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    [given([self.thirdValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    NSArray *recipes = @[[NITRecipe new], [NITRecipe new], [NITRecipe new]];
    NSArray *filtered = [self.validationFilter filterRecipes:recipes];
    XCTAssertTrue([filtered count] == 3);
}

- (void)testOneValidatorAlwaysReturnFalse {
    [given([self.firstValidator isValidWithRecipe:anything()]) willReturnBool:NO];
    [given([self.secondValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    [given([self.thirdValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    NSArray *recipes = @[[NITRecipe new], [NITRecipe new], [NITRecipe new]];
    NSArray *filtered = [self.validationFilter filterRecipes:recipes];
    XCTAssertTrue([filtered count] == 0);
}

- (void)testASingleRecipeShouldFail {
    NITRecipe *shouldFailRecipe = [[NITRecipe alloc] init];
    shouldFailRecipe.ID = @"shouldFail";
    NITRecipe *shouldPassRecipe = [[NITRecipe alloc] init];
    shouldPassRecipe.ID = @"shouldPass";
    [given([self.firstValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    [given([self.firstValidator isValidWithRecipe:sameInstance(shouldFailRecipe)]) willReturnBool:NO];
    [given([self.secondValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    [given([self.thirdValidator isValidWithRecipe:anything()]) willReturnBool:YES];
    NSArray *recipes = @[shouldFailRecipe, shouldPassRecipe];
    NSArray *filtered = [self.validationFilter filterRecipes:recipes];
    XCTAssertTrue([filtered count] == 1);
    assertThat(filtered, hasItem(shouldPassRecipe));
    assertThat(filtered, isNot(hasItem(shouldFailRecipe)));
}

- (void)testNoValidatorsAreSet {
    self.validationFilter = [[NITRecipeValidationFilter alloc] initWithValidators:@[]];
    NSArray *recipes = @[[NITRecipe new], [NITRecipe new], [NITRecipe new]];
    NSArray *filtered = [self.validationFilter filterRecipes:recipes];
    XCTAssertTrue([filtered count] == 3);
}

@end
