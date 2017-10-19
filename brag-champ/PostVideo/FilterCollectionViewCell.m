//
//  FilterCollectionViewCell.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@interface FilterCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

@end

@implementation FilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = thumbImage;
    
    self.previewImageView.image = thumbImage;
}

@end
