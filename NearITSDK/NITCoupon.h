//
//  NITCoupon.h
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <NearITSDK/NearITSDK.h>
#import "NITClaim.h"
#import "NITImage.h"

@interface NITCoupon : NITResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *couponDescription;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *expiresAt;
@property (nonatomic, strong) NSArray<NITClaim*> *claims;
@property (nonatomic, strong) NITImage *icon;

@end
