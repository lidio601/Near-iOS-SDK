//
//  NITNodesManager.h
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NITNode;
@class NITJSONAPI;

@interface NITNodesManager : NSObject

- (void)parseAndSetNodes:(NITJSONAPI* _Nullable)jsonApi;
- (NSArray<NITNode*>* _Nonnull)roots;
- (NITNode* _Nullable)findNodeWithID:(NSString* _Nonnull)ID;
- (NSArray<NITNode*>* _Nonnull)siblingsWithNode:(NITNode* _Nonnull)node;
- (void)traverseNodesWithBlock:(void (^_Nonnull)(NITNode* _Nonnull node))block;
- (NSArray<NITNode*>* _Nonnull)nodes;

@end
