//
//  Video.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Video : NSObject

@property (nonatomic, assign) NSInteger postId;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger maxChallengers;
@property (nonatomic, assign) BOOL isPublic;
@property (nonatomic, strong) NSString *hashtags;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *thumbURL;
@property (nonatomic, strong) NSString *createdTime;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger trash_count;
@property (nonatomic, assign) NSInteger challenge_count;
@property (nonatomic, assign) NSInteger comment_count;
@property (nonatomic, assign) NSInteger view_count;

@property (nonatomic, assign) NSInteger like_status;

//@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isCommented;
@property (nonatomic, assign) BOOL isReplied;
@property (nonatomic, assign) BOOL isChallengable;
@property (nonatomic, assign) BOOL isViewed;

@property (nonatomic, strong) User *user;

+ (instancetype)videoWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
