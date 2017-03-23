//
//  NITInstallation.h
//  NearITSDK
//
//  Created by Francesco Leoni on 23/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITInstallation : NSObject

+ (NITInstallation* _Nonnull)sharedInstance;
- (void)registerInstallationWithCompletionHandler:(void (^_Nullable)(NSString* _Nullable installationId, NSError* _Nullable error))handler;

@end
