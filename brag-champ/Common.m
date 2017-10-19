//
//  Common.m
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "Common.h"
#import "AppDelegate.h"

#import <UIKit/UIKit.h>

@implementation Common

+ (void)showAlertWithMessage:(NSString *)message {
    [Common showAlertWithTitle:@"Brag Champ" message:message];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [Common showAlertWithTitle:title message:message dismissCaption:@"OK"];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message dismissCaption:(NSString *)dismissCaption {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:dismissCaption style:UIAlertActionStyleDefault handler:nil]];
    
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    [appDelegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}


+ (BOOL)isValidEmail:(NSString *)email {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidUsername:(NSString *)username {
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    return ([username stringByTrimmingCharactersInSet:charset].length == 0);
}
+ (CGFloat)getHeightOfString:(NSString*)content width:(CGFloat)width andFont:(UIFont*)font
{
    NSDictionary* attributes = @{NSFontAttributeName:font};
    CGFloat height = [content boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size.height;
    
    return height;
    
}
@end
