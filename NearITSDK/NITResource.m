//
//  NITResource.m
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITResource.h"
#import "NITJSONAPIResource.h"

#define ResourceKey @"resource"

@implementation NITResource

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.resourceObject = [aDecoder decodeObjectForKey:ResourceKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.resourceObject forKey:ResourceKey];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

/** Dictionary for attributes mapping, if you want to change a property name and map to attributes, subclass this method, otherwise leave as it is
 *  Example: you have an attribute (or relationship) named "fullName" in a json api, but you want to call it "completeName", so you create a dictionary like this @{"fullName" => "completeName"}
 */
- (NSDictionary*)attributesMap {
    return [NSDictionary dictionary];
}

- (NSString*)ID {
    return self.resourceObject.ID;
}

- (void)setID:(NSString*)ID {
    if (self.resourceObject == nil) {
        self.resourceObject = [[NITJSONAPIResource alloc] init];
    }
    self.resourceObject.ID = ID;
}

@end
