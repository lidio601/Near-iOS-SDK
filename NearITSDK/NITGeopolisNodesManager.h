//
//  NITGeopolisNodesManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 14/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNodesManager.h"

@class NITNode;

@interface NITGeopolisNodesManager : NITNodesManager

- (NSArray<NITNode*>* _Nonnull)monitoredNodesOnEnterWithId:(NSString* _Nonnull)nodeId;
- (NSArray<NITNode*>* _Nonnull)monitoredNodesOnExitWithId:(NSString* _Nonnull)nodeId;
- (NSArray<NITNode*>* _Nonnull)statelessMonitoredNodesOnEnterWithId:(NSString* _Nonnull)nodeId;
- (NSArray<NITNode*>* _Nonnull)statelessMonitoredNoesOnExitWithId:(NSString* _Nonnull)nodeId;
- (NSArray<NITNode*>* _Nonnull)statelessRangedNodesOnEnterWithId:(NSString* _Nonnull)nodeId;

@end
