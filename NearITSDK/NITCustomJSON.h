//
//  NITCustomJSON.h
//  NearITSDK
//
//  Created by Francesco Leoni on 31/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <NearITSDK/NearITSDK.h>

@interface NITCustomJSON : NITResource<NSCoding>

@property (nonatomic, strong) NSDictionary<NSString*, id> *content;

@end
