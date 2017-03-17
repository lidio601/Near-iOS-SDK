//
//  NITBeaconNode.h
//  NearITSDK
//
//  Created by Francesco Leoni on 17/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITNode.h"

@interface NITBeaconNode : NITNode

@property (nonatomic, strong) NSString* _Nonnull proximityUUID;
@property (nonatomic, strong) NSNumber* _Nullable major;
@property (nonatomic, strong) NSNumber* _Nullable minor;

@end
