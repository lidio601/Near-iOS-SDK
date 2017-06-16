//
//  NITTimeBandEvaluator.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/06/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITDateManager;

@interface NITTimeBandEvaluator : NSObject

- (instancetype _Nonnull)initWithDateManager:(NITDateManager* _Nonnull)dateManager;
- (BOOL)isInTimeBandWithFromHour:(NSString* _Nullable)fromHour toHour:(NSString* _Nullable)toHour;
- (void)setTimeZone:(NSTimeZone * _Nonnull)timeZone;

@end
