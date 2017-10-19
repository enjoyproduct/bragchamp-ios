//
//  Comment.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject
@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *comment;

+ (instancetype)commentWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
