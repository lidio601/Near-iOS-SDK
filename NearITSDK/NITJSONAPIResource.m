//
//  NITJSONAPIResource.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITJSONAPIResource.h"

@interface NITJSONAPIResource()

@property (nonatomic, strong) NSMutableDictionary<NSString*, id> *attributes;

@end

@implementation NITJSONAPIResource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.attributes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addAttributeObject:(id)object forKey:(NSString*)key {
    [self.attributes setObject:object forKey:key];
}

- (NSInteger)attributesCount {
    return [self.attributes count];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary<NSString*, id> *dict = [[NSMutableDictionary alloc] init];
    
    if (self.ID) {
        [dict setObject:self.ID forKey:@"id"];
    }
    [dict setObject:self.type forKey:@"type"];
    
    if ([self.attributes count] > 0) {
        [dict setObject:self.attributes forKey:@"attributes"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (NITJSONAPIResource *)resourceObjectWithDictiornary:(NSDictionary *)dictionary {
    NITJSONAPIResource *resourceObject = [[NITJSONAPIResource alloc] init];
    
    resourceObject.ID = [dictionary objectForKey:@"id"];
    resourceObject.type = [dictionary objectForKey:@"type"];
    NSDictionary<NSString*, id> *attributes = [dictionary objectForKey:@"attributes"];
    if (attributes) {
        resourceObject.attributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    }
    
    return resourceObject;
}

@end
