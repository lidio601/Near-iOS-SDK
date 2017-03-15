//
//  NITJSONAPI.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NITJSONAPIResource;

@interface NITJSONAPI : NSObject

- (instancetype _Nonnull)init;
+ (instancetype _Nonnull)jsonAPIWithDictionary:(NSDictionary* _Nonnull)json;

- (void)setDataWithResourceObject:(NITJSONAPIResource* _Nonnull)resourceObject;
- (NITJSONAPIResource* _Nullable)firstResourceObject;
- (NSDictionary* _Nonnull)toDictionary;

@end
