//
//  NITTestCase.m
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestCase.h"

@implementation NITTestCase

- (NITRecipe*)recipeWithContentsOfFile:(NSString*)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    
    [jsonApi registerClass:[NITRecipe class] forType:@"recipes"];
    [jsonApi registerClass:[NITCoupon class] forType:@"coupons"];
    [jsonApi registerClass:[NITClaim class] forType:@"claims"];
    [jsonApi registerClass:[NITImage class] forType:@"images"];
    
    NSArray<NITRecipe*> *recipes = [jsonApi parseToArrayOfObjects];
    XCTAssertTrue([recipes count] > 0);
    
    return [recipes objectAtIndex:0];
}

- (NITFeedback*)feedbackWithContentsOfFile:(NSString*)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    
    [jsonApi registerClass:[NITFeedback class] forType:@"feedbacks"];
    
    NSArray<NITFeedback*> *feedbacks = [jsonApi parseToArrayOfObjects];
    XCTAssertTrue([feedbacks count] > 0);
    
    return [feedbacks objectAtIndex:0];
}

- (NSArray<NITContent*>*)contentsWithContentsOfFile:(NSString*)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    XCTAssertNil(jsonApiError);
    
    [jsonApi registerClass:[NITContent class] forType:@"contents"];
    [jsonApi registerClass:[NITImage class] forType:@"images"];
    
    NSArray<NITContent*> *contents = [jsonApi parseToArrayOfObjects];
    XCTAssertTrue([contents count] > 0);
    
    return contents;
}

- (NITJSONAPI*)jsonApiWithContentsOfFile:(NSString*)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    
    NSError *jsonApiError;
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc ] initWithContentsOfFile:path error:&jsonApiError];
    return jsonApi;
}

- (NSDictionary *)jsonWithContentsOfFile:(NSString *)filename {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:filename ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
}

@end
