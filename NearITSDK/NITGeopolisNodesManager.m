//
//  NITGeopolisNodesManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 14/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisNodesManager.h"
#import "NITNode.h"
#import "NITBeaconNode.h"

@implementation NITGeopolisNodesManager

- (NSArray<NITNode *> *)statelessMonitoredNodesOnEnterWithId:(NSString *)nodeId {
    NSMutableArray<NITNode*> *nodes = [[NSMutableArray alloc] init];
    
    NITNode *node = [self nodeWithID:nodeId];
    if (node != nil) {
        if (![node isKindOfClass:[NITBeaconNode class]] || ![node isLeaf]) {
            NSArray<NITNode*> *siblings = [self siblingsWithNode:node];
            [nodes addObjectsFromArray:siblings];
            if ([node isKindOfClass:[NITBeaconNode class]] && node.identifier) {
                // The child must not be monitored
            } else if (node.children != nil && [node.children count] > 0) {
                [nodes addObjectsFromArray:node.children];
            }
        }
    }
    
    return [NSArray arrayWithArray:nodes];
}

- (NSArray<NITNode*> *)statelessMonitoredNoesOnExitWithId:(NSString*)nodeId {
    NSMutableArray<NITNode*> *nodes = [[NSMutableArray alloc] init];
    
    NITNode *node = [self nodeWithID:nodeId];
    if (node != nil) {
        if (![node isKindOfClass:[NITBeaconNode class]] || ![node isLeaf]) {
            if (node.parent) {
                NSArray<NITNode*> *siblings = [self siblingsWithNode:node.parent];
                [nodes addObjectsFromArray:siblings];
                [nodes addObjectsFromArray:node.parent.children];
            } else {
                [nodes addObjectsFromArray:[self roots]];
            }
        }
    }
    
    return [NSArray arrayWithArray:nodes];
}

- (NSArray<NITNode *> *)statelessRangedNodesOnEnterWithId:(NSString *)nodeId {
    NSMutableArray<NITNode*> *nodes = [[NSMutableArray alloc] init];
    
    NITNode *node = [self nodeWithID:nodeId];
    if (node != nil) {
        if (node.identifier && [node isKindOfClass:[NITBeaconNode class]]) {
            [nodes addObject:node];
        }
    }
    
    return [NSArray arrayWithArray:nodes];
}

@end
