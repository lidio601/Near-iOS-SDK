//
//  NITJSONAPI.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"

@interface NITJSONAPI()

@property (nonatomic) NSMutableDictionary* internalJson;
@property (nonatomic, strong) NSMutableArray<NITJSONAPIResource*> *resources;

@end

/// Class for handling JSON API
@implementation NITJSONAPI

/// Use it for an empty json
- (instancetype)init {
    self = [super init];
    if (self) {
        self.internalJson = [[NSMutableDictionary alloc] init];
        self.resources = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 * Instanciate an object with an initial dictionary
 * @param json Your json
 */
+ (instancetype)jsonAPIWithDictionary:(NSDictionary*)json {
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    //jsonApi.internalJson = [[NSMutableDictionary alloc] initWithDictionary:json];
    id data = [json objectForKey:@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
        for(NSDictionary *resDict in data) {
            NITJSONAPIResource *res = [NITJSONAPIResource resourceObjectWithDictiornary:resDict];
            [jsonApi.resources addObject:res];
        }
    } else {
        NITJSONAPIResource *res = [NITJSONAPIResource resourceObjectWithDictiornary:data];
        [jsonApi.resources addObject:res];
    }
    
    return jsonApi;
}

/**
 * Set the "data" with one resource object
 * @param resourceObject Resource object created externally
 */
- (void)setDataWithResourceObject:(NITJSONAPIResource *)resourceObject {
    [self.resources removeAllObjects];
    [self.resources addObject:resourceObject];
}

- (NITJSONAPIResource *)firstResourceObject {
    if ([self.resources count] > 0) {
        return [self.resources objectAtIndex:0];
    }
    return nil;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if ([self.resources count] == 1) {
        NITJSONAPIResource *res = [self.resources objectAtIndex:0];
        [dict setObject:[res toDictionary] forKey:@"data"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
