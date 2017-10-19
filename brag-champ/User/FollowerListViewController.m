//
//  FollowerListViewController.m
//  brag-champ
//
//  Created by Admin on 8/22/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "FollowerListViewController.h"
#import "FollowTableViewCell.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "User.h"
#import "APIManager.h"
#import "Me.h"
#import "Common.h"
#import "ProfileViewController.h"


@interface FollowerListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblBanner;
@property(nonatomic, strong) NSMutableArray *userArray;

@end

@implementation FollowerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowTableViewCell" bundle:nil] forCellReuseIdentifier:@"FollowTableViewCell"];
    
    
    self.lblBanner.text = _type;
    [self loadFollowers];
}
- (void) loadFollowers {
    [SVProgressHUD show];
    
    [[APIManager sharedManager] getFollowers:[Me me]
                                      user_id:_user_id
                                follow_type:_type
                                    success:^(NSArray *users)
     {
         [SVProgressHUD dismiss];
         self.userArray = [NSMutableArray arrayWithArray:users];
         [self.tableView reloadData];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FollowTableViewCell"];
    User *user = self.userArray[indexPath.row];
    [cell.ivAvatar setShowActivityIndicatorView:YES];
    [cell.ivAvatar setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.ivAvatar sd_setImageWithURL:[NSURL URLWithString:[user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    
    cell.lblUsername.text = user.name;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user = self.userArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
