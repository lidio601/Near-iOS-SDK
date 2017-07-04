//
//  NITGeopolisRadar.h
//  NearITSDK
//
//  Created by Francesco Leoni on 04/07/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NITConstants.h"

@class NITGeopolisRadar;
@class NITNode;
@class NITGeopolisNodesManager;
@class CLLocationManager;

@protocol NITGeopolisRadarDelegate <NSObject>

- (void)geopolisRadar:(NITGeopolisRadar* _Nonnull)geopolisRadar didTriggerWithNode:(NITNode* _Nonnull)node event:(NITRegionEvent)event;

@end

@interface NITGeopolisRadar : NSObject

@property (nonatomic, weak) id<NITGeopolisRadarDelegate> _Nullable delegate;
@property (nonatomic, readonly) BOOL isStarted;

- (instancetype _Nonnull)initWithDelegate:(id<NITGeopolisRadarDelegate> _Nullable)delegate nodesManager:(NITGeopolisNodesManager* _Nonnull)nodesManager locationManager:(CLLocationManager* _Nonnull)locationManager;

- (BOOL)start;

@end
