//
//  NITResource.m
//  NearITSDK
//
//  Created by Francesco Leoni on 16/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITResource.h"
#import "NITJSONAPIResource.h"

@implementation NITResource

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

@end
