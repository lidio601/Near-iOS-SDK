//
//  TestReachability.m
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "TestReachability.h"

@implementation TestReachability

- (instancetype)init {
    self = [super init];
    if (self) {
        self.testNetworkStatus = NotReachable;
    }
    return self;
}

- (NetworkStatus)currentReachabilityStatus {
    return self.testNetworkStatus;
}

@end
