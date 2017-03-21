//
//  NITGeopolisManager+Tests.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITGeopolisManager+Tests.h"
#import "NITNodesManager.h"
#import "NITNode.h"
#import <CoreLocation/CoreLocation.h>

NSErrorDomain const NITGeopolisErrorDomain = @"com.nearit.geopolis";
NSString* const NodeKey = @"node";

@interface NITGeopolisManager()

- (void)stepInRegion:(CLRegion*)region;
- (void)stepOutRegion:(CLRegion*)region;
- (NITNodesManager*)nodesManager;
- (NSArray<CLRegion*>*)monitoredRegions;
- (NSArray<CLRegion*>*)rangedRegions;

@end

@implementation NITGeopolisManager (Tests)

- (void)testStepInRegion:(CLRegion*)region {
    [self stepInRegion:region];
}

- (void)testStepOutRegion:(CLRegion*)region {
    [self stepOutRegion:region];
}

- (void)testAllNodes:(NSError**)anError {
    for (NITNode *node in [[self nodesManager] nodes]) {
        NSError *nodeError;
        BOOL result = [self testWithNode:node error:&nodeError];
        if (nodeError) {
            *anError = nodeError;
            break;
        } else if(!result) {
            *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Generic error"}];
            break;
        }
    }
}

- (BOOL)testWithNode:(NITNode*)node error:(NSError**)anError {
    [self testStepInRegion:[node createRegion]];
    NSError *nodeError;
    if([self testVerifyMonitoringWithNode:node error:&nodeError]) {
        NITNode *firstChild = [node firstChild];
        NITNode *nextSibling = [node nextSibling];
        if (firstChild) {
            NSError *childError;
            if([self testWithNode:firstChild error:&childError]) {
                if (nextSibling) {
                    NSError *siblingError;
                    [self testStepOutRegion:[node createRegion]];
                    if(![self testForStepOutWithNode:node]) {
                        *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:10 userInfo:@{NSLocalizedDescriptionKey:@"Step out failed"}];
                        return NO;
                    }
                    if([self testWithNode:nextSibling error:&siblingError]) {
                        return YES;
                    } else {
                        *anError = siblingError;
                        return NO;
                    }
                } else {
                    [self testStepOutRegion:[node createRegion]];
                    if(![self testForStepOutWithNode:node]) {
                        *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:10 userInfo:@{NSLocalizedDescriptionKey:@"Step out failed"}];
                        return NO;
                    }
                    return YES;
                }
            } else {
                *anError = childError;
                return NO;
            }
        } else if(nextSibling) {
            NSError *siblingError;
            if([self testWithNode:nextSibling error:&siblingError]) {
                *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:10 userInfo:@{NSLocalizedDescriptionKey:@"Step out failed"}];
                return YES;
            } else {
                *anError = siblingError;
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        *anError = nodeError;
        return NO;
    }
    return NO;
}

- (BOOL)testForStepOutWithNode:(NITNode*)node {
    if (node.parent == nil) {
        return YES;
    }
    
    CLRegion *region = [node createRegion];
    if ([[self monitoredRegions] containsObject:region]) {
        return NO;
    }
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        if([self.rangedRegions containsObject:region]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)testVerifyMonitoringWithNode:(NITNode*)node error:(NSError**)anError {
    CLRegion *nodeRegion = [node createRegion];
    
    if ([nodeRegion isKindOfClass:[CLBeaconRegion class]]) {
        
        if ([node isLeaf]) {
            return YES;
        }
        
        NSInteger nodesCount = [self.nodesManager countIdentifierBeaconNodeWithNode:node];
        if ([self.rangedRegions count] != nodesCount) {
            if (anError != NULL) {
                NSString *description = [NSString stringWithFormat:@"The number of rangedRegions is wrong: RR => %lu, NC => %lu", (unsigned long)[self.rangedRegions count], (unsigned long)nodesCount];
                *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
            }
            return NO;
        }
        
        if (nodesCount == 0) {
            return YES;
        }
        
        CLRegion *foundRegion = nil;
        NSArray<CLRegion*> *regions = self.rangedRegions;
        for (CLRegion *region in regions) {
            if([region.identifier isEqualToString:nodeRegion.identifier]) {
                foundRegion = region;
                break;
            }
        }
        
        if(foundRegion == nil) {
            NSString *description = [NSString stringWithFormat:@"No region found in ranging"];
            *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
            return NO;
        }
        
        return YES;
    } else {
        NSInteger nodesCount = [[self.nodesManager siblingsWithNode:node] count] + [node.children count];
        if ([self.monitoredRegions count] != nodesCount) {
            if (anError != NULL) {
                NSString *description = [NSString stringWithFormat:@"The number of monitoredRegions is wrong: MR => %lu, NC => %lu", (unsigned long)[self.monitoredRegions count], (unsigned long)nodesCount];
                *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description, NodeKey: node}];
            }
            return NO;
        }
        
        NSMutableDictionary<NSString*, NSNumber*> *regionsMap = [[NSMutableDictionary alloc] init];
        for(CLRegion *region in self.monitoredRegions) {
            [regionsMap setObject:[NSNumber numberWithBool:NO] forKey:region.identifier];
        }
        
        if ([regionsMap objectForKey:node.ID]) {
            [regionsMap setObject:[NSNumber numberWithBool:YES] forKey:node.ID];
        }
        
        for(NITNode *child in node.children) {
            if ([regionsMap objectForKey:child.ID]) {
                [regionsMap setObject:[NSNumber numberWithBool:YES] forKey:child.ID];
            }
        }
        
        for(NSString *key in regionsMap) {
            if (![regionsMap objectForKey:key]) {
                if (anError != NULL) {
                    NSString *description = [NSString stringWithFormat:@"The regions map is wrong"];
                    *anError = [[NSError alloc] initWithDomain:NITGeopolisErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:description}];
                }
                return NO;
            }
        }
        
        return YES;
    }
    return NO;
}

@end
