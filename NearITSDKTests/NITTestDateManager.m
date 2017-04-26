//
//  NITTestDateManager.m
//  NearITSDK
//
//  Created by Francesco Leoni on 26/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestDateManager.h"

@implementation NITTestDateManager

- (NSDate *)currentDate {
    if (self.testCurrentDate) {
        return self.testCurrentDate;
    }
    return [super currentDate];
}

@end
