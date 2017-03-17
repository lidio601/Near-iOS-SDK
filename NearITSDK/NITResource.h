//
//  NITResource.h
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NITJSONAPIResource;

@interface NITResource : NSObject

@property (nonatomic, strong) NITJSONAPIResource* _Nullable resourceObject;

- (NSDictionary* _Nonnull)attributesMap;
- (NSString* _Nullable)ID;

@end
