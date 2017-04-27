//
//  NITTrackRequest.h
//  NearITSDK
//
//  Created by Francesco Leoni on 21/04/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITTrackRequest : NSObject<NSCoding>

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *nextRetry;
@property (nonatomic) NSInteger retry;
@property (nonatomic) BOOL sending;

- (void)increaseRetryWithTimeInterval:(NSTimeInterval)interval;
- (BOOL)availableForNextRetryWithDate:(NSDate*)date;

@end
