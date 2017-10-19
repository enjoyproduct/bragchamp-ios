//
//  User.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *thumbURL;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) NSInteger followings;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger trash_count;
@property (nonatomic, assign) NSInteger comment_count;
@property (nonatomic, assign) NSInteger challenge_count;
@property (nonatomic, assign) NSInteger view_count;

@property (nonatomic, assign) BOOL isReported;
@property (nonatomic, assign) BOOL isFollowing;
@property (nonatomic, assign) BOOL isBlocked;

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
