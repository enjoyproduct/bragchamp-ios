//
//  Message.m
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "Message.h"

@implementation Message

+ (instancetype)messageWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return [[self alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.messageId = [dictionary[@"id"] integerValue];
        self.receiverId = [dictionary[@"receiver_id"] integerValue];
        self.senderId = [dictionary[@"sender_id"] integerValue];
        self.message = dictionary[@"message"];
        self.date = [dictionary[@"create_time"] integerValue];
        
    }
    
    return self;
}
@end
