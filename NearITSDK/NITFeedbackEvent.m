//
//  NITFeedbackEvent.m
//  NearITSDK
//
//  Created by Francesco Leoni on 31/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITFeedbackEvent.h"
#import "NITFeedback.h"
#import "NITJSONAPI.h"
#import "NITJSONAPIResource.h"
#import "NITConfiguration.h"

@interface NITFeedbackEvent()

@property (nonatomic) NSInteger rating;
@property (nonatomic, strong) NSString *comment;

@end

@implementation NITFeedbackEvent

- (instancetype)initWithFeedback:(NITFeedback*)feedback rating:(NSInteger)rating comment:(NSString*)comment {
    self = [super init];
    if (self) {
        self.ID = feedback.ID;
        self.rating = rating;
        self.comment = comment;
        self.recipeId = feedback.recipeId;
    }
    return self;
}

- (NITJSONAPI*)toJsonAPI:(NITConfiguration*)configuration {
    NSString *profileId = configuration.profileId;
    if (profileId == nil || self.rating == -1 || self.recipeId == nil || self.ID == nil) {
        return nil;
    }
    NITJSONAPI *json = [[NITJSONAPI alloc] init];
    NITJSONAPIResource *resource = [[NITJSONAPIResource alloc] init];
    resource.type = @"answers";
    [resource addAttributeObject:[NSNumber numberWithInteger:self.rating] forKey:@"rating"];
    [resource addAttributeObject:profileId forKey:@"profile_id"];
    [resource addAttributeObject:self.recipeId forKey:@"recipe_id"];
    if (self.comment) {
        [resource addAttributeObject:self.comment forKey:@"comment"];
    }
    [json setDataWithResourceObject:resource];
    
    return json;
}

@end
