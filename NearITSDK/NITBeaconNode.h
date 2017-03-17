//
//  NITBeaconNode.h
//  NearITSDK
//
//  Created by Francesco Leoni on 17/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNode.h"

@interface NITBeaconNode : NITNode

@property (nonatomic, strong) NSString *proximityUUID;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, strong) NSNumber *minor;

@end
