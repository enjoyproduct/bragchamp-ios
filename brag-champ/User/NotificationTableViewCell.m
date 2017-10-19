//
//  NotificationTableViewCell.m
//  brag-champ
//
//  Created by Star on 4/4/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Notification.h"
#import "User.h"
#import <UIImageView+WebCache.h>

@interface NotificationTableViewCell()

@property(nonatomic, weak) IBOutlet UIImageView *userImageView;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *noteLabel;
@property(nonatomic, weak) IBOutlet UIButton *viewButton;
@property(nonatomic, weak) IBOutlet UIButton *ignoreButton;

@end

@implementation NotificationTableViewCell

@synthesize delegate;

typedef enum {
    FRIEND = 1,
    MENTION1 = 2,
    MENTION2 = 3,
    LIKE1 = 4,
    LIKE2 = 5
} NotificationType;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = 30;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapUsername)];
    singleTap.numberOfTapsRequired = 1;
    [self.nameLabel addGestureRecognizer:singleTap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(Notification *)notification {
    _notification = notification;
    [self.userImageView setShowActivityIndicatorView:YES];
    [self.userImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[notification.user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
    
    NSString *note = @"";
    NSString *buttonText = @"View";
    switch (notification.type) {
        case FRIEND:
            note = @"Sent A Request";
            buttonText = @"Approve";
            break;
        case MENTION1:
        case MENTION2:
            note = @"Mentioned You";
            break;
        case LIKE1:
        case LIKE2:
            note = @"Liked Your Post";
            break;
        default:
            break;
    }
    
    self.nameLabel.text = [NSString stringWithFormat:@"@%@", [notification.user.name uppercaseString]];
    self.noteLabel.text = note;
    [self.viewButton setTitle:buttonText forState:UIControlStateNormal];
}
- (void)tapUsername {
    if (self.delegate != NULL) {
        [self.delegate gotoProfile: _notification.user];
    }
}
#pragma mark - IBActions
- (IBAction)onViewButton:(id)sender {
    [self.delegate onViewButton:_notification];
}

- (IBAction)onIgnoreButton:(id)sender {
    [self.delegate onIgnoreButton:_notification];
}

@end
