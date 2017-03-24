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

@property (nonatomic, strong) NSString * _Nullable name;
@property (nonatomic, strong) NSDictionary<NSString*, id> * _Nullable notification;
@property (nonatomic, strong) NSDictionary<NSString*, id> * _Nullable labels;
@property (nonatomic, strong) NSString * _Nonnull pulsePluginId;
@property (nonatomic, strong) NSString * _Nonnull reactionPluginId;
@property (nonatomic, strong) NITResource * _Nonnull pulseBundle;
@property (nonatomic, strong) NITResource * _Nonnull pulseAction;

- (BOOL)isEvaluatedOnline;
- (BOOL)isForeground;
- (NSString* _Nullable)notificationTitle;
- (NSString* _Nullable)notificationBody;

@end
