//
//  RegisterViewController.m
//  brag-champ
//
//  Created by Apple on 12/13/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "RegisterViewController.h"
#import "Common.h"
#import "APIManager.h"
#import "User.h"
#import "Me.h"

#import <SVProgressHUD.h>

@interface RegisterViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *firstnameTextField;
@property (nonatomic, weak) IBOutlet UITextField *lastnameTextField;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *birthTextField;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTextField;

@property (nonatomic, strong) IBOutlet UIDatePicker *birthPicker;
@property (nonatomic, strong) IBOutlet UIToolbar *birthToolbar;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.birthTextField.inputView = self.birthPicker;
    self.birthTextField.inputAccessoryView = self.birthToolbar;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";

    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]];
    self.birthTextField.text = [NSString stringWithFormat:@"%ld-01-01", year - 16];
    self.birthPicker.minimumDate = [formatter dateFromString:self.birthTextField.text];
    self.birthPicker.maximumDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld-12-31", year - 70]];
    self.birthPicker.date = [formatter dateFromString:self.birthTextField.text];

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 147, 32);
    [self.navigationItem setTitleView:titleButton];
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


- (IBAction)birthdayChanged:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.birthTextField.text = [formatter stringFromDate:self.birthPicker.date];
}

- (IBAction)closeBirthPicker:(id)sender {
    [self.birthTextField resignFirstResponder];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender {
    NSString *firstname = _firstnameTextField.text;
    if (firstname.length == 0) {
        [Common showAlertWithMessage:@"Please input your first name."];
        [_firstnameTextField becomeFirstResponder];
        return;
    }
    
    NSString *lastname = _lastnameTextField.text;
    if (lastname.length == 0) {
        [Common showAlertWithMessage:@"Please input your last name."];
        [_lastnameTextField becomeFirstResponder];
        return;
    }
    
    NSString *email = _emailTextField.text;
    if (email.length == 0 ) {
        [Common showAlertWithMessage:@"Please input your email address."];
        [_emailTextField becomeFirstResponder];
        return;
    }
    if (![Common isValidEmail:email]) {
        [Common showAlertWithMessage:@"Please input a valid email address."];
        [_emailTextField becomeFirstResponder];
        return;
    }
    
    NSString *birthday = _birthTextField.text;
    if (birthday.length == 0) {
        [Common showAlertWithMessage:@"Please input your birthday."];
        [_birthTextField becomeFirstResponder];
        return;
    }

    NSString *username = _usernameTextField.text;
    if (username.length == 0) {
        [Common showAlertWithMessage:@"Please input username."];
        [_usernameTextField becomeFirstResponder];
        return;
    }
    if (username.length < kUsernameMinLen) {
        [Common showAlertWithMessage:[NSString stringWithFormat:@"Username is too short. Please input more than %ld characters.", (long)kUsernameMinLen]];
        [_usernameTextField becomeFirstResponder];
        return;
    }
    if (username.length > kUsernameMaxLen) {
        [Common showAlertWithMessage:[NSString stringWithFormat:@"Username is too long. Please input less than %ld characters.", (long)kUsernameMaxLen]];
        [_usernameTextField becomeFirstResponder];
        return;
    }
//    if (![Common isValidUsername:username]) {
//        [Common showAlertWithMessage:@"Username is invalid. Please use English alphabetics, digits and underline only."];
//        [_usernameTextField becomeFirstResponder];
//        return;
//    }

    NSString *password = _passwordTextField.text;
    if (password.length == 0) {
        [Common showAlertWithMessage:@"Please input the password."];
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
    
    [self.firstnameTextField resignFirstResponder];
    [self.lastnameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.birthTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    
    
    [SVProgressHUD show];
    
    [[APIManager sharedManager] signupWithFirstname:firstname
                                           lastname:lastname
                                              email:email
                                           birthday:birthday
                                           username:username
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
    if (textField == _firstnameTextField) {
        [_lastnameTextField becomeFirstResponder];
    } else if (textField == _lastnameTextField) {
        [_emailTextField resignFirstResponder];
    } else if (textField == _emailTextField) {
        [_birthTextField resignFirstResponder];
    } else if (textField == _usernameTextField) {
        [_usernameTextField resignFirstResponder];
    } else if (textField == _passwordTextField) {
        [_confirmPasswordTextField becomeFirstResponder];
    } else if (textField == _confirmPasswordTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
