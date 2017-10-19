//
//  ChallengerCollectionViewCell.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "ChallengerCollectionViewCell.h"
#import "User.h"
#import <UIImageView+WebCache.h>

@interface ChallengerCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;

@end

@implementation ChallengerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.thumbImageView.layer.cornerRadius = self.thumbImageView.bounds.size.width / 2;
    self.thumbImageView.layer.masksToBounds = YES;
}

- (void)setUser:(User *)user {
    _user = user;
    
    [self.thumbImageView setShowActivityIndicatorView:YES];
    [self.thumbImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:[user.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]]];
}

@end
