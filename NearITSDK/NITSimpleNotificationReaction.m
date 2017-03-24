//
//  NITSimpleNotificationReaction.m
//  NearITSDK
//
//  Created by Francesco Leoni on 24/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITSimpleNotificationReaction.h"
#import "NITRecipe.h"
#import "NITSimpleNotification.h"
#import "NITConstants.h"

@implementation NITSimpleNotificationReaction

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id content, NSError * error))handler {
    if (handler) {
        NITSimpleNotification *notification = [self contentWithRecipe:recipe];
        if(notification) {
            handler(notification, nil);
        } else {
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@"Invalid notification in recipe"}];
            handler(nil, anError);
        }
    }
}

- (NITSimpleNotification*)contentWithRecipe:(NITRecipe*)recipe {
    NSString *title = [recipe notificationTitle];
    NSString *body = [recipe notificationBody];
    if (title && body) {
        NITSimpleNotification *notification = [[NITSimpleNotification alloc] init];
        notification.notificationTitle = title;
        notification.message = body;
        return notification;
    }
    return nil;
}

@end
