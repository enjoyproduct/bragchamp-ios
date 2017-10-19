//
//  VideoCollectionViewCell.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;
@protocol VideoCollectionViewCellDelegate <NSObject>

- (void)deleteVideo:(int)index;

@end

@interface VideoCollectionViewCell : UICollectionViewCell {
    @public int index;
}


@property (nonatomic, strong) Video *video;
@property (nonatomic, weak) id <VideoCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@end
