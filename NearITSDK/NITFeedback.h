//
//  NITFeedback.h
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <NearITSDK/NearITSDK.h>

@interface NITFeedback : NITResource<NSCoding>

@property (nonatomic, strong) NSString* _Nonnull question;
@property (nonatomic, strong) NSString* _Nonnull recipeId;

@end
