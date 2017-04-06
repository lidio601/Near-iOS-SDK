//
//  NITNodesManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNodesManager.h"
#import "NITJSONAPI.h"
#import "NITNode.h"
#import "NITBeaconNode.h"
#import "NITGeofenceNode.h"
#import <CoreLocation/CoreLocation.h>

@interface NITNodesManager()

@property (nonatomic, strong) NSArray<NITNode*> *nodes;

@end

@implementation NITNodesManager

- (NSArray<NITNode*>*)setNodesWithJsonApi:(NITJSONAPI *)jsonApi {
    if (jsonApi == nil) {
        return [NSArray array];
    }
    
    [jsonApi registerClass:[NITGeofenceNode class] forType:@"geofence_nodes"];
    [jsonApi registerClass:[NITBeaconNode class] forType:@"beacon_nodes"];
    
    self.nodes = [jsonApi parseToArrayOfObjects];
    return self.nodes;
}

- (NSArray<NITNode *> *)roots {
    if (self.nodes) {
        return self.nodes;
    }
    return [NSArray array];
}

- (NITNode *)nodeWithID:(NSString *)ID {
    return [self nodeWithID:ID inNodes:self.nodes];
}

- (NITNode*)nodeWithID:(NSString *)ID inNodes:(NSArray<NITNode*>*)nodes {
    NITNode *foundNode = nil;
    for (NITNode *node in nodes) {
        if ([[node ID] isEqualToString:ID]) {
            foundNode = node;
            break;
        } else if ([node.children count] > 0) {
            foundNode = [self nodeWithID:ID inNodes:node.children];
            if (foundNode) {
                break;
            }
        }
    }
    return foundNode;
}

- (NSArray<NITNode *> *)siblingsWithNode:(NITNode *)node {
    if (node == nil) {
        return [NSArray array];
    } else if (node.parent == nil) {
        return [self roots];
    } else if(node.parent.children) {
        return node.parent.children;
    } else {
        return [NSArray array];
    }
}

- (NSInteger)countSiblingsAndChildrenBeaconNode:(NITNode*)node {
    NSInteger counter = 0;
    NSArray<NITNode*>* siblings = [self siblingsWithNode:node];
    for(NITNode *node in siblings) {
        if([node isKindOfClass:[NITBeaconNode class]]) {
            counter++;
        }
    }
    for(NITNode *childNode in node.children) {
        if([childNode isKindOfClass:[NITBeaconNode class]]) {
            counter++;
        }
    }
    return counter;
}

- (NSInteger)countIdentifierBeaconNodeWithNode:(NITNode*)node {
    NSInteger counter = 0;
    if ([node isKindOfClass:[NITBeaconNode class]] && node.identifier != nil) {
        counter++;
    }
    NITNode *parent = node.parent;
    while(parent != nil) {
        if ([parent isKindOfClass:[NITBeaconNode class]] && parent.identifier != nil) {
            counter++;
        }
        parent = parent.parent;
    }
    
    return counter;
}

- (void)traverseNodesWithBlock:(void (^)(NITNode *node))block {
    NSMutableArray<NITNode*> *nodes = [[NSMutableArray alloc] init];
    for(NITNode *node in [self roots]) {
        [nodes addObject:node];
        [self traverseWithNode:node array:nodes];
    }
    
    for (NITNode *node in nodes) {
        block(node);
    }
}

- (void)traverseWithNode:(NITNode*)parent array:(NSMutableArray<NITNode*>*)array {
    if ([parent.children count] == 0) {
        return;
    }
    
    for (NITNode *node = [parent firstChild]; node != nil; node = [node nextSibling]) {
        [array addObject:node];
        [self traverseWithNode:node array:array];
    }
}

- (NITBeaconNode *)beaconNodeWithBeacon:(CLBeacon *)beacon inChildren:(NSArray<NITNode *> *)children {
    NITBeaconNode *beaconNode = nil;
    for(NITNode *node in children) {
        if ([node isKindOfClass:[NITBeaconNode class]]) {
            NITBeaconNode *bNode = (NITBeaconNode*)node;
            if ([beacon.minor integerValue] == [bNode.minor integerValue]) {
                beaconNode = bNode;
            }
        }
    }
    return beaconNode;
}

@end
