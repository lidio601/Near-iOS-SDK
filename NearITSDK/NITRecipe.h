//
//  NITRecipe.h
//  NearITSDK
//
//  Created by Francesco Leoni on 22/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITResource.h"

@class NITPulseBundle;

@interface NITRecipe : NITResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary<NSString*, id> *notification;
@property (nonatomic, strong) NSDictionary<NSString*, id> *labels;
@property (nonatomic, strong) NSString *pulsePluginId;
@property (nonatomic, strong) NITResource *pulseBundle;
@property (nonatomic, strong) NITResource *pulseAction;

- (BOOL)isEvaluatedOnline;

@end
