//
//  NITSimpleNotification.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITSimpleNotification.h"

#define TitleKey @"title"
#define MessageKey @"message"

@implementation NITSimpleNotification

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.notificationTitle = [aDecoder decodeObjectForKey:TitleKey];
        self.message = [aDecoder decodeObjectForKey:MessageKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.notificationTitle forKey:TitleKey];
    [aCoder encodeObject:self.message forKey:MessageKey];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
