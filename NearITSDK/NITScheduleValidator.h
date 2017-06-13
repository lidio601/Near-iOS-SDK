//
//  NITScheduleValidator.h
//  NearITSDK
//
//  Created by Francesco Leoni on 12/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITValidating.h"

@class NITDateManager;

@interface NITScheduleValidator : NSObject<NITValidating>

- (instancetype _Nonnull)initWithDateManager:(NITDateManager* _Nonnull)dateManager;

@end
