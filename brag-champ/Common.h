//
//  Common.h
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kUsernameMinLen     3
#define kUsernameMaxLen     20
#define kPasswordMinLen     6
#define kPasswordMaxLen     64

#define kDidUpdatedVideoSocialInfoNotification       @"UpdateVideoSocialInfoNotification"
#define kDidUpdatedChallengeSocialInfoNotification       @"UpdateChallengeSocialInfoNotification"
#define kDidLikeVideoNotification       @"kDidLikeVideoNotification"

@interface Common : NSObject

+ (void)showAlertWithMessage:(NSString *)message;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissCaption:(NSString *)dismissCaption;

+ (BOOL)isValidEmail:(NSString *)email;
+ (BOOL)isValidUsername:(NSString *)username;

//Get Height Of Text by its content, font, width
+ (CGFloat)getHeightOfString:(NSString*)content width:(CGFloat)width andFont:(UIFont*)font;
@end
