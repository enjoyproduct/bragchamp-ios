//
//  Me.h
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "User.h"

@interface Me : User <NSCoding>

@property (nonatomic, strong) NSString *authKey;

+ (instancetype)me;

- (void)saveOnLocal;
- (void)logout;

@end
