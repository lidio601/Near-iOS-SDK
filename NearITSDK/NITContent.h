//
//  NITContent.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITResource.h"

@interface NITContent : NITResource

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSArray<NITResource*> *images;

@end
