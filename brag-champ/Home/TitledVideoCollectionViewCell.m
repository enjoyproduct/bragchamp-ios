//
//  TitledVideoCollectionViewCell.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "TitledVideoCollectionViewCell.h"
#import "Video.h"
#import <UIImageView+WebCache.h>

@interface TitledVideoCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *maskView;

@end

@implementation TitledVideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.maskView.hidden = YES;
}

- (void)setVideo:(Video *)video {
    _video = video;

    if (video.isChallengable) {
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.4];
    } else {
        self.maskView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.4];
    }

    self.titleLabel.text = video.name;

    [self.thumbImageView setShowActivityIndicatorView:YES];
    [self.thumbImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:[video.thumbURL stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.maskView.hidden = NO;
        }
    }];
}

@end
