//
//  NITTestCase.h
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITRecipe.h"
#import "NITContent.h"
#import "NITImage.h"
#import "NITCoupon.h"
#import "NITJSONAPI.h"

@interface NITTestCase : XCTestCase

- (NITRecipe*)recipeWithContentsOfFile:(NSString*)filename;
- (NSArray<NITContent*>*)contentsWithContentsOfFile:(NSString*)filename;
- (NITJSONAPI*)jsonApiWithContentsOfFile:(NSString*)filename;

@end
