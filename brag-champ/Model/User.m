//
//  User.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "User.h"

@implementation User

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.userId = [dictionary[@"id"] integerValue];
        self.name = dictionary[@"user_name"];
        self.firstName = dictionary[@"fname"];
        self.lastName = dictionary[@"lname"];
        self.email = dictionary[@"email"];
        self.birthday = dictionary[@"birthday"];
        self.thumbURL = dictionary[@"avatar_url"];
        self.bio = dictionary[@"bio"];
        if ([self.bio isEqual:[NSNull null]]) {
            self.bio = @"";
        }
        
        self.followers = [dictionary[@"followers"] integerValue];
        self.followings = [dictionary[@"followings"] integerValue];
        
        
        self.isReported = [dictionary[@"isReported"] boolValue];

        self.isFollowing = [dictionary[@"isFollowing"] boolValue];
        self.isBlocked = [dictionary[@"isBlocked"] boolValue];
        
        self.like_count = [dictionary[@"like_count"] integerValue];
        self.trash_count = [dictionary[@"trash_count"] integerValue];
        self.comment_count = [dictionary[@"comment_count"] integerValue];
        self.challenge_count = [dictionary[@"challenge_count"] integerValue];
        self.view_count = [dictionary[@"view_count"] integerValue];
        
    }
    
    return self;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.userId forKey:@"user_id"];
    if (self.name) {
        [aCoder encodeObject:self.name forKey:@"user_name"];
    }
    if (self.firstName) {
        [aCoder encodeObject:self.firstName forKey:@"fname"];
    }
    if (self.lastName) {
        [aCoder encodeObject:self.lastName forKey:@"lname"];
    }
    if (self.email) {
        [aCoder encodeObject:self.email forKey:@"email"];
    }
    if (self.birthday) {
        [aCoder encodeObject:self.birthday forKey:@"birthday"];
    }
    if (self.thumbURL) {
        [aCoder encodeObject:self.thumbURL forKey:@"avatar_url"];
    }
    if (self.bio) {
        [aCoder encodeObject:self.bio forKey:@"bio"];
    }
    [aCoder encodeInteger:self.followers forKey:@"followers"];
    [aCoder encodeInteger:self.followings forKey:@"followings"];
    [aCoder encodeBool:self.isReported forKey:@"isReported"];

    [aCoder encodeBool:self.isFollowing forKey:@"isFollowing"];
    [aCoder encodeBool:self.isBlocked forKey:@"isBlocked"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userId = [aDecoder decodeIntegerForKey:@"user_id"];
        self.name = [aDecoder decodeObjectForKey:@"user_name"];
        self.firstName = [aDecoder decodeObjectForKey:@"fname"];
        self.lastName = [aDecoder decodeObjectForKey:@"lname"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.thumbURL = [aDecoder decodeObjectForKey:@"avatar_url"];
        self.bio = [aDecoder decodeObjectForKey:@"bio"];
        self.followers = [aDecoder decodeIntegerForKey:@"followers"];
        self.followings = [aDecoder decodeIntegerForKey:@"followings"];
        self.isReported = [aDecoder decodeBoolForKey:@"isReported"];

        self.isFollowing = [aDecoder decodeBoolForKey:@"isFollowing"];
        self.isBlocked = [aDecoder decodeBoolForKey:@"isBlocked"];
    }
    
    return self;
}

@end
