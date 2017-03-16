//
//  NITNode.h
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITResource.h"

@interface NITNode : NITResource

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NITNode *parent;
@property (nonatomic, strong) NSArray<NITResource*> *children;

@end
