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
#import "NITNetworkMock.h"

#define NITNetowkrErrorDomain @"com.nearit.network"
#define LogResponseOnError YES

static NSURLSession *session;
static NITNetworkManager *sharedNetwork;

@interface NITNetworkManager()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation NITNetworkManager

+ (NITNetworkManager *)sharedInstance {
    if (sharedNetwork == nil) {
        sharedNetwork = [NITNetworkManager new];
    }
    return sharedNetwork;
}

- (NSURLSession*)defaultSession {
    if (self.session == nil) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self.session;
}

- (void)makeRequestWithURLRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSError * _Nullable))completionHandler {
    NSData *data = [[NITNetworkMock sharedInstance] dataWithRequest:request];
    if(data) {
        completionHandler(data, nil);
        return;
    }
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
