//
//  VideoDetailViewController.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "APIManager.h"
#import "Common.h"
#import "Video.h"
#import "User.h"
#import "Comment.h"
#import "Me.h"
#import "ChallengeVideo.h"
#import "ChallengerCollectionViewCell.h"
#import "CommentTableViewCell.h"
#import "RecordViewController.h"
#import "ChallengeVideoDetailViewController.h"
#import "ProfileViewController.h"

#import <UIImageView+WebCache.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD.h>

//#import "MyMacro.h"

@interface VideoDetailViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, CommentTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *challengeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *likeButton;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *challengeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (nonatomic, weak) IBOutlet UICollectionView *challengersCollectionView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderBorderView;
@property (nonatomic, weak) IBOutlet UITableView *commentsTableView;
@property (nonatomic, weak) IBOutlet UITextField *commentTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) AVPlayer *avplayer;
@property (nonatomic, strong) AVPlayerLayer *avplayerLayer;

@property (nonatomic, strong) NSArray *challenges;
@property (nonatomic, strong) NSMutableArray *comments;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblChallengeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblTrashCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UILabel *lblViewCount;

@end

@implementation VideoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.thumbImageView.layer.cornerRadius = 5;
    self.thumbImageView.layer.shadowOffset = CGSizeMake(3, 3);
    self.thumbImageView.layer.shadowRadius = 3;
    self.thumbImageView.layer.shadowOpacity = 0.5;
    
    self.likeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.commentButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.challengeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.challengersCollectionView registerNib:[UINib nibWithNibName:@"ChallengerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ChallengerCollectionViewCell"];
    [self.commentsTableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentTableViewCell"];
    self.commentsTableView.estimatedRowHeight = 1032;
    self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self getVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLikeVideo:) name:kDidUpdatedVideoSocialInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handler

- (void)didLikeVideo:(NSNotification *)notification {
//    Video *video = notification.object;
//    NSInteger likeCount = video.like_count < 0 ? 0 : video.like_count;
    [self updateSocialInfo];
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


- (void)getVideo {
    if (self.video.user.name) {
        self.usernameLabel.text = [@"@" stringByAppendingString:[self.video.user.name uppercaseString]];
    }

    ///get video detail
        self.usernameLabel.text = @"";

    [[APIManager sharedManager] getVideo:[Me me]
                                      postId:self.video.postId
                                     success:^(Video *video)
     {
         self.video = video;
         self.usernameLabel.text = [@"@" stringByAppendingString:[self.video.user.name uppercaseString]];
         self.challengeLabel.text = self.video.name;

         [self.thumbImageView setShowActivityIndicatorView:YES];
         [self.thumbImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
         [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:[self.video.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];

         [self updateSocialInfo];

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

    
    ////
    if ([Me me].userId == self.video.userId) {
        self.likeButton.enabled = NO;
        self.trashButton.enabled = NO;
        self.challengeButton.enabled = NO;
        self.commentButton.enabled = NO;
    }
    
    self.challengeLabel.text = self.video.name;

    [self.thumbImageView setShowActivityIndicatorView:YES];
    [self.thumbImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:[self.video.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    
    
    [[APIManager sharedManager] getChallengeVideos:[Me me]
                                             video:self.video
                                           success:^(NSArray *videos)
     {
         self.challenges = videos;
         [self.challengersCollectionView reloadData];
         //set challenge count
         if (self.video.user.name) {
             self.lblChallengeCount.text = [NSString stringWithFormat:@"%ld challengers", (long)self.challenges.count];
         }
         
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
    
    [[APIManager sharedManager] getComments:[Me me]
                                      video:self.video
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
    if ([Me me].userId != self.video.userId) {
        
        if (self.video.like_status == 0) {
            self.likeButton.tintColor = COLOR_YELLOW;
            self.trashButton.tintColor = COLOR_GRAY;
        } else if (self.video.like_status == 1) {
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
        if (self.video.isReplied) {
            self.challengeButton.enabled = NO;
            [self.challengeButton setImage:[UIImage imageNamed:@"challenged"] forState:UIControlStateNormal];
        } else if (self.video.isChallengable) {
            self.challengeButton.enabled = YES;
            [self.challengeButton setImage:[UIImage imageNamed:@"challenge"] forState:UIControlStateNormal];
        } else {
            self.challengeButton.enabled = NO;
            [self.challengeButton setImage:[UIImage imageNamed:@"challenge"] forState:UIControlStateNormal];
        }
        if (self.video.isViewed) {
            self.viewButton.tintColor = COLOR_PINK;
        } else {
            self.viewButton.tintColor = COLOR_GRAY;
        }
        
    }
    //set like count
    if (self.video.like_count <= 1) {
        self.lblLikeCount.text = [NSString stringWithFormat:@"%ld Trophy", (long)self.video.like_count];
    } else {
        self.lblLikeCount.text = [NSString stringWithFormat:@"%ld Trophies", (long)self.video.like_count];
    }
    //set trash count
    if (self.video.trash_count <= 1) {
        self.lblTrashCount.text = [NSString stringWithFormat:@"%ld Trash", (long)self.video.trash_count];
    } else {
        self.lblTrashCount.text = [NSString stringWithFormat:@"%ld Trashes", (long)self.video.trash_count];
    }
    
    //set challenge count
    if (self.video.challenge_count <= 1) {
        self.lblChallengeCount.text = [NSString stringWithFormat:@"%ld Challenger", (long)self.video.challenge_count];
    } else {
        self.lblChallengeCount.text = [NSString stringWithFormat:@"%ld Challengers", (long)self.video.challenge_count];
    }
    //set comment count
    if (self.video.comment_count <= 1) {
        self.lblCommentCount.text = [NSString stringWithFormat:@"%ld Comment", (long)self.video.comment_count];
    } else {
        self.lblCommentCount.text = [NSString stringWithFormat:@"%ld Comments", (long)self.video.comment_count];
    }
    //set view count
    if (self.video.view_count <= 1) {
        self.lblViewCount.text = [NSString stringWithFormat:@"%ld View", (long)self.video.view_count];
    } else {
        self.lblViewCount.text = [NSString stringWithFormat:@"%ld Views", (long)self.video.view_count];
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
    if (!self.video.url) {
        return;
    }
    
    NSURL *videoURL = [NSURL URLWithString:[self.video.url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
    self.avplayer = [AVPlayer playerWithURL:videoURL];
    self.avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.avplayerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.avplayerLayer.frame = self.thumbImageView.bounds;
    [self.thumbImageView.layer addSublayer:self.avplayerLayer];
    
    self.avplayer.rate = 1;
    [self.avplayer play];
    
    self.playButton.hidden = YES;
    
    [self viewVideo];
}

- (IBAction)like:(id)sender {
    if (self.video.like_status == 0) {
        self.likeButton.tintColor = COLOR_GRAY;
        
        [[APIManager sharedManager] unlikeVideo:[Me me]
                                        video:self.video
                                      success:^(NSString *message)
         {
             self.video.like_status = -1;
             self.video.like_count --;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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
    } else if (self.video.like_status == -1) {
        self.likeButton.tintColor = COLOR_YELLOW;
        
        [[APIManager sharedManager] likeVideo:[Me me]
                                        video:self.video
                                      success:^(NSString *message)
         {
             self.video.like_status = 0;
             self.video.like_count ++;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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

- (IBAction)challenge:(id)sender {
    [self performSegueWithIdentifier:@"showRecord" sender:nil];
}
- (IBAction)trash:(id)sender {
    if (self.video.like_status == 1) {
        self.trashButton.tintColor = COLOR_GRAY;
        
        [[APIManager sharedManager] unlikeVideo:[Me me]
                                          video:self.video
                                        success:^(NSString *message)
         {
             self.video.like_status = -1;
             self.video.trash_count --;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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
    } else if (self.video.like_status == -1) {
        self.trashButton.tintColor = COLOR_BLACK;
        
        [[APIManager sharedManager] dislikeVideo:[Me me]
                                        video:self.video
                                      success:^(NSString *message)
         {
             self.video.like_status = 1;
             self.video.trash_count ++;
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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
- (IBAction)viewed:(id)sender {
    
}
- (void) viewVideo {
    [[APIManager sharedManager] viewVideo:[Me me]
                                      video:self.video
                                    success:^(NSString *message)
     {
         self.video.view_count ++;
         self.video.isViewed = YES;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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
- (IBAction)tapUsername:(id)sender {
    [self performSegueWithIdentifier:@"showProfile" sender:nil];
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.challenges.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChallengerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChallengerCollectionViewCell" forIndexPath:indexPath];
    
    ChallengeVideo *challenge = self.challenges[indexPath.item];
    cell.user = challenge.user;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"showChallengeVideo" sender:self.challenges[indexPath.item]];
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

#pragma mark - CommentTableViewCellDelegate
- (void) gotoProfile:(User *)user {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) deleteComment:(int)index {
    [SVProgressHUD showWithStatus:@"Deleting..."];
    Comment *comment = [self.comments objectAtIndex:index];
    
    [[APIManager sharedManager] deletePostComment:[Me me] commentId: comment.commentId success:^(NSString * success) {
        [SVProgressHUD dismiss];
        if (success) {
            //            [Common showAlertWithMessage:success];
            [self.comments removeObjectAtIndex:index];
            [self.commentsTableView reloadData];
            self.video.comment_count --;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
            
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


#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RecordViewController class]]) {
        RecordViewController *recordVC = (RecordViewController *)segue.destinationViewController;
        recordVC.video = self.video;
    } else if ([segue.destinationViewController isKindOfClass:[ChallengeVideoDetailViewController class]]) {
        ChallengeVideoDetailViewController *challengeVC = (ChallengeVideoDetailViewController *)segue.destinationViewController;
        challengeVC.video = self.video;
        challengeVC.challengeVideo = sender;
        challengeVC.challenges = self.challenges;
    } else if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]]) {
        ProfileViewController *profileVC = (ProfileViewController *)segue.destinationViewController;
        profileVC.user = self.video.user;
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    NSString *text = textField.text;
    if (textField == self.commentTextField && text.length > 0) {
        if (text.length > 255) {
            text = [text substringToIndex:255];
        }
        
        [[APIManager sharedManager] commentVideo:[Me me]
                                           video:self.video
                                         comment:text
                                         success:^(NSString *message)
         {
             self.commentButton.tintColor = COLOR_YELLOW_DARK;
             Comment *comment = [[Comment alloc] init];
             comment.user = [Me me];
             comment.comment = text;

             [self.comments addObject:comment];
             [self.commentsTableView reloadData];
             self.video.comment_count ++;
             [[NSNotificationCenter defaultCenter] postNotificationName:kDidUpdatedVideoSocialInfoNotification object:self.video];
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
