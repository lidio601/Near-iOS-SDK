//
//  NITNetworkProvider.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NITNetworkProvider : NSObject

+ (NSURLRequest*)recipesList;
+ (NSURLRequest*)newProfileWithAppId:(NSString*)appId;
+ (NSURLRequest*)geopolisNodes;

@end
