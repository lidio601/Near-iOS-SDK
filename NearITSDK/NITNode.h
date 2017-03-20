//
//  NITNode.h
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITResource.h"
@class CLRegion;

@interface NITNode : NITResource

@property (nonatomic, strong) NSString* _Nullable identifier;
@property (nonatomic, strong) NITNode* _Nullable parent;
@property (nonatomic, strong) NSArray<NITNode*>* _Nullable children;

- (CLRegion* _Nullable)createRegion;
- (NITNode* _Nullable)firstChild;
- (NITNode* _Nullable)nextSibling;
- (BOOL)isLeaf;
- (NSInteger)parentsCount;
- (NSInteger)parentsBeaconRegionsCount;

@end
