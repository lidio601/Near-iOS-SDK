//
//  NITJSONAPIResource.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITJSONAPIResource : NSObject

@property (nonatomic, strong) id _Nullable ID;
@property (nonatomic, strong) NSString * _Nonnull type;

- (void)addAttributeObject:(id _Nonnull)object forKey:(NSString* _Nonnull)key;
- (NSInteger)attributesCount;
- (NSDictionary* _Nonnull)toDictionary;
+ (NITJSONAPIResource* _Nonnull)resourceObjectWithDictiornary:(NSDictionary* _Nonnull)dictionary;

@end
