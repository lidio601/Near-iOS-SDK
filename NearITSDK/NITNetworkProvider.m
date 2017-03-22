//
//  NITNetworkProvider.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNetworkProvider.h"
#import "NITConfiguration.h"
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"

#define NITApiVersion @"2"
#define BASE_URL @"https://dev-api.nearit.com"

@implementation NITNetworkProvider

+ (NSURLRequest *)recipesList {
    return [NITNetworkProvider requestWithPath:@"/recipes"];
}

+ (NSURLRequest *)newProfileWithAppId:(NSString*)appId {
    NSMutableURLRequest *request =[NITNetworkProvider requestWithPath:@"/plugins/congrego/profiles"];
    [request setHTTPMethod:@"POST"];
    
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"profiles";
    [resource addAttributeObject:appId forKey:@"app_id"];
    [jsonApi setDataWithResourceObject:resource];
    
    NSDictionary *json = [jsonApi toDictionary];
    NSData *jsonDataBody = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonDataBody];
    
    return request;
}

+ (NSURLRequest *)geopolisNodes {
    return [NITNetworkProvider requestWithPath:[NSString stringWithFormat:@"/plugins/geopolis/nodes?filter[app_id]=%@&include=**.children", [[NITConfiguration defaultConfiguration] appId]]];
}

+ (NSMutableURLRequest*)requestWithPath:(NSString*)path {
    NSURL *url = [NSURL URLWithString:[BASE_URL stringByAppendingString:path]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [NITNetworkProvider setNearITHeaders:request];
    return request;
}

+ (void)setNearITHeaders:(NSMutableURLRequest*)request {
    
    [request setValue:[NSString stringWithFormat:@"bearer %@", [[NITConfiguration defaultConfiguration] apiKey]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Accept"];
    [request setValue:NITApiVersion forHTTPHeaderField:@"X-API-Version"];
}

@end
