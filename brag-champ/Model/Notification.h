//
//  Notification.h
//  brag-champ
//
//  Created by Apple on 4/1/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Video;
@class ChallengeVideo;

@interface Notification : NSObject

@property (nonatomic, assign) NSInteger notificationId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *createdTime;

@property (nonatomic, assign) NSInteger followId;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) ChallengeVideo *challenge;

+ (instancetype)notificationWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
