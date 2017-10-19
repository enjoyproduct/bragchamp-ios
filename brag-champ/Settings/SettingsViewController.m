//
//  SettingsViewController.m
//  brag-champ
//
//  Created by Apple on 2/21/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "SettingsViewController.h"
#import "Me.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 147, 32);
    [self.navigationItem setTitleView:titleButton];
    
    self.navigationItem.title = @" ";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section != 1) {
        return;
    }
    
    switch (indexPath.row) {
        case 0: // Profile
            [self profile:nil];
            break;
        case 1: // Password
            [self password:nil];
            break;
        case 2: // Log out
            [self logout:nil];
            break;
        case 3: // Help
            [self help:nil];
            break;
        case 4: // Privacy Policy
            [self privacyPolicy:nil];
            break;
    }
}


- (IBAction)facebook:(id)sender {
#warning Facebook
}

- (IBAction)gmail:(id)sender {
#warning Gmail
}


- (IBAction)profile:(id)sender {
    [self performSegueWithIdentifier:@"showEditProfile" sender:nil];
}

- (IBAction)password:(id)sender {
    [self performSegueWithIdentifier:@"showPassword" sender:nil];
}

- (IBAction)logout:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Log out" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[Me me] logout];
        [self.navigationController performSegueWithIdentifier:@"showLogin" sender:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)help:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bragchampapp.com"]];
}

- (IBAction)privacyPolicy:(id)sender {

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bragchampapp.com"]];
}

@end
