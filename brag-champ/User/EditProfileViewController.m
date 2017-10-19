//
//  EditProfileViewController.m
//  brag-champ
//
//  Created by Apple on 2/21/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Me.h"
#import "APIManager.h"
#import "Common.h"
#import "ProfileViewController.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate> {
    BOOL isAvatarChanged;
}

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UITextView *bioTextView;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.bioTextView.layer.borderWidth = 1;
    self.bioTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.bioTextView.layer.shadowOffset = CGSizeMake(2, 2);
    self.bioTextView.layer.shadowRadius = 2;
    self.bioTextView.layer.shadowOpacity = 0.5;
    self.usernameTextField.superview.layer.borderWidth = 1;
    self.usernameTextField.superview.layer.borderColor = [UIColor blackColor].CGColor;
    self.usernameTextField.superview.layer.shadowOffset = CGSizeMake(2, 2);
    self.usernameTextField.superview.layer.shadowRadius = 2;
    self.usernameTextField.superview.layer.shadowOpacity = 0.5;

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 147, 32);
    [self.navigationItem setTitleView:titleButton];
    
    self.navigationItem.title = @" ";
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[[Me me].thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    self.bioTextView.text = [Me me].bio;
    self.usernameTextField.text = [Me me].name;
}
//set text length limit in textview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 150;
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


- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)browse:(id)sender {
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:@"Browse" preferredStyle:UIAlertControllerStyleActionSheet];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    [actionsheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self presentViewController:actionsheet animated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    if (self.usernameTextField.text.length == 0) {
        [Common showAlertWithMessage:@"Please input your username."];
        [self.usernameTextField becomeFirstResponder];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Saving"];
    
    if (isAvatarChanged) {
        [[APIManager sharedManager] uploadAvatar:[Me me]
                                           image:self.avatarImageView.image
                                         success:^(NSString *avatarName, NSString *avatarUrl)
         {
             [[APIManager sharedManager] updateProfile:[Me me]
                                                   bio:self.bioTextView.text
                                              username:self.usernameTextField.text
                                            avatarName:avatarName
                                             avatarUrl:avatarUrl
                                               success:^(Me *me)
              {
                  [me saveOnLocal];
                  
                  [SVProgressHUD dismiss];
                  [self.navigationController popViewControllerAnimated:YES];
                  [Common showAlertWithMessage:@"Your profile was updated."];
              }
                                                failed:^(NSString *message, NSError *error)
              {
                  [SVProgressHUD dismiss];
                  [Common showAlertWithMessage:error ? error.localizedDescription : message];
              }];
         }
                                          failed:^(NSString *message, NSError *error)
         {
             [SVProgressHUD dismiss];
             [Common showAlertWithMessage:error ? error.localizedDescription : message];
         }];
    } else {
        [[APIManager sharedManager] updateProfile:[Me me]
                                              bio:self.bioTextView.text
                                         username:self.usernameTextField.text
                                       avatarName:nil
                                        avatarUrl:nil
                                          success:^(Me *me)
         {
             [me saveOnLocal];

             [SVProgressHUD dismiss];
             [self.navigationController popViewControllerAnimated:YES];
             [Common showAlertWithMessage:@"Your profile was updated."];
         }
                                           failed:^(NSString *message, NSError *error)
         {
             [SVProgressHUD dismiss];
             [Common showAlertWithMessage:error ? error.localizedDescription : message];
         }];
    }
}
- (IBAction)viewProfile:(id)sender {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user = [Me me];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerEditedImage];
        self.avatarImageView.image = image;
        isAvatarChanged = YES;
    }];
}

@end
