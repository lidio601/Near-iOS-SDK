//
//  NITFeedback.m
//  NearITSDK
//
//  Created by Francesco Leoni on 30/03/17.
//  Copyright © 2017 NearIT. All rights reserved.
//

#import "NITFeedback.h"

#define QuestionKey @"question"
#define RecipeIdKey @"recipeId"

@implementation NITFeedback

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.question = [aDecoder decodeObjectForKey:QuestionKey];
        self.recipeId = [aDecoder decodeObjectForKey:RecipeIdKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.question forKey:QuestionKey];
    [aCoder encodeObject:self.recipeId forKey:RecipeIdKey];
}

@end
