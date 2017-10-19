//
//  OutGoMessageTableViewCell.m
//  brag-champ
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "OutGoMessageTableViewCell.h"

@implementation OutGoMessageTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)onDelete:(id)sender {
    if (self.delegate != NULL && index >= 0) {
        [self.delegate deleteMessage: index];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
