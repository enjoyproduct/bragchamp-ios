//
//  UsersViewController.m
//  brag-champ
//
//  Created by Apple on 3/6/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "UsersViewController.h"
#import "NotificationTableViewCell.h"
#import "APIManager.h"
#import "Me.h"
#import "Common.h"
#import "Notification.h"
#import "VideoDetailViewController.h"
#import "ChallengeVideoDetailViewController.h"
#import "ProfileViewController.h"
#import "MessageViewController.h"
#import <SVProgressHUD.h>

@interface UsersViewController () <UITableViewDataSource, UITableViewDelegate, NotificationDelegate> {
    NSInteger selectedType;
    UIColor *selectedColor;
    UIColor *normalColor;
}

@property(nonatomic, weak) IBOutlet UIButton *friendButton;
@property(nonatomic, weak) IBOutlet UIButton *mentionButton;
@property(nonatomic, weak) IBOutlet UIButton *likeButton;
@property(nonatomic, weak) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *friendsArray;
@property(nonatomic, strong) NSMutableArray *mentionsArray;
@property(nonatomic, strong) NSMutableArray *likesArray;
@property(nonatomic, strong) NSMutableArray *messagesArray;
@property(nonatomic, strong) NSMutableArray *challengesArray;

@end

@implementation UsersViewController

typedef enum {
    FRIEND = 1,
    MENTION = 2,
    LIKE = 3,
    MESSAGE = 4,
    CHALLENGE = 5
} SELECT_TYPE;

typedef enum {
    N_FRIEND = 1,
    MENTION1 = 2,
    MENTION2 = 3,
    LIKE1 = 4,
    LIKE2 = 5,
    N_MESSAGE = 6,
    N_CHALLENGE = 7
} NOTIFICATION_TYPE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedType = FRIEND;
    [self.tableView registerNib:[UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil] forCellReuseIdentifier:@"NotificationTableViewCell"];
    self.tableView.allowsSelection = NO;
    
    selectedColor = [UIColor colorWithRed:1 green:0 blue:162.0/255 alpha:1];
    normalColor = [UIColor colorWithWhite:55.0/255 alpha:1];
    
    self.navigationItem.title = @" ";
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navlogo"]]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self changeButtonState];
    [self loadNotifications];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)loadNotifications {
    if (selectedType == FRIEND) {
        [self loadFriends];
    } else if (selectedType == MENTION) {
        [self loadMentions];
    } else if (selectedType == LIKE) {
        [self loadLikes];
    } else if (selectedType == MESSAGE) {
        [self loadMessage];
    } else if (selectedType == CHALLENGE) {
        [self loadChallenage];
    }
}

- (void)loadFriends {
    [SVProgressHUD showWithStatus:@"Loading friend requests..."];
    [[APIManager sharedManager] getNotifications:[Me me]
                                            type:@"1"
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.friendsArray = result;
                                             [self.tableView reloadData];
                                         }
                                          failed:^(NSString *message, NSError *error) {
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

- (void)loadMentions {
    [SVProgressHUD showWithStatus:@"Loading mentions..."];
    [[APIManager sharedManager] getNotifications:[Me me]
                                            type:@"2,3"
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.mentionsArray = result;
                                             [self.tableView reloadData];
                                         }
                                          failed:^(NSString *message, NSError *error) {
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

- (void)loadLikes {
    [SVProgressHUD showWithStatus:@"Loading trophies..."];
    [[APIManager sharedManager] getNotifications:[Me me]
                                            type:@"4,5"
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.likesArray = result;
                                             [self.tableView reloadData];
                                         }
                                          failed:^(NSString *message, NSError *error) {
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
- (void)loadMessage {
    [SVProgressHUD showWithStatus:@"Loading messages..."];
    [[APIManager sharedManager] getNotifications:[Me me]
                                            type:@"6"
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.messagesArray = result;
                                             [self.tableView reloadData];
                                         }
                                          failed:^(NSString *message, NSError *error) {
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
- (void)loadChallenage {
    [SVProgressHUD showWithStatus:@"Loading challenges..."];
    [[APIManager sharedManager] getNotifications:[Me me]
                                            type:@"7"
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.challengesArray = result;
                                             [self.tableView reloadData];
                                         }
                                          failed:^(NSString *message, NSError *error) {
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

- (void)changeButtonState {
    switch (selectedType) {
        case FRIEND:
            [self.friendButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.mentionButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.likeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.challengeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.messageButton setTitleColor:normalColor forState:UIControlStateNormal];
            break;
        case MENTION:
            [self.friendButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.mentionButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.likeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.challengeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.messageButton setTitleColor:normalColor forState:UIControlStateNormal];
            break;
        case LIKE:
            [self.friendButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.mentionButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.likeButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.challengeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.messageButton setTitleColor:normalColor forState:UIControlStateNormal];
            break;
        case MESSAGE:
            [self.friendButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.mentionButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.likeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.challengeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.messageButton setTitleColor:selectedColor forState:UIControlStateNormal];
            break;
        case CHALLENGE:
            [self.friendButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.mentionButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.likeButton setTitleColor:normalColor forState:UIControlStateNormal];
            [self.challengeButton setTitleColor:selectedColor forState:UIControlStateNormal];
            [self.messageButton setTitleColor:normalColor forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (IBAction)onFriendsButton:(id)sender {
    if (selectedType != FRIEND) {
        selectedType = FRIEND;
        [self changeButtonState];
        [self loadNotifications];
    }
}

- (IBAction)onMentionsButton:(id)sender {
    if (selectedType != MENTION) {
        selectedType = MENTION;
        [self changeButtonState];
        [self loadNotifications];
    }
}

- (IBAction)onLikesButton:(id)sender {
    if (selectedType != LIKE) {
        selectedType = LIKE;
        [self changeButtonState];
        [self loadNotifications];
    }
}

- (IBAction)onMessagesButton:(id)sender {
    if (selectedType != MESSAGE) {
        selectedType = MESSAGE;
        [self changeButtonState];
        [self loadNotifications];
    }
}
- (IBAction)onChallengesButton:(id)sender {
    if (selectedType != CHALLENGE) {
        selectedType = CHALLENGE;
        [self changeButtonState];
        [self loadNotifications];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (selectedType == FRIEND)
        return _friendsArray.count;
    else if (selectedType == MENTION)
        return _mentionsArray.count;
    else if (selectedType == LIKE)
        return _likesArray.count;
    else if (selectedType == MESSAGE)
        return _messagesArray.count;
    else if (selectedType == CHALLENGE)
        return _challengesArray.count;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell"];
    Notification *item;
    if (selectedType == FRIEND)
        item = _friendsArray[indexPath.row];
    else if (selectedType == MENTION)
        item = _mentionsArray[indexPath.row];
    else if (selectedType == LIKE)
        item = _likesArray[indexPath.row];
    else if (selectedType == MESSAGE)
        item = _messagesArray[indexPath.row];
    else if (selectedType == CHALLENGE)
        item = _challengesArray[indexPath.row];
    
    cell.notification = item;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - NotificationDelegate

- (void)onViewButton:(Notification *)notification {
    
    if (notification.type == FRIEND) {
        [self approveNotification:notification state:1];
    } else {
        [self viewNotification:notification];
    }
}

- (void)onIgnoreButton:(Notification *)notification {
    if (notification.type == FRIEND) {
        [self approveNotification:notification state:2];
    } else {
        [self ignoreNotification:notification];
    }
    
}
- (void) gotoProfile:(User *)user {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    vc.user = user;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)goVideoViewController:(Notification *)notification {
    VideoDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoDetailViewController"];
    controller.video = notification.video;
    [self.navigationController pushViewController:controller animated:true];
    
}

- (void)goChallengeVideoViewController:(Notification *)notification {
    ChallengeVideoDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChallengeVideoDetailViewController"];
    controller.challengeVideo = notification.challenge;
    [self.navigationController pushViewController:controller animated:true];
}

- (void)goMessageViewController:(Notification *)notification {
    MessageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    controller.user = notification.user;
    
    [self.navigationController pushViewController:controller animated:true];
}

- (void)viewNotification:(Notification *)notification {
    [SVProgressHUD showWithStatus:@"Loading..."];
    [[APIManager sharedManager] viewNotification:[Me me] notificationId:notification.notificationId success:^(NSString *result) {
        [SVProgressHUD dismiss];
        if (notification.type == MENTION1 || notification.type == LIKE1 ) {
            [self goVideoViewController:notification];
        } else if (notification.type == MENTION2 || notification.type == LIKE2 || notification.type == N_CHALLENGE) {
            [self goChallengeVideoViewController:notification];
        } else if (notification.type == N_MESSAGE) {
            [self goMessageViewController:notification];
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
        
        [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
    }];
}

- (void)ignoreNotification:(Notification *)notification {
    [SVProgressHUD show];
    [[APIManager sharedManager] removeNotification:[Me me] notificationId:notification.notificationId success:^(NSString *result) {
        [SVProgressHUD dismiss];
        switch (selectedType) {
            case FRIEND:
                [_friendsArray removeObject:notification];
                break;
            case MENTION:
                [_mentionsArray removeObject:notification];
                break;
            case LIKE:
                [_likesArray removeObject:notification];
                break;
            case MESSAGE:
                [_messagesArray removeObject:notification];
                break;
            case CHALLENGE:
                [_challengesArray removeObject:notification];
                break;
            default:
                break;
        }
        [self.tableView reloadData];
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

- (void)approveNotification:(Notification *)notification state:(NSInteger)state {
    [SVProgressHUD show];
    [[APIManager sharedManager] approveNotification:[Me me]
                                     notificationId:notification.notificationId
                                           followId:notification.followId
                                              state:state
                                            success:^(NSString *message) {
                                                [SVProgressHUD dismiss];
                                                [Common showAlertWithMessage:message];
                                                [self.friendsArray removeObject:notification];
                                                [self.tableView reloadData];
                                            }
                                             failed:^(NSString *message, NSError *error) {
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

@end
