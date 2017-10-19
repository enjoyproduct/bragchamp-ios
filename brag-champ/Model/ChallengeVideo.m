//
//  ChallengeVideo.m
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "ChallengeVideo.h"
#import "User.h"

@implementation ChallengeVideo

+ (instancetype)challengeVideoWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.challengeId = [dictionary[@"id"] integerValue];
        self.postId = [dictionary[@"post_id"] integerValue];
        self.userId = [dictionary[@"user_id"] integerValue];
        self.url = dictionary[@"video_url"];
        self.thumbURL = dictionary[@"thumbnail_url"];
        self.avatarURL = dictionary[@"avatar_url"];
        self.createdTime = dictionary[@"create_time"];
        
        self.like_count = [dictionary[@"like_count"] integerValue];
        self.trash_count = [dictionary[@"trash_count"] integerValue];
        self.comment_count = [dictionary[@"comment_count"] integerValue];
        
        self.like_status = [dictionary[@"like_status"] integerValue];
        self.isCommented = ([dictionary[@"iscomment"] integerValue] > 0);
        

        self.user = [[User alloc] init];
        self.user.userId = self.userId;
        self.user.name = dictionary[@"user_name"];
        self.user.thumbURL = dictionary[@"thumbnail_url"];
//        self.user = [User userWithDictionary:dictionary];
    }
    
    return self;
}

@end
