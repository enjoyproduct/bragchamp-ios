//
//  ChallengeVideoDetailViewController.h
//  brag-champ
//
//  Created by Apple on 1/5/17.
//  Copyright © 2017 Julian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video;
@class ChallengeVideo;

@interface ChallengeVideoDetailViewController : UIViewController

@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) ChallengeVideo *challengeVideo;

@property (nonatomic, strong) NSArray *challenges;

@end
