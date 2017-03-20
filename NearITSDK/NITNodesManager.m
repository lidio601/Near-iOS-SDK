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

@interface NITNodesManager()

@property (nonatomic, strong) NSArray<NITNode*> *nodes;

@end

@implementation NITNodesManager

- (void)parseAndSetNodes:(NITJSONAPI *)jsonApi {
    if (jsonApi == nil) {
        return;
    }
    
    [jsonApi registerClass:[NITGeofenceNode class] forType:@"geofence_nodes"];
    [jsonApi registerClass:[NITBeaconNode class] forType:@"beacon_nodes"];
    
    self.nodes = [jsonApi parseToArrayOfObjects];
}

- (NSArray<NITNode *> *)roots {
    if (self.nodes) {
        return self.nodes;
    }
    return [NSArray array];
}

- (NITNode *)findNodeWithID:(NSString *)ID {
    return [self findNodeWithID:ID inNodes:self.nodes];
}

- (NITNode*)findNodeWithID:(NSString *)ID inNodes:(NSArray<NITNode*>*)nodes {
    NITNode *foundNode = nil;
    for (NITNode *node in nodes) {
        if ([[node ID] isEqualToString:ID]) {
            foundNode = node;
            break;
        } else if ([node.children count] > 0) {
            foundNode = [self findNodeWithID:ID inNodes:node.children];
            if (foundNode) {
                break;
            }
        }
    }
    return foundNode;
}

- (NSArray<NITNode *> *)siblingsWithNode:(NITNode *)node {
    if (node.parent == nil) {
        NSMutableArray<NITNode*>* siblings = [[NSMutableArray alloc] init];
        for(NITNode *rootNode in [self roots]) {
            if(![node.ID isEqualToString:rootNode.ID]) {
                [siblings addObject:rootNode];
            }
        }
        return [NSArray arrayWithArray:siblings];
    } else if(node.parent.children) {
        NSMutableArray<NITNode*>* siblings = [[NSMutableArray alloc] init];
        for(NITNode *childNode in node.parent.children) {
            if(![node.ID isEqualToString:childNode.ID]) {
                [siblings addObject:childNode];
            }
        }
        return [NSArray arrayWithArray:siblings];
    } else {
        return [NSArray array];
    }
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

@end
