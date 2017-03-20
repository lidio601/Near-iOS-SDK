//
//  NITNode.m
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNode.h"
#import "NITBeaconNode.h"

@interface NITNode()

@property (nonatomic) NSInteger childIndex;

@end

@implementation NITNode

- (instancetype)init {
    self = [super init];
    if(self) {
        self.childIndex = 0;
    }
    return self;
}

- (CLRegion *)createRegion {
    return nil;
}

- (NITNode *)firstChild {
    self.childIndex = 0;
    if(self.children == nil || [self.children count] == 0) {
        return nil;
    } else {
        return [self.children objectAtIndex:0];
    }
}

- (NITNode *)nextChild {
    self.childIndex++;
    if(self.children == nil || [self.children count] == 0) {
        return nil;
    } else if(self.childIndex >= [self.children count]) {
        return nil;
    } else {
        return [self.children objectAtIndex:self.childIndex];
    }
}

- (NITNode *)nextSibling {
    if (self.parent == nil) {
        return nil;
    } else {
        return [self.parent nextChild];
    }
}

- (BOOL)isLeaf {
    if (self.children == nil || [self.children count] == 0) {
        return YES;
    }
    return NO;
}

- (NSInteger)parentsCount {
    NSInteger count = 0;
    
    NITNode *parent = self.parent;
    while (parent != nil) {
        count++;
        parent = parent.parent;
    }
    
    return count;
}

- (NSInteger)parentsBeaconRegionsCount {
    NSInteger count = 0;
    
    NITNode *parent = self.parent;
    while (parent != nil) {
        if ([parent isKindOfClass:[NITBeaconNode class]]) {
            count++;
        }
        parent = parent.parent;
    }
    
    return count;
}

@end
