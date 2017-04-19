//
//  NITTestBeacon.m
//  NearITSDK
//
//  Created by Francesco Leoni on 19/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITTestBeacon.h"

@implementation NITTestBeacon

- (NSUUID *)proximityUUID {
    return self.testProximityUUID;
}

- (NSNumber *)major {
    return self.testMajor;
}

- (NSNumber *)minor {
    return self.testMinor;
}

- (CLProximity)proximity {
    return self.testProximity;
}

@end
