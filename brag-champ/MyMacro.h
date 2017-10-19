//
//  config.h
//  Fitness
//
//  Created by Admin on 3/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#ifndef GeneralConstants_h
#define GeneralConstants_h

#define USER_DEFAULTS                                   [NSUserDefaults standardUserDefaults]
#define USER_DEFAULTS_SYNC()                            [[NSUserDefaults standardUserDefaults] synchronize]
#define SET_USER_DEFAULTS(key,value)                    [USER_DEFAULTS setObject:value forKey:key]
#define GET_USER_DEFAULTS(key)                          [USER_DEFAULTS objectForKey:key]

#define SET_LOGIN                                       SET_USER_DEFAULTS(@"isLogin", @"yes")
#define SET_LOGOUT                                      SET_USER_DEFAULTS(@"isLogin", @"no")
#define ISLOGIN                                         ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] isEqualToString:@"yes"])


#define SCREEN_MAX_LENGTH                               (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH                               (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define ERRORMESSAGE                                    NSLocalizedString(@"Connection Failed",nil)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)      ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define UA_invalidateTimer(t) [t invalidate]; t = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#define UA_runOnMainThread if (![NSThread isMainThread]) { dispatch_sync(dispatch_get_main_queue(), ^{ [self performSelector:_cmd]; }); return; };
#pragma clang diagnostic pop


//Color
#define UA_rgba(r,g,b,a)				[UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UA_rgb(r,g,b)					UA_rgba(r, g, b, 1.0f)

#ifdef DEBUG
#define UA_log( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define UA_log( s, ... )
#endif

#define UA_logBounds(view) UA_log(@"%@ bounds: %@", view, NSStringFromRect([view bounds]))
#define UA_logFrame(view)  UA_log(@"%@ frame: %@", view, NSStringFromRect([view frame]))

#define COLOR_YELLOW				[UIColor colorWithRed:1 green:226.0/255 blue:32.0/255 alpha:1]
#define COLOR_GRAY                  [UIColor colorWithWhite:170.0/255 alpha:1]
#define COLOR_BLACK                 [UIColor colorWithRed:6/255.0f green:6/255.0f blue:6/255.0f alpha:1]
#define COLOR_YELLOW_DARK			[UIColor colorWithRed:254/255.0f green:153/255.0f blue:6/255.0f alpha:1]
#define COLOR_GREEN                 [UIColor colorWithRed:22/255.0f green:223/255.0f blue:37/255.0f alpha:1]
#define COLOR_PINK                  [UIColor colorWithRed:254/255.0f green:7/255.0f blue:164/255.0f alpha:1]

//NSNUMBER Control
#define BOX_BOOL(x) [NSNumber numberWithBool:(x)]
#define BOX_INT(x) [NSNumber numberWithInt:(x)]
#define BOX_SHORT(x) [NSNumber numberWithShort:(x)]
#define BOX_LONG(x) [NSNumber numberWithLong:(x)]
#define BOX_UINT(x) [NSNumber numberWithUnsignedInt:(x)]
#define BOX_FLOAT(x) [NSNumber numberWithFloat:(x)]
#define BOX_DOUBLE(x) [NSNumber numberWithDouble:(x)]

#define UNBOX_BOOL(x) [(x) boolValue]
#define UNBOX_INT(x) [(x) intValue]
#define UNBOX_SHORT(x) [(x) shortValue]
#define UNBOX_LONG(x) [(x) longValue]
#define UNBOX_UINT(x) [(x) unsignedIntValue]
#define UNBOX_FLOAT(x) [(x) floatValue]
#define UNBOX_DOUBLE(x) [(x) doubleValue]

//Rect
#define RECT_WITH_WIDTH_HEIGHT(rect, width, height)     CGRectMake((rect).origin.x, (rect).origin.y, (width), (height))
#define RECT_WITH_WIDTH(rect, width)                    CGRectMake((rect).origin.x, (rect).origin.y, (width), (rect).size.height)
#define RECT_WITH_HEIGHT(rect, height)                  CGRectMake((rect).origin.x, (rect).origin.y, (rect).size.width, (height))


#define RECT_INSET_BY_LEFT_TOP_RIGHT_BOTTOM(rect, left, top, right, bottom)     CGRectMake(rect.origin.x + (left), rect.origin.y + (top), rect.size.width - (left) - (right), rect.size.height - (top) - (bottom))
#define RECT_INSET_BY_TOP_BOTTOM(rect, top, bottom)     CGRectMake(rect.origin.x, rect.origin.y + (top), rect.size.width, rect.size.height - (top) - (bottom))
#define RECT_INSET_BY_LEFT_RIGHT(rect, left, right)     CGRectMake(rect.origin.x + (left), rect.origin.y, rect.size.width - (left) - (right), rect.size.height)
#define RECT_STACKED_OFFSET_BY_X(rect, offset)          CGRectMake(rect.origin.x + rect.size.width + (offset), rect.origin.y, rect.size.width, rect.size.height)
#define RECT_STACKED_OFFSET_BY_Y(rect, offset)          CGRectMake(rect.origin.x, rect.origin.y + rect.size.height + (offset), rect.size.width, rect.size.height)

//Utilities
#define SEL(x)  @selector(x)
#define IS_EMPTY_STRING(str)        (!(str) || ![(str) isKindOfClass:NSString.class] || [(str) length] == 0)
#define IS_POPULATED_STRING(str)    ((str) && [(str) isKindOfClass:NSString.class] && [(str) length] > 0)
#define DEVICE_UDID                 ([UIDevice currentDevice].uniqueIdentifier)
#define DOCUMENTS_DIR               ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject])


#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define NotificationCenter                  [NSNotificationCenter defaultCenter]
#define SharedApplication                   [UIApplication sharedApplication]
#define Bundle                              [NSBundle mainBundle]
#define MainScreen                          [UIScreen mainScreen]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        self.navigationController.navigationBar.bounds.size.height
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define StatusBarHeight                     [UIApplication sharedApplication].statusBarFrame.size.height
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define FlushPool(p)                        [p drain]; p = [[NSAutoreleasePool alloc] init]
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]
#define HEXCGCOLOR(c)                       [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0].CGColor



// phone version
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)


#endif /* GeneralConstants_h */



