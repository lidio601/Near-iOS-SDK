//
//  NITConstants.h
//  NearITSDK
//
//  Created by Francesco Leoni on 23/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NITRegionEvent) {
    NITRegionEventEnterArea,
    NITRegionEventLeaveArea,
    NITRegionEventImmediate,
    NITRegionEventNear,
    NITRegionEventFar,
    NITRegionEventEnterPlace,
    NITRegionEventLeavePlace,
    NITRegionEventUnknown
};

extern NSErrorDomain const NITUserProfileErrorDomain;
extern NSErrorDomain const NITInstallationErrorDomain;
extern NSErrorDomain const NITReactionErrorDomain;
