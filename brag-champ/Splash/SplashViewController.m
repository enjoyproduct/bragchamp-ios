//
//  SplashViewController.m
//  brag-champ
//
//  Created by Apple on 12/26/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "SplashViewController.h"

#import "Me.h"
#import "User.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([Me me]) {
        [self performSegueWithIdentifier:@"showHome" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:nil];
    }
}

@end
