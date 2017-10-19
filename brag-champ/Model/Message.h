//
//  Message.h
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, assign) NSInteger senderId;
@property (nonatomic, assign) NSInteger receiverId;
@property (nonatomic, assign) NSInteger date;
@property (nonatomic, copy) NSString *message;

+ (instancetype)messageWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
