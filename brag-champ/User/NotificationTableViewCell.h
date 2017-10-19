//
//  NotificationTableViewCell.h
//  brag-champ
//
//  Created by Star on 4/4/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@class Notification;

@protocol NotificationDelegate

- (void)onViewButton:(Notification *)notification;
- (void)onIgnoreButton:(Notification *)notification;
- (void)gotoProfile:(User*)user;

@end

@interface NotificationTableViewCell : UITableViewCell

@property(nonatomic, strong) Notification *notification;
@property(nonatomic, weak) id<NotificationDelegate> delegate;

@end
