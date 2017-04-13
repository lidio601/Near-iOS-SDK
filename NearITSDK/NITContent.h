//
//  NITContent.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITResource.h"

@class NITImage;
@class NITAudio;
@class NITUpload;

@interface NITContent : NITResource<NSCoding>

@property (nonatomic, strong) NSString * _Nullable content;
@property (nonatomic, strong) NSArray<NITImage*> * _Nullable images;
@property (nonatomic, strong) NSString * _Nullable videoLink;
@property (nonatomic, strong) NITAudio * _Nullable audio;
@property (nonatomic, strong) NITUpload * _Nullable upload;

@end
