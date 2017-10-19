//
//  FollowTableViewCell.m
//  brag-champ
//
//  Created by Admin on 8/22/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import "FollowTableViewCell.h"

@implementation FollowTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.ivAvatar.layer.cornerRadius = self.ivAvatar.layer.bounds.size.width / 2;
    self.ivAvatar.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
