//
//  Notification.m
//  brag-champ
//
//  Created by Apple on 4/1/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "Notification.h"
#import "User.h"
#import "Video.h"
#import "ChallengeVideo.h"

@implementation Notification

+ (instancetype)notificationWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.notificationId = [dictionary[@"id"] integerValue];
        self.userId = [dictionary[@"receiver_id"] integerValue];
        self.type = [dictionary[@"type"] integerValue];
        self.status = [dictionary[@"status"] integerValue];
        NSData *contentData = [dictionary[@"content"] dataUsingEncoding:NSUTF8StringEncoding];
        NSError * jsonError;
        NSDictionary *content = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:&jsonError];
        self.user = [User userWithDictionary:content[@"user"]];
        if (self.type == 1) {
            self.followId = [content[@"follow_id"] integerValue];
        } else if (self.type == 2 || self.type == 4) {
            self.video = [Video videoWithDictionary:content[@"post"]];
        } else if (self.type == 3 || self.type == 5 ) {
            self.challenge = [ChallengeVideo challengeVideoWithDictionary:content[@"challenge"]];
            self.challenge.user = self.user;
        } else if (self.type == 7) {
            self.video = [Video videoWithDictionary:content[@"post"]];
            self.challenge = [ChallengeVideo challengeVideoWithDictionary:content[@"challenge"]];
            self.challenge.user = self.user;
        }
    }
    
    return self;
}

@end
