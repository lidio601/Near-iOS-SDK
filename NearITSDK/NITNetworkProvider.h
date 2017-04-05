//
//  NITNetworkProvider.h
//  NearITSDK
//
//  Created by Francesco Leoni on 15/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NITJSONAPI;

@interface NITNetworkProvider : NSObject

+ (NSURLRequest*)recipesProcessListWithJsonApi:(NITJSONAPI*)jsonApi;
+ (NSURLRequest*)processRecipeWithId:(NSString*)recipeId;
+ (NSURLRequest*)evaluateRecipeWithId:(NSString*)recipeId jsonApi:(NITJSONAPI*)jsonApi;
+ (NSURLRequest*)onlinePulseEvaluationWithJsonApi:(NITJSONAPI*)jsonApi;
+ (NSURLRequest*)newProfileWithAppId:(NSString*)appId;
+ (NSURLRequest*)geopolisNodes;
+ (NSURLRequest*)newInstallationWithJsonApi:(NITJSONAPI*)jsonApi;
+ (NSURLRequest*)updateInstallationWithJsonApi:(NITJSONAPI*)jsonApi installationId:(NSString*)installationId;
+ (NSURLRequest*)contentWithBundleId:(NSString*)bundleId;
+ (NSURLRequest*)contents;
+ (NSURLRequest*)sendTrackingsWithJsonApi:(NITJSONAPI*)jsonApi;
+ (NSURLRequest*)couponsWithProfileId:(NSString*)profileId;
+ (NSURLRequest*)feedbackWithBundleId:(NSString*)bundleId;
+ (NSURLRequest*)feedbacks;
+ (NSURLRequest*)sendFeedbackEventWithJsonApi:(NITJSONAPI*)jsonApi feedbackId:(NSString*)feedbackId;
+ (NSURLRequest*)customJSONWithBundleId:(NSString*)bundleId;
+ (NSURLRequest*)customJSONs;
+ (NSURLRequest*)setUserDataWithJsonApi:(NITJSONAPI*)jsonApi profileId:(NSString*)profileId;

@end
