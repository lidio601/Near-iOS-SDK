//
//  NITTestCase.h
//  NearITSDK
//
//  Created by Francesco Leoni on 28/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NITRecipe.h"
#import "NITJSONAPI.h"

@interface NITTestCase : XCTestCase

- (NITRecipe*)recipeWithContentsOfFile:(NSString*)filename;

@end