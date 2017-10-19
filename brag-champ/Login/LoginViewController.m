//
//  LoginViewController.m
//  brag-champ
//
//  Created by Apple on 12/13/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "LoginViewController.h"
#import "Common.h"
#import "APIManager.h"
#import "User.h"
#import "Me.h"

#import <SVProgressHUD.h>
#import <AFNetworking.h>

@interface LoginViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _usernameTextField.layer.cornerRadius = 1;
    _passwordTextField.layer.cornerRadius = 1;

    self.navigationItem.title = @" ";
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)submit:(id)sender {
    NSString *username = _usernameTextField.text;
    if (username.length == 0) {
        [Common showAlertWithMessage:@"Please input username."];
        [_usernameTextField becomeFirstResponder];
        return;
    }
    
    NSString *password = _passwordTextField.text;
    if (password.length == 0) {
        [Common showAlertWithMessage:@"Please input the password."];
        [_passwordTextField resignFirstResponder];
        return;
    }
    
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    
    [SVProgressHUD show];
    
    [[APIManager sharedManager] loginWithUsername:username
                                         password:password
                                          success:^(Me *me)
     {
         [SVProgressHUD dismiss];
         
         [me saveOnLocal];
         [self performSegueWithIdentifier:@"showHome" sender:nil];
     }
                                             failed:^(NSString *message, NSError *error)
     {
         [SVProgressHUD dismiss];
         
         if (message) {
             [Common showAlertWithMessage:message];
             return;
         }
         
         if (error) {
             [Common showAlertWithMessage:error.localizedDescription];
             return;
         }
         
         [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
     }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
