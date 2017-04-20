//
//  NITLog.m
//  NearITSDK
//
//  Created by Francesco Leoni on 13/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITLog.h"
#import "NITDefaultLogger.h"

static id<NITLogger> loggerInstance;
static NITLogLevel logLevel = NITLogLevelDebug;
static BOOL logEnabled = NO;

@implementation NITLog

+ (id<NITLogger>)logger {
    if (loggerInstance == nil) {
        loggerInstance = [[NITDefaultLogger alloc] init];
    }
    return loggerInstance;
}

+ (void)setLevel:(NITLogLevel)level {
    logLevel = level;
}

+ (void)setLogger:(id<NITLogger>)logger {
    loggerInstance = logger;
}

+ (void)setLogEnabled:(BOOL)enabled {
    logEnabled = enabled;
}

+ (BOOL)canLogWithLevel:(NITLogLevel)level {
    if (logEnabled && level >= logLevel) {
        return YES;
    }
    return NO;
}

void NITLogV(NSString * _Nonnull tag, NSString * _Nonnull format, ...) {
    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if ([NITLog canLogWithLevel:NITLogLevelVerbose]) {
        [[NITLog logger]  verboseWithTag:tag message:message];
    }
}

void NITLogD(NSString * _Nonnull tag, NSString * _Nonnull format, ...) {
    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if ([NITLog canLogWithLevel:NITLogLevelDebug]) {
        [[NITLog logger] debugWithTag:tag message:message];
    }
}

void NITLogI(NSString * _Nonnull tag, NSString * _Nonnull format, ...) {
    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if ([NITLog canLogWithLevel:NITLogLevelInfo]) {
        [[NITLog logger]  infoWithTag:tag message:message];
    }
}

void NITLogW(NSString * _Nonnull tag, NSString * _Nonnull format, ...) {
    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if ([NITLog canLogWithLevel:NITLogLevelWarning]) {
        [[NITLog logger]  warningWithTag:tag message:message];
    }
}

void NITLogE(NSString * _Nonnull tag, NSString * _Nonnull format, ...) {
    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if ([NITLog canLogWithLevel:NITLogLevelError]) {
        [[NITLog logger]  errorWithTag:tag message:message];
    }
}

@end
