//
//  SplashSegue.m
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "SplashSegue.h"
#import "AppDelegate.h"

@implementation SplashSegue

- (void)perform {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window setRootViewController:self.destinationViewController];
}

@end
