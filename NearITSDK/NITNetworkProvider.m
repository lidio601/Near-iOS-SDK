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

+ (NSURLRequest *)recipesProcessList {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:@"/recipes/process"];
    [request setHTTPMethod:@"POST"];
    
    NITConfiguration *config = [NITConfiguration defaultConfiguration];
    NITJSONAPI *jsonApi = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"evaluation";
    if (config.appId && config.profileId && config.installationId) {
        NSMutableDictionary<NSString*, NSString*> *core = [[NSMutableDictionary alloc] init];
        [core setObject:config.profileId forKey:@"profile_id"];
        [core setObject:config.installationId forKey:@"installation_id"];
        [core setObject:config.appId forKey:@"app_id"];
        [resource addAttributeObject:core forKey:@"core"];
    }
    [jsonApi setDataWithResourceObject:resource];
    NSDictionary *json = [jsonApi toDictionary];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];
    
    return request;
}

+ (NSURLRequest *)newProfileWithAppId:(NSString*)appId {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:@"/plugins/congrego/profiles"];
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

+ (NSURLRequest *)newInstallationWithJsonApi:(NITJSONAPI *)jsonApi {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:@"/installations"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *json = [jsonApi toDictionary];
    NSData *jsonDataBody = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonDataBody];
    
    return request;
}

+ (NSURLRequest *)updateInstallationWithJsonApi:(NITJSONAPI *)jsonApi installationId:(NSString *)installationId {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:[NSString stringWithFormat:@"/installations/%@", installationId]];
    [request setHTTPMethod:@"PUT"];
    
    NSDictionary *json = [jsonApi toDictionary];
    NSData *jsonDataBody = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonDataBody];
    return request;
}

+ (NSURLRequest *)contentWithBundleId:(NSString *)bundleId {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:[NSString stringWithFormat:@"/plugins/content-notification/contents/%@?include=images,audio,upload", bundleId]];
    return request;
}

+ (NSURLRequest*)contents {
    NSMutableURLRequest *request = [NITNetworkProvider requestWithPath:@"/plugins/content-notification/contents?include=images,audio,upload"];
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
