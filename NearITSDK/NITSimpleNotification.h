//
//  NITSimpleNotification.h
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITSimpleNotification : NSObject

@property (nonatomic, strong) NSString *notificationTitle;
@property (nonatomic, strong) NSString *message;

@end
