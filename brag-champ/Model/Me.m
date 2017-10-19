//
//  Me.m
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "Me.h"

@implementation Me

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.authKey = dictionary[@"authkey"];
    }
    
    return self;
}


- (void)saveOnLocal {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"me"];
    [defaults synchronize];
}

- (void)logout {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"me"];
    [defaults synchronize];
}


+ (instancetype)loadFromLocal {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"me"];
    
    if (!data) {
        return nil;
    }

    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (instancetype)me {
    return [Me loadFromLocal];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.authKey) {
        [aCoder encodeObject:self.authKey forKey:@"authkey"];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.authKey = [aDecoder decodeObjectForKey:@"authkey"];
    }
    
    return self;
}

@end
