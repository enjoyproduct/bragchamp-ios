//
//  ChallengeVideo.h
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface ChallengeVideo : NSObject

@property (nonatomic, assign) NSInteger challengeId;
@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbURL;
@property (nonatomic, strong) NSString *createdTime;
@property (nonatomic, strong) NSString *avatarURL;

@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger trash_count;
@property (nonatomic, assign) NSInteger comment_count;

@property (nonatomic, assign) NSInteger like_status;

@property (nonatomic, assign) BOOL isCommented;

@property (nonatomic, strong) User *user;

+ (instancetype)challengeVideoWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
