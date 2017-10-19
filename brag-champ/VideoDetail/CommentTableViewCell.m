//
//  CommentTableViewCell.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Comment.h"
#import "User.h"
#import <UIImageView+WebCache.h>



@interface CommentTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;



@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //add tap gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(tapUsername)];
    singleTap.numberOfTapsRequired = 1;
    [self.commentLabel addGestureRecognizer:singleTap];
    
}
- (IBAction)onDelete:(id)sender {
    if (self.delegate != NULL && index >= 0) {
        [self.delegate deleteComment: index];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.width / 2;
}

- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    [self.userImageView setShowActivityIndicatorView:YES];
    [self.userImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[comment.user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@: ", [comment.user.name uppercaseString]] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName : [UIColor blueColor]}];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor grayColor]}]];
    self.commentLabel.attributedText = text;
}
- (void)tapUsername {
    if (self.delegate != NULL) {
        [self.delegate gotoProfile:_comment.user];
    }
}

@end
