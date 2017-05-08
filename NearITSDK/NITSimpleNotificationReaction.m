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
#import "NITLog.h"

#define LOGTAG @"SimpleNotificationReaction"

@implementation NITSimpleNotificationReaction

- (void)contentWithRecipe:(NITRecipe *)recipe completionHandler:(void (^)(id content, NSError * error))handler {
    if (handler) {
        NITSimpleNotification *notification = [self contentWithRecipe:recipe];
        if(notification) {
            NITLogD(LOGTAG, @"Notification extracted from recipe (%@): title -> %@", recipe.ID, notification.notificationTitle);
            handler(notification, nil);
        } else {
            NITLogE(LOGTAG, @"Notification failure: recipeId -> %@", recipe.ID);
            NSError *anError = [NSError errorWithDomain:NITReactionErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"Invalid notification in recipe"}];
            handler(nil, anError);
        }
    }
}

- (NITSimpleNotification*)contentWithRecipe:(NITRecipe*)recipe {
    NSString *title = [recipe notificationTitle];
    NSString *body = [recipe notificationBody];
    if (body) {
        NITSimpleNotification *notification = [[NITSimpleNotification alloc] init];
        notification.notificationTitle = title;
        notification.message = body;
        return notification;
    }
    return nil;
}

@end
