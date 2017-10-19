//
//  Video.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "Video.h"
#import "User.h"

@implementation Video

+ (instancetype)videoWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.postId = [dictionary[@"id"] integerValue];
        self.userId = [dictionary[@"user_id"] integerValue];
        self.name = dictionary[@"ch_title"];
        self.maxChallengers = [dictionary[@"ch_count"] integerValue];
        self.isPublic = ([dictionary[@"ch_mode"] integerValue] == 0);
        self.hashtags = dictionary[@"hashtags"];
        self.url = dictionary[@"video_url"];
        self.thumbURL = dictionary[@"thumbnail_url"];
        self.createdTime = dictionary[@"create_time"];
        self.like_count = [dictionary[@"like_count"] integerValue];
        self.trash_count = [dictionary[@"trash_count"] integerValue];
        self.challenge_count = [dictionary[@"challenge_count"] integerValue];
        self.view_count = [dictionary[@"view_count"] integerValue];
        self.comment_count = [dictionary[@"comment_count"] integerValue];
        
        self.user = [[User alloc] init];
        self.user.userId = self.userId;
        self.user.name = dictionary[@"user_name"];
//        self.user = [User userWithDictionary:dictionary];
        
        self.like_status = ([dictionary[@"like_status"] integerValue]);
        
        self.isCommented = ([dictionary[@"iscomment"] integerValue] > 0);
        self.isReplied = ([dictionary[@"isreply"] integerValue] > 0);
        self.isViewed = ([dictionary[@"isViewed"] integerValue] > 0);
        self.isChallengable = ([dictionary[@"isChallengable"] integerValue] > 0);
    }
    
    return self;
}

@end
