//
//  SearchViewController.m
//  brag-champ
//
//  Created by Apple on 3/10/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "SearchViewController.h"
#import "APIManager.h"
#import "Common.h"
#import "User.h"
#import "Me.h"
#import "Video.h"
#import "VideoCollectionViewCell.h"
#import "ChallengerCollectionViewCell.h"
#import "VideoDetailViewController.h"
#import "ProfileViewController.h"

#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>

@interface SearchViewController () <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    BOOL isChallenges;
}

@property (nonatomic, weak) IBOutlet UIButton *challengeButton;
@property (nonatomic, weak) IBOutlet UIButton *peopleButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) NSArray *challenges;
@property (nonatomic, strong) NSArray *users;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isChallenges = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"ChallengerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ChallengerCollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 120, 40);
    [self.navigationItem setTitleView:titleButton];
    
    self.navigationItem.title = @" ";
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

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (IBAction)challenges:(id)sender {
    [self.searchTextField resignFirstResponder];
    
    if (isChallenges) {
        [self textFieldShouldReturn:self.searchTextField];
        return;
    }
    
    self.challengeButton.tintColor = [UIColor colorWithRed:1 green:0 blue:162.0/255 alpha:1];
    self.peopleButton.tintColor = [UIColor colorWithWhite:55.0/255 alpha:1];
    isChallenges = YES;

    self.challenges = nil;
    self.users = nil;
    [self.collectionView reloadData];

    [self textFieldShouldReturn:self.searchTextField];
}

- (IBAction)users:(id)sender {
    [self.searchTextField resignFirstResponder];

    if (!isChallenges) {
        [self textFieldShouldReturn:self.searchTextField];
        return;
    }
    
    self.challengeButton.tintColor = [UIColor colorWithWhite:55.0/255 alpha:1];
    self.peopleButton.tintColor = [UIColor colorWithRed:1 green:0 blue:162.0/255 alpha:1];
    isChallenges = NO;

    self.challenges = nil;
    self.users = nil;
    [self.collectionView reloadData];
    
    [self textFieldShouldReturn:self.searchTextField];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (isChallenges ? self.challenges : self.users).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (isChallenges) {
        VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
        cell.video = self.challenges[indexPath.item];
        return cell;
    } else {
        ChallengerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChallengerCollectionViewCell" forIndexPath:indexPath];
        cell.user = self.users[indexPath.item];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (isChallenges) {
        [self performSegueWithIdentifier:@"showVideo" sender:self.challenges[indexPath.item]];
    } else {
        [self performSegueWithIdentifier:@"showProfile" sender:self.users[indexPath.item]];
    }
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVideo"]) {
        VideoDetailViewController *videoVC = (VideoDetailViewController *)segue.destinationViewController;
        videoVC.video = sender;
    } else if ([segue.identifier isEqualToString:@"showProfile"]) {
        ProfileViewController *profileVC = (ProfileViewController *)segue.destinationViewController;
        profileVC.user = sender;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *text = textField.text;
    if (text.length > 0) {
        if (isChallenges) {
            [SVProgressHUD showWithStatus:@"Loading..."];
            [[APIManager sharedManager] searchChallenges:[Me me]
                                                     key:text
                                                 success:^(NSArray *result) {
                                                     [SVProgressHUD dismiss];
                                                     self.challenges = result;
                                                     [self.collectionView reloadData];
                                                 } failed:^(NSString *message, NSError *error) {
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
        } else {
            [SVProgressHUD showWithStatus:@"Loading..."];
            [[APIManager sharedManager] searchUsers:[Me me]
                                                key:text
                                            success:^(NSArray *result) {
                                                [SVProgressHUD dismiss];
                                                self.users = result;
                                                [self.collectionView reloadData];
                                            } failed:^(NSString *message, NSError *error) {
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
        
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomConstraint.constant = 0;
        }];
    }
    
    return YES;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (frame.size.height == 0 || frame.origin.y + frame.size.height > [UIScreen mainScreen].bounds.size.height) {
        // Hide Keyboard
        [UIView animateWithDuration:duration animations:^{
            self.bottomConstraint.constant = 0;
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.bottomConstraint.constant = frame.size.height;
        }];
    }
}

@end
