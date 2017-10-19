//
//  ChallengeVideoDetailViewController.m
//  brag-champ
//
//  Created by Apple on 1/5/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "ChallengeVideoDetailViewController.h"
#import "Common.h"
#import "Video.h"
#import "User.h"
#import "Me.h"
#import "ChallengeVideo.h"
#import "APIManager.h"
#import "ChallengerCollectionViewCell.h"
#import "CommentTableViewCell.h"
#import "ProfileViewController.h"
#import "Comment.h"

#import <UIImageView+WebCache.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD.h>

@interface ChallengeVideoDetailViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, CommentTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;



@property (nonatomic, weak) IBOutlet UICollectionView *challengersCollectionView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderBorderView;
@property (nonatomic, weak) IBOutlet UITableView *commentsTableView;
@property (nonatomic, weak) IBOutlet UITextField *commentTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) AVPlayer *avplayer;
@property (nonatomic, strong) AVPlayerLayer *avplayerLayer;

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSArray *otherChallenges;
@property (nonatomic, strong) ChallengeVideo *selectedChallenge;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblChallengeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblTrashCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;


@end

@implementation ChallengeVideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.thumbImageView.layer.cornerRadius = 5;
    self.thumbImageView.layer.shadowOffset = CGSizeMake(3, 3);
    self.thumbImageView.layer.shadowRadius = 3;
    self.thumbImageView.layer.shadowOpacity = 0.5;
    
    self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.commentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.challengersCollectionView registerNib:[UINib nibWithNibName:@"ChallengerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ChallengerCollectionViewCell"];
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    self.commentsTableView.estimatedRowHeight = 1032;
    self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self displayVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLikeVideo:) name:kDidUpdatedChallengeSocialInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 147, 32);
    [self.navigationItem setTitleView:titleButton];

    self.navigationItem.title = @" ";
}
#pragma mark - Notification Handler

- (void)didLikeVideo:(NSNotification *)notification {
    //    Video *video = notification.object;
    //    NSInteger likeCount = video.like_count < 0 ? 0 : video.like_count;
    [self updateSocialInfo];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if (notification.object != self.avplayer.currentItem) {
        return;
    }
    
    [self.avplayer seekToTime:kCMTimeZero];
    
    self.avplayer.rate = 1;
    [self.avplayer play];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.avplayer) {
        [self.avplayerLayer removeFromSuperlayer];
        self.avplayerLayer = nil;
        
        [self.avplayer pause];
        self.avplayer = nil;
    }
    
    self.playButton.hidden = NO;

    [self.commentTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIView *headerView = self.commentsTableView.tableHeaderView;
    
    CGRect frame = headerView.frame;
    frame.size.height = self.tableHeaderBorderView.frame.origin.y;
    headerView.frame = frame;
    
    self.commentsTableView.tableHeaderView = headerView;
}



- (void)setChallenges:(NSArray *)challenges {
    _challenges = challenges;
    
    NSMutableArray *mutableChallenges = [self.challenges mutableCopy];
    [mutableChallenges removeObject:self.challengeVideo];
    self.otherChallenges = mutableChallenges;
    
    [self.challengersCollectionView reloadData];
}

- (void)displayVideo {
    self.usernameLabel.text = [@"@" stringByAppendingString:[self.challengeVideo.user.name uppercaseString]];
    
    [self.thumbImageView setShowActivityIndicatorView:YES];
    [self.thumbImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:[self.challengeVideo.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    
    if (self.video.isCommented) {
        self.commentButton.tintColor = COLOR_YELLOW_DARK;
    } else {
        self.commentButton.tintColor = COLOR_GRAY;
    }
    if ([Me me].userId == self.challengeVideo.userId) {
        self.likeButton.enabled = NO;
        self.trashButton.enabled = NO;
        self.commentButton.enabled = NO;
    } else {
        self.likeButton.enabled = YES;
        self.trashButton.enabled = YES;
        self.commentButton.enabled = YES;
        
    }
    [self updateSocialInfo];
    
    [self.challengersCollectionView reloadData];
    
    [[APIManager sharedManager] getChallengeComments:[Me me]
                                           challenge:self.challengeVideo
                                             success:^(NSArray *comments)
     {
         self.comments = [NSMutableArray arrayWithArray:comments];
         [self.commentsTableView reloadData];
     }
                                     failed:^(NSString *message, NSError *error)
     {
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
- (void) updateSocialInfo {
    if (self.challengeVideo.like_status == 0) {
        self.likeButton.tintColor = COLOR_YELLOW;
        self.trashButton.tintColor = COLOR_GRAY;
    } else if (self.challengeVideo.like_status == 1) {
        self.likeButton.tintColor = COLOR_GRAY;
        self.trashButton.tintColor = COLOR_BLACK;
    } else {
        self.likeButton.tintColor = COLOR_GRAY;
        self.trashButton.tintColor = COLOR_GRAY;
    }
    if (self.video.isCommented) {
        self.commentButton.tintColor = COLOR_YELLOW_DARK;
    } else {
        self.commentButton.tintColor = COLOR_GRAY;
    }

    //set like count
    if (self.challengeVideo.like_count <= 1) {
        self.lblLikeCount.text = [NSString stringWithFormat:@"%ld Trophy", (long)self.challengeVideo.like_count];
    } else {
        self.lblLikeCount.text = [NSString stringWithFormat:@"%ld Trophies", (long)self.challengeVideo.like_count];
    }
    //set trash count
    if (self.challengeVideo.trash_count <= 1) {
        self.lblTrashCount.text = [NSString stringWithFormat:@"%ld Trashed", (long)self.challengeVideo.trash_count];
    } else {
        self.lblTrashCount.text = [NSString stringWithFormat:@"%ld Trashed", (long)self.challengeVideo.trash_count];
    }
    //set comment count
    if (self.challengeVideo.comment_count <= 1) {
        self.lblCommentCount.text = [NSString stringWithFormat:@"%ld Comment", (long)self.challengeVideo.comment_count];
    } else {
        self.lblCommentCount.text = [NSString stringWithFormat:@"%ld Comments", (long)self.challengeVideo.comment_count];
    }

}

- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (IBAction)play:(id)sender {
    if (!self.challengeVideo.url) {
        return;
    }
    
    NSURL *videoURL = [NSURL URLWithString:[self.challengeVideo.url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
    self.avplayer = [AVPlayer playerWithURL:videoURL];
    self.avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.avplayerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.avplayerLayer.frame = self.thumbImageView.bounds;
    [self.thumbImageView.layer addSublayer:self.avplayerLayer];
    
    self.avplayer.rate = 1;
    [self.avplayer play];
    
    self.playButton.hidden = YES;
}

- (IBAction)like:(id)sender {
    if (self.challengeVideo.like_status == 0) {
        self.likeButton.tintColor = COLOR_GRAY;
        
        [[APIManager sharedManager] unlikeChallengeVideo:[Me me]
                                                  postId:self.challengeVideo.challengeId
                                                 success:^(NSString *message)
         {
             self.challengeVideo.like_status = -1;
             self.challengeVideo.like_count --;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
         }
                                                  failed:^(NSString *message, NSError *error)
         {
             self.likeButton.tintColor = COLOR_YELLOW;
             
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
    } else if (self.challengeVideo.like_status == -1) {
        self.likeButton.tintColor = COLOR_YELLOW;
        
        [[APIManager sharedManager] likeChallengeVideo:[Me me]
                                                postId:self.challengeVideo.challengeId
                                               success:^(NSString *message)
         {
             self.challengeVideo.like_status = 0;
             self.challengeVideo.like_count ++;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
         }
                                       failed:^(NSString *message, NSError *error)
         {
             self.likeButton.tintColor = COLOR_GRAY;
             
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
}

- (IBAction)comment:(id)sender {
    if (self.bottomConstraint.constant != 0) {
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomConstraint.constant = self.commentTextField.frame.size.height;
    }];
}
- (IBAction)trash:(id)sender {
    if (self.challengeVideo.like_status == 1) {
        self.trashButton.tintColor = COLOR_GRAY;
        
        [[APIManager sharedManager] unlikeChallengeVideo:[Me me]
                                                  postId:self.challengeVideo.challengeId
                                                 success:^(NSString *message)
         {
             self.challengeVideo.like_status = -1;
             self.challengeVideo.trash_count --;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
         }
                                                  failed:^(NSString *message, NSError *error)
         {
             self.trashButton.tintColor = COLOR_BLACK;
             
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
    } else if (self.challengeVideo.like_status == -1) {
        self.trashButton.tintColor = COLOR_BLACK;
        
        [[APIManager sharedManager] likeChallengeVideo:[Me me]
                                                postId:self.challengeVideo.challengeId
                                               success:^(NSString *message)
         {
             self.challengeVideo.like_status = 1;
             self.challengeVideo.trash_count ++;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
         }
                                                failed:^(NSString *message, NSError *error)
         {
             self.trashButton.tintColor = COLOR_GRAY;
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
}



- (IBAction)tapUsername:(id)sender {
    [self performSegueWithIdentifier:@"showProfile" sender:nil];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.otherChallenges.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChallengerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChallengerCollectionViewCell" forIndexPath:indexPath];
    ChallengeVideo *challenge = self.otherChallenges[indexPath.item];
    cell.user = challenge.user;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.selectedChallenge = self.otherChallenges[indexPath.item];
    
    ChallengeVideoDetailViewController *challengeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChallengeVideoDetailViewController"];
    challengeVC.video = self.video;
    challengeVC.challengeVideo = self.selectedChallenge;
    challengeVC.challenges = self.challenges;
    [self.navigationController pushViewController:challengeVC animated:YES];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell"];
    Comment *comment = self.comments[indexPath.row];
    cell.comment = comment;
    cell.delegate = self;
    if (comment.user.userId == [Me me].userId) {
        cell.btnDelete.hidden = NO;
        cell->index = indexPath.row;
    } else {
        cell.btnDelete.hidden = YES;
        cell->index = 0;
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
        ProfileViewController *profileVC = (ProfileViewController *)segue.destinationViewController;
        profileVC.user = self.challengeVideo.user;
    }
}
#pragma mark - CommentTableViewCellDelegate
- (void) gotoProfile:(User *)user {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) deleteComment:(int)index {
    [SVProgressHUD showWithStatus:@"Deleting..."];
    Comment *comment = [self.comments objectAtIndex:index];
    
    [[APIManager sharedManager] deleteChallengeComment:[Me me] commentId: comment.commentId success:^(NSString * success) {
        [SVProgressHUD dismiss];
        if (success) {
            //            [Common showAlertWithMessage:success];
            [self.comments removeObjectAtIndex:index];
            [self.commentsTableView reloadData];
            self.challengeVideo.comment_count --;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
            return;
        }
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
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    NSString *text = textField.text;
    if (textField == self.commentTextField && text.length > 0) {
        if (text.length > 255) {
            text = [text substringToIndex:255];
        }
        
        [[APIManager sharedManager] commentChallenge:[Me me]
                                           challenge:self.challengeVideo
                                             comment:text
                                             success:^(NSString *message)
         {
             self.commentButton.tintColor = COLOR_YELLOW_DARK;
             
             Comment *comment = [[Comment alloc] init];
             comment.user = [Me me];
             comment.comment = text;
             [self.comments addObject:comment];
             [self.commentsTableView reloadData];
             self.challengeVideo.comment_count ++;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedChallengeSocialInfoNotification object:self.challengeVideo];
             
         }
                                              failed:^(NSString *message, NSError *error)
         {
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
        
        textField.text = @"";
        
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
            self.bottomConstraint.constant = self.commentTextField.bounds.size.height;
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            self.bottomConstraint.constant = self.commentTextField.bounds.size.height + frame.size.height;
        }];
    }
}

@end
