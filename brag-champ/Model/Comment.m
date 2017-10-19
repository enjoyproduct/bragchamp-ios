//
//  Comment.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

+ (instancetype)commentWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.user = [User userWithDictionary:dictionary];
        self.commentId = [dictionary[@"comment_id"] integerValue];
        self.comment = dictionary[@"content"];
        
    }
    
    return self;
}

@end
