//
//  ProfileViewController.m
//  brag-champ
//
//  Created by Apple on 2/10/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIManager.h"
#import "User.h"
#import "Me.h"
#import "Video.h"
#import "VideoCollectionViewCell.h"
#import "VideoDetailViewController.h"
#import "MessageViewController.h"
#import "Common.h"
#import "FollowerListViewController.h"

#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, VideoCollectionViewCellDelegate>

@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;

@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIButton *blockButton;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *menuView;

@property (weak, nonatomic) IBOutlet UILabel *lblFollowers;
@property (weak, nonatomic) IBOutlet UILabel *lblFollowing;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblTrashCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UILabel *lblChallengeCount;
@property (weak, nonatomic) IBOutlet UILabel *lblViewCount;



@property (nonatomic, strong) NSMutableArray *videos;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.user == nil) {
        self.user = [Me me];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 147, 32);
    [self.navigationItem setTitleView:titleButton];
    
    self.navigationItem.title = @" ";
    
//    [self displayUser];
    [self loadUserInfo];
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


- (void)displayUser {
    
    self.usernameLabel.text = [@"@" stringByAppendingString:[self.user.name uppercaseString]];
    
    NSString *bio = self.user.bio;
    if (bio.length > 150) { //meaning 51+
        /* trim the string. Its important to note that substringToIndex returns a
         new string containing the characters of the receiver up to, but not
         including, the one at a given index. In other words, it goes up to 50,
         but not 50, so that means we have to do desired number + 1.
         Additionally, this method includes counting white-spaces */
        
        bio = [self.user.bio substringToIndex:51];
    }
    self.bioLabel.text = bio.length ? self.user.bio : @"-";
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[self.user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    self.lblFollowers.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:@(self.user.followers)]];
    self.lblFollowing.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:@(self.user.followings)]];
    self.lblLikeCount.text = [NSString stringWithFormat:@"%ld", (long)self.user.like_count];
    self.lblTrashCount.text = [NSString stringWithFormat:@"%ld", (long)self.user.trash_count];
    self.lblCommentCount.text = [NSString stringWithFormat:@"%ld", (long)self.user.comment_count];
    self.lblChallengeCount.text = [NSString stringWithFormat:@"%ld", (long)self.user.challenge_count];
    self.lblViewCount.text = [NSString stringWithFormat:@"%ld", (long)self.user.view_count];
    
    
    if ([self isMe]) {
        [self.followButton setTitle:@"Edit" forState:UIControlStateNormal];
        self.menuButton.hidden = YES;
    } else {
        [self.followButton setTitle:self.user.isFollowing ? @"Unfollow" : @"Follow" forState:UIControlStateNormal];
        [self.blockButton setTitle:self.user.isBlocked ? @"UNBLOCK" : @"BLOCK" forState:UIControlStateNormal];
        self.menuButton.hidden = NO;
    }
}
- (BOOL) isMe {
    if (self.user.userId == [Me me].userId) {
        return YES;
    } else {
        return NO;
    }
}
- (void)loadUserInfo {
    [SVProgressHUD show];
    self.followButton.userInteractionEnabled = NO;
    self.menuButton.userInteractionEnabled = NO;
    
    [[APIManager sharedManager] getUserInfo:[Me me] userId:self.user.userId success:^(User *user, NSArray *videos) {
        [SVProgressHUD dismiss];
        
        self.followButton.userInteractionEnabled = YES;
        self.menuButton.userInteractionEnabled = YES;

        self.user = user;
        [self displayUser];
        
        self.videos = videos;
        [self.collectionView reloadData];
        
    } failed:^(NSString *message, NSError *error) {
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        [Common showAlertWithMessage:error ? error.localizedDescription : message];
    }];
}


- (IBAction)openMenu:(id)sender {
    self.menuView.alpha = 0;
    self.menuView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.alpha = 1;
    }];
}

- (IBAction)closeMenu:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.alpha = 0;
    } completion:^(BOOL finished) {
        self.menuView.hidden = YES;
    }];
}
- (IBAction)followers:(id)sender {
    FollowerListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerListViewController"];
    vc.type = @"FOLLOWERS";
    vc.user_id = self.user.userId;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)followings:(id)sender {
    FollowerListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowerListViewController"];
    vc.type = @"FOLLOWINGS";
    vc.user_id = self.user.userId;
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}


- (IBAction)follow:(id)sender {
    if ([self isMe]) {
        [self performSegueWithIdentifier:@"editProfile" sender:nil];
        return;
    }
    
    [self closeMenu:nil];
    
    [SVProgressHUD showWithStatus:self.user.isFollowing ? @"Unfollowing" : @"Following"];
    
    [[APIManager sharedManager] follow:[Me me]
                                  user:self.user
                                follow:!self.user.isFollowing
                               success:^(NSDictionary *result)
     {
         [SVProgressHUD dismiss];
         
         self.user.isFollowing = !self.user.isFollowing;
         self.user.followers = [result[@"follower_count"] integerValue];
         self.user.followings = [result[@"following_count"] integerValue];
         [self displayUser];
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

- (IBAction)sendMessage:(id)sender {
    [self closeMenu:nil];
    
    MessageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    controller.user = self.user;
    
    [self.navigationController pushViewController:controller animated:true];

}

- (IBAction)block:(id)sender {
    [self closeMenu:nil];

    [SVProgressHUD showWithStatus:self.user.isBlocked ? @"Unblocking" : @"Blocking"];
    
    [[APIManager sharedManager] block:[Me me]
                                 user:self.user
                                block:!self.user.isBlocked
                              success:^(NSString *message)
     {
         [SVProgressHUD dismiss];
         
         self.user.isBlocked = !self.user.isBlocked;
         [self displayUser];
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

- (IBAction)report:(id)sender {
    [self closeMenu:nil];

    [SVProgressHUD showWithStatus:@"Reporting"];

    [[APIManager sharedManager] report:[Me me] user:self.user content:@"Report" success:^(NSString *message) {
        [SVProgressHUD dismiss];
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

#pragma mark -VideoCollectionViewCellDelegate
- (void) deleteVideo:(int)index {
    [SVProgressHUD showWithStatus:@"Deleting..."];
    Video *video = [self.videos objectAtIndex:index];
    
    [[APIManager sharedManager] deleteVideo:[Me me] postId: video.postId success:^(NSString * success) {
        [SVProgressHUD dismiss];
        if (success) {
            //            [Common showAlertWithMessage:success];
            [self.videos removeObjectAtIndex:index];
            [self.collectionView reloadData];
            
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

#pragma mark - Videos CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
    cell.video = self.videos[indexPath.item];
    if ([self isMe]) {
        cell.btnDelete.hidden = NO;
        cell.delegate = self;
        cell->index = indexPath.row;
    } else {
        cell.btnDelete.hidden = YES;
        cell.delegate = NULL;
        cell->index = 0;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    Video *video = self.videos[indexPath.item];
    [self performSegueWithIdentifier:@"showVideoDetail" sender:video];
}


#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVideoDetail"]) {
        VideoDetailViewController *detailVC = (VideoDetailViewController *)segue.destinationViewController;
        detailVC.video = sender;
    }
}

@end
