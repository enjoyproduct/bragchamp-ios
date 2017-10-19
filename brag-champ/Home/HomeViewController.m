//
//  HomeViewController.m
//  brag-champ
//
//  Created by Apple on 12/13/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoCollectionViewCell.h"
#import "TitledVideoCollectionViewCell.h"
#import "APIManager.h"
#import "Common.h"
#import "Video.h"
#import "User.h"
#import "Me.h"
#import "VideoDetailViewController.h"
#import <SVPullToRefresh.h>
#import <SVProgressHUD.h>

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *popularVideosCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *bestChallengesCollectionView;
@property (nonatomic, weak) IBOutlet UICollectionView *recentVideosCollectionView;

@property (nonatomic, strong) NSArray *popularVideos;
@property (nonatomic, strong) NSArray *bestChallenges;
@property (nonatomic, strong) NSMutableArray *recentVideos;
@property (nonatomic) int offset;
@property (nonatomic) BOOL isLast;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.popularVideosCollectionView registerNib:[UINib nibWithNibName:@"TitledVideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TitledVideoCollectionViewCell"];
    [self.bestChallengesCollectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];
    [self.recentVideosCollectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLikeVideo:) name:kDidLikeVideoNotification object:nil];

//    self.navigationItem.title = @" ";
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navlogo"]]];
    
    [self.recentVideosCollectionView addInfiniteScrollingWithActionHandler:^{
        
        [self getRecentVideos];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.offset = 0;
    self.isLast = NO;
    self.recentVideos = [[NSMutableArray alloc] init];
    [self.recentVideosCollectionView reloadData];
    [self loadVideos];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)loadVideos {
    [[APIManager sharedManager] getPopularVideos:[Me me]
                                         success:^(NSArray *videos)
     {
         self.popularVideos = videos;
         [self.popularVideosCollectionView reloadData];
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
    
    [[APIManager sharedManager] getOpenChallenges:[Me me]
                                          success:^(NSArray *videos)
     {
         self.bestChallenges = videos;
         [self.bestChallengesCollectionView reloadData];
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

    [self getRecentVideos];
    }
- (void) getRecentVideos {
    if (self.isLast) {
        [self.recentVideosCollectionView.infiniteScrollingView stopAnimating];
        return;
    }
    [[APIManager sharedManager] getRecentVideos:[Me me] offset: self.offset
                                        success:^(NSArray *videos)
     {
         [self.recentVideosCollectionView.infiniteScrollingView stopAnimating];

         if (videos.count > 0) {
             self.offset ++;
             [self.recentVideos addObjectsFromArray:videos];
         } else {
             self.isLast = YES;
         }
         
         [self.recentVideosCollectionView reloadData];
     }
                                         failed:^(NSString *message, NSError *error)
     {
         [self.recentVideosCollectionView.infiniteScrollingView stopAnimating];
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

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.popularVideosCollectionView) {
        return self.popularVideos.count;
    } else if (collectionView == self.bestChallengesCollectionView) {
        return self.bestChallenges.count;
    } else if (collectionView == self.recentVideosCollectionView) {
        return self.recentVideos.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.popularVideosCollectionView) {
        TitledVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TitledVideoCollectionViewCell" forIndexPath:indexPath];
        cell.video = self.popularVideos[indexPath.item];
        return cell;
    } else if (collectionView == self.bestChallengesCollectionView) {
        VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
        cell.video = self.bestChallenges[indexPath.item];
        return cell;
    } else if (collectionView == self.recentVideosCollectionView) {
        VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
        cell.video = self.recentVideos[indexPath.item];
        return cell;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    Video *video = nil;
    if (collectionView == self.popularVideosCollectionView) {
        video = self.popularVideos[indexPath.item];
    } else if (collectionView == self.bestChallengesCollectionView) {
        video = self.bestChallenges[indexPath.item];
    } else if (collectionView == self.recentVideosCollectionView) {
        video = self.recentVideos[indexPath.item];
    } else {
        return;
    }

    [self performSegueWithIdentifier:@"showVideoDetail" sender:video];
}


#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVideoDetail"]) {
        VideoDetailViewController *detailVC = (VideoDetailViewController *)segue.destinationViewController;
        detailVC.video = sender;
    }
}


#pragma mark - Notification Handler

- (void)didLikeVideo:(NSNotification *)notification {
    Video *video = notification.object;

    for (Video *v in self.recentVideos) {
        if (video.postId == v.postId) {
            v.like_status = video.like_status;
            v.isCommented = video.isCommented;
            v.isViewed = video.isViewed;
            v.isReplied = video.isReplied;
            
            v.like_count = video.like_count;
            v.trash_count = video.trash_count;
            v.comment_count = video.comment_count;
            v.view_count = video.view_count;
            v.challenge_count = video.challenge_count;
            return;
        }
    }

    for (Video *v in self.bestChallenges) {
        if (video.postId == v.postId) {
            v.like_status = video.like_status;
            v.isCommented = video.isCommented;
            v.isViewed = video.isViewed;
            v.isReplied = video.isReplied;
            
            v.like_count = video.like_count;
            v.trash_count = video.trash_count;
            v.comment_count = video.comment_count;
            v.view_count = video.view_count;
            v.challenge_count = video.challenge_count;
            return;
        }
    }

    for (Video *v in self.recentVideos) {
        if (video.postId == v.postId) {
            v.like_status = video.like_status;
            v.isCommented = video.isCommented;
            v.isViewed = video.isViewed;
            v.isReplied = video.isReplied;
            
            v.like_count = video.like_count;
            v.trash_count = video.trash_count;
            v.comment_count = video.comment_count;
            v.view_count = video.view_count;
            v.challenge_count = video.challenge_count;
            return;
        }
    }
}

@end
