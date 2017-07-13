//
//  NITNetworkManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNetworkManager.h"
#import "NITConfiguration.h"
#import "NITJSONAPI.h"
#import "NITConstants.h"

#define LogResponseOnError YES

@interface NITNetworkManager()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NITNetworkManager

- (NSURLSession*)defaultSession {
    if (self.session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.session = [NSURLSession sessionWithConfiguration:config];
    }
    return self.session;
}

- (void)makeRequestWithURLRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler {
    NSURLSessionDataTask *task = [[self defaultSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            completionHandler(data, error);
        } else {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
                    NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
                    [errorUserInfo setObject:@"HTTP Status 500" forKey:NSLocalizedDescriptionKey];
                    if(error) {
                        [errorUserInfo setObject:error forKey:NSUnderlyingErrorKey];
                        [errorUserInfo setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:NITHttpStatusCode];
                    }
                    NSError *statusError = [NSError errorWithDomain:NITNetowkrErrorDomain code:1 userInfo:errorUserInfo];
                    if (LogResponseOnError) {
                        NSLog(@"*** %@ ***", request.URL);
                        NSLog(@"-----> Headers: %@", request.allHTTPHeaderFields);
                        NSLog(@"*** Response info ***");
                        NSLog(@"-----> Code: %ld", (long)httpResponse.statusCode);
                        NSLog(@"-----> Headers: %@", httpResponse.allHeaderFields);
                        NSLog(@"-----> Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        NSLog(@"*******");
                    }
                    completionHandler(data, statusError);
                } else {
                    completionHandler(data, nil);
                }
            } else {
                completionHandler(data, nil);
            }
        }
    }];
    [task resume];
}

- (void)makeRequestWithURLRequest:(NSURLRequest *)request jsonApicompletionHandler:(void (^)(NITJSONAPI * _Nullable json, NSError * _Nullable error))completionHandler {
    [self makeRequestWithURLRequest:request completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        if(error) {
            completionHandler(nil, error);
        } else {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                completionHandler(nil, jsonError);
            } else {
                NITJSONAPI *jsonApi = [[NITJSONAPI alloc] initWithDictionary:json];
                completionHandler(jsonApi, nil);
            }
        }
    }];
}

@end
