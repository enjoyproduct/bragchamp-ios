//
//  CommentTableViewCell.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@class Comment;

@protocol CommentTableViewCellDelegate <NSObject>
- (void)deleteComment:(int)index;
@optional
- (void)gotoProfile:(User*)user;

@end

@interface CommentTableViewCell : UITableViewCell {
    @public int index;
}


@property (nonatomic, strong) Comment *comment;

@property (nonatomic, weak) id <CommentTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

@end
