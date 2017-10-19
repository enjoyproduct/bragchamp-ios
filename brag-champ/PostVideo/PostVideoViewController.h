//
//  PostVideoViewController.h
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;

@interface PostVideoViewController : UIViewController

@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) NSURL *recordedAsset;

@end
