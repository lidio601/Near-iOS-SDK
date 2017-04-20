//
//  NITTestLogger.h
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITLogger.h"

@interface NITTestLogger : NSObject<NITLogger>

@property (nonatomic, strong) NSMutableArray<NSString*>* _Nonnull logs;

@end
