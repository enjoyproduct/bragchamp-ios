//
//  PasswordViewController.m
//  brag-champ
//
//  Created by Apple on 3/4/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "PasswordViewController.h"
#import "Common.h"
#import "APIManager.h"
#import "User.h"
#import "Me.h"

#import <SVProgressHUD.h>

@interface PasswordViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *oldPasswordTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 120, 40);
    [self.navigationItem setTitleView:titleButton];

    self.navigationItem.title = @" ";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
    NSString *oldPassword = _oldPasswordTextField.text;
    if (oldPassword.length == 0) {
        [Common showAlertWithMessage:@"Please input the old password."];
        [_passwordTextField resignFirstResponder];
        return;
    }
    
    NSString *password = _passwordTextField.text;
    if (password.length == 0) {
        [Common showAlertWithMessage:@"Please input the new password."];
        [_passwordTextField resignFirstResponder];
        return;
    }
    if (password.length < kPasswordMinLen) {
        [Common showAlertWithMessage:[NSString stringWithFormat:@"The password is too short. Please input more than %ld characters.", (long)kPasswordMinLen]];
        [_passwordTextField becomeFirstResponder];
        return;
    }
    if (password.length > kPasswordMaxLen) {
        [Common showAlertWithMessage:[NSString stringWithFormat:@"The password is too long. Please input less than %ld characters.", (long)kPasswordMaxLen]];
        [_passwordTextField becomeFirstResponder];
        return;
    }
    
    if (![password isEqualToString:_confirmPasswordTextField.text]) {
        [Common showAlertWithMessage:@"The passwords don't match."];
        [_passwordTextField becomeFirstResponder];
        return;
    }
    
    [self.oldPasswordTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    
    
    [SVProgressHUD show];
    
    [[APIManager sharedManager] updatePassword:[Me me]
                                   oldPassword:oldPassword
                                   newPassword:password
                                       success:^()
     {
         [SVProgressHUD dismiss];
         
         [self.navigationController popViewControllerAnimated:YES];
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
    if (textField == _passwordTextField) {
        [_confirmPasswordTextField becomeFirstResponder];
    } else if (textField == _confirmPasswordTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
