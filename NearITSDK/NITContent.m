//
//  NITContent.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITContent.h"

#define ContentKey @"content"
#define VideoLinkKey @"videoLink"
#define ImagesKey @"images"
#define AudioKey @"audio"
#define UploadKey @"upload"

@implementation NITContent

- (NSDictionary *)attributesMap {
    return @{ @"video_link" : @"videoLink"};
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.content = [aDecoder decodeObjectForKey:ContentKey];
        self.videoLink = [aDecoder decodeObjectForKey:VideoLinkKey];
        self.images = [aDecoder decodeObjectForKey:ImagesKey];
        self.audio = [aDecoder decodeObjectForKey:AudioKey];
        self.upload = [aDecoder decodeObjectForKey:UploadKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.content forKey:ContentKey];
    [aCoder encodeObject:self.videoLink forKey:VideoLinkKey];
    [aCoder encodeObject:self.images forKey:ImagesKey];
    [aCoder encodeObject:self.audio forKey:AudioKey];
    [aCoder encodeObject:self.upload forKey:UploadKey];
}

@end
