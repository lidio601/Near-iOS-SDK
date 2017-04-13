//
//  NITDefaultLogger.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITDefaultLogger.h"

@implementation NITDefaultLogger

- (void)verboseWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithThresold:@"verbose" tag:tag message:message];
}

- (void)debugWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithThresold:@"debug" tag:tag message:message];
}

- (void)infoWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithThresold:@"info" tag:tag message:message];
}

- (void)warningWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithThresold:@"warning" tag:tag message:message];
}

- (void)errorWithTag:(NSString *)tag message:(NSString *)message {
    [self logWithThresold:@"error" tag:tag message:message];
}

- (void)logWithThresold:(NSString*)thresold tag:(NSString*)tag message:(NSString*)message {
    NSLog(@"[%@] %@: %@", thresold.uppercaseString, tag, message);
}

@end
