//
//  NITTestLogger.m
//  NearITSDK
//
//  Created by Francesco Leoni on 20/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestLogger.h"

@implementation NITTestLogger

- (instancetype)init {
    self = [super init];
    if (self) {
        self.logs = [[NSMutableArray alloc] init];
    }
    return self;
}

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
    NSString *log = [NSString stringWithFormat:@"[%@] %@: %@", thresold.uppercaseString, tag, message];
    [self.logs addObject:log];
}

@end
