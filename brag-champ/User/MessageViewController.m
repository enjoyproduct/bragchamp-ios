//
//  MessageViewController.m
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "MessageViewController.h"
#import "APIManager.h"
#import "Me.h"
#import "Common.h"
#import "Notification.h"
#import <SVProgressHUD.h>
#import "Message.h"
#import "IncomeMessageTableViewCell.h"
#import "OutGoMessageTableViewCell.h"
#import <UIImageView+WebCache.h>

@interface MessageViewController ()  <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, OutGoMessageTableViewCellDelegate>{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *ivAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tfInputBox;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputboxBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property(nonatomic, strong) NSMutableArray *messagesArray;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //init navigation bar
    self.navigationItem.title = @" ";
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"navbar"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navlogo"]]];
    
    //register custom cell
    [self.tableView registerNib:[UINib nibWithNibName:@"IncomeMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"IncomeMessageTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"OutGoMessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"OutGoMessageTableViewCell"];
    //init tableview
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    //keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //set user info
    if (self.user != NULL) {
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.width / 2;
        self.ivAvatar.layer.masksToBounds = YES;
        [self.ivAvatar sd_setImageWithURL:[NSURL URLWithString:[self.user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
        
        self.lblUsername.text = [NSString stringWithFormat:@"Conversation with @%@", self.user.name];
    }
    
    [self loadMessage];
}
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideKeyboard];
}
- (void) hideKeyboard {
    [self.view endEditing:YES];
}
- (void) keyboardWillShow: (NSNotification*) notification {
    
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
//    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        if (_inputboxBottomConstraint.constant == 0) {
            self.inputboxBottomConstraint.constant = height;
            self.tableViewBottomConstraint.constant = self.tableViewBottomConstraint.constant + height;
            self.tableViewTopConstraint.constant = self.tableViewTopConstraint.constant - height;
            [self.view layoutIfNeeded];
            
        }
    }];
}
- (void) keyboardWillHide: (NSNotification*) notification {
    
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
    //    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:animationDuration animations:^{
        if (_inputboxBottomConstraint.constant == height) {
            self.inputboxBottomConstraint.constant = 0;
            self.tableViewBottomConstraint.constant = self.tableViewBottomConstraint.constant - height;
            self.tableViewTopConstraint.constant = self.tableViewTopConstraint.constant + height;
            [self.view layoutIfNeeded];

        }
    }];
}
- (IBAction)clickedSettings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}
- (void)loadMessage {
    self.messagesArray = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithStatus:@"Loading messages..."];
    [[APIManager sharedManager] getMessage:[Me me]
                                            userId:self.user.userId
                                         success:^(NSMutableArray *result) {
                                             [SVProgressHUD dismiss];
                                             self.messagesArray = result;
                                             [self.tableView reloadData];
                                             [self scrollToBottom];
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
- (void)scrollToBottom {
    if (self.messagesArray.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.messagesArray count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (IBAction)clickedSend:(UIButton *)sender {
    NSString* message = self.tfInputBox.text;
    if (message.length > 0) {
        [self sendMessage:message];
        Message* newMsg = [[Message alloc] init];
        newMsg.senderId = [Me me].userId;
        newMsg.receiverId = self.user.userId;
        newMsg.message = message;
        newMsg.date = [[NSDate date] timeIntervalSince1970];
        [self.messagesArray addObject:newMsg];
        [self.tableView reloadData];
        [self scrollToBottom];
        
    } else {
        
    }
    self.tfInputBox.text = @"";
}
- (void)sendMessage:(NSString *)message {
//    [SVProgressHUD showWithStatus:@"Sending..."];
    [[APIManager sharedManager] sendMessage:[Me me] receiverId:self.user.userId message:message success:^(NSString * success) {
        [SVProgressHUD dismiss];
        if (success) {
//            [Common showAlertWithMessage:success];
            return;
        }
    } failed:^(NSString *message, NSError *error) {
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
#pragma mark -OutGoMessageTableViewCellDelegate
- (void) deleteMessage:(int)index {
    [SVProgressHUD showWithStatus:@"Deleting..."];
    Message *msg = [self.messagesArray objectAtIndex:index];
    
    [[APIManager sharedManager] deleteMessage:[Me me] messageId: msg.messageId success:^(NSString * success) {
        [SVProgressHUD dismiss];
        if (success) {
            //            [Common showAlertWithMessage:success];
            [self.messagesArray removeObjectAtIndex:index];
            [self.tableView reloadData];
            
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
#pragma mark -UIScrollViewDelegate
// Somewhere in your implementation file:
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"Will begin dragging");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Did Scroll");
    [self hideKeyboard];
}
#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    UIFont* font = [UIFont systemFontOfSize:14];
    CGFloat width = self.view.frame.size.width - 80;
    Message* message = self.messagesArray[indexPath.row];
    
    CGFloat descriptionHeight = [Common getHeightOfString:message.message width:width andFont:font];
    if (message.senderId == self.user.userId) {
        height = height + descriptionHeight;
    } else {
        height = height - 15 + descriptionHeight;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message* message = self.messagesArray[indexPath.row];
    if (message.senderId == self.user.userId) {
        IncomeMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IncomeMessageTableViewCell"];
        cell.lblUsername.text = [NSString stringWithFormat:@"@%@",self.user.name];
        cell.tvMessage.text = message.message;
        
        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];
        return cell;
    } else {
        OutGoMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OutGoMessageTableViewCell"];
        cell.tvMessage.text = message.message;

        [cell.contentView setNeedsLayout];
        [cell.contentView layoutIfNeeded];

        cell.delegate = self;
        cell->index = indexPath.row;
        return cell;
    }
    
}

@end
