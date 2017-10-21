//
//  PostVideoViewController.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "PostVideoViewController.h"
#import "APIManager.h"
#import "Common.h"
#import "Me.h"
#import "Video.h"
#import "FilterCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <GPUImage.h>
#import <SVProgressHUD.h>

@interface PostVideoViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger selectedFilter;
}

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *filtersCollectionView;
@property (nonatomic, weak) IBOutlet UITextField *challengeTitleTextField;
@property (nonatomic, weak) IBOutlet UITextField *challengersTextField;
@property (nonatomic, weak) IBOutlet UISwitch *publicSwitch;
@property (nonatomic, weak) IBOutlet UITextField *hashtagsTextField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *optionalHeightConstraint;
@property (nonatomic, strong) IBOutlet UIPickerView *challengersPicker;
@property (nonatomic, strong) IBOutlet UIToolbar *challengersToolbar;

@property (nonatomic, strong) NSArray *thumbImages;
@property (nonatomic, strong) NSArray *imageFilters;

@property (nonatomic, strong) GPUImageView *playView;
@property (nonatomic, strong) GPUImageMovie *gpuImageMovie;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageMovie *movieToWrite;

@end

@implementation PostVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    selectedFilter = 0;
    
    if (self.video) {
        self.optionalHeightConstraint.constant = 0;
    } else {
        self.optionalHeightConstraint.constant = 201;
    }
    
    [self.filtersCollectionView registerNib:[UINib nibWithNibName:@"FilterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FilterCollectionViewCell"];
    
    self.challengersTextField.inputView = self.challengersPicker;
    self.challengersTextField.inputAccessoryView = self.challengersToolbar;
    
    [self displayVideo];
    [self prepareFilters];

    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setBackgroundImage:[UIImage imageNamed:@"navlogo"] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.frame = CGRectMake(0, 0, 120, 40);
    [self.navigationItem setTitleView:titleButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)displayVideo {
    self.playView = [[GPUImageView alloc] initWithFrame:self.thumbImageView.bounds];
    self.playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.thumbImageView addSubview:self.playView];
    
    self.gpuImageMovie = [[GPUImageMovie alloc] initWithURL:self.recordedAsset];
    self.gpuImageMovie.shouldRepeat = YES;
    self.gpuImageMovie.playAtActualSpeed = YES;
}

- (void)prepareFilters {
    GPUImageFilter *filter1 = [[GPUImageFilter alloc] init];
    
    GPUImageWhiteBalanceFilter *filter2 = [[GPUImageWhiteBalanceFilter alloc] init];
    filter2.temperature = 1000;
    
    GPUImageGrayscaleFilter *filter3 = [[GPUImageGrayscaleFilter alloc] init];

    self.imageFilters = @[filter1, filter2, filter3];
    

    // Generate Thumbnail
    UIImage *thumbImage = [self generateThumbImage:self.recordedAsset];

    GPUImagePicture *inputFilter = [[GPUImagePicture alloc] initWithImage:thumbImage];
    [inputFilter addTarget:filter1];
    [inputFilter addTarget:filter2];
    [inputFilter addTarget:filter3];

    [filter1 useNextFrameForImageCapture];
    [filter2 useNextFrameForImageCapture];
    [filter3 useNextFrameForImageCapture];
    
    [inputFilter processImage];

    self.thumbImages = @[[filter1 imageFromCurrentFramebuffer],
                         [filter2 imageFromCurrentFramebuffer],
                         [filter3 imageFromCurrentFramebuffer]];
    
    [inputFilter removeAllTargets];

    [filter1 addTarget:self.playView];
    [filter2 addTarget:self.playView];
    [filter3 addTarget:self.playView];

    [self.gpuImageMovie addTarget:filter1];
    [filter1 setInputRotation:kGPUImageRotateRight atIndex:0];
    [self.gpuImageMovie startProcessing];
}

- (UIImage *)generateThumbImage:(NSURL *)url {
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:CMTimeMake(1, 1) actualTime:NULL error:nil];
    UIImage* thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
    return thumbnail;
}



- (IBAction)home:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)settings:(id)sender {
    UIViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (IBAction)submit:(id)sender {
    if (!self.video) {
        // New Video
        NSString *title = self.challengeTitleTextField.text;
        if ([title length] == 0) {
            [Common showAlertWithMessage:@"Please input the challenge title."];
            [self.challengeTitleTextField resignFirstResponder];
            return;
        }
    }
    
    [SVProgressHUD showWithStatus:@"Uploading"];

    GPUImageFilter *filter = self.imageFilters[selectedFilter];
    [filter removeAllTargets];
    [self.gpuImageMovie removeAllTargets];
    
    self.movieToWrite = [[GPUImageMovie alloc] initWithURL:self.recordedAsset];
    self.movieToWrite.playAtActualSpeed = NO;
    
    AVAssetTrack *videoTrack = [[[AVAsset assetWithURL:self.recordedAsset] tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((size.width - MIN(size.width , size.height)) / 2 / size.width, (size.height - MIN(size.width, size.height)) / 2 / size.height, MIN(size.width, size.height) / size.width, MIN(size.width, size.height) / size.height)];
    [self.movieToWrite addTarget:crop];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld-%ld.mp4", (long)[Me me].userId, (long)time(NULL)]];
    
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecH264,
                                     AVVideoWidthKey:@(640),
                                     AVVideoHeightKey:@(640),
                                     AVVideoCompressionPropertiesKey:
                                         @{AVVideoAverageBitRateKey:@(1100000),
                                           AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel,
                                           AVVideoMaxKeyFrameIntervalKey:@(16)}};
    
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:path] size:CGSizeMake(640, 640) fileType:AVFileTypeQuickTimeMovie outputSettings:outputSettings];
    self.movieWriter.shouldPassthroughAudio = YES;

    NSInteger index = selectedFilter;
    
    __weak PostVideoViewController *welf = self;
    [self.movieWriter setCompletionBlock:^{
        [welf.movieWriter endProcessing];
        [welf.movieToWrite endProcessing];
        [welf.movieWriter finishRecording];
        
        GPUImageFilter *filter = welf.imageFilters[index];
        [welf.gpuImageMovie addTarget:filter];
        [filter setInputRotation:kGPUImageRotateRight atIndex:0];

        dispatch_async(dispatch_get_main_queue(), ^{
            [welf uploadVideo:[NSURL fileURLWithPath:path]];
        });
    }];
    [self.movieWriter setFailureBlock:^(NSError *error) {
        [welf.movieWriter endProcessing];
        [welf.movieToWrite endProcessing];
        [welf.movieWriter finishRecording];

        GPUImageFilter *filter = welf.imageFilters[index];
        [welf.movieToWrite removeAllTargets];
        [filter removeAllTargets];
        
        [welf.gpuImageMovie addTarget:filter];
        [filter setInputRotation:kGPUImageRotateRight atIndex:0];

        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [Common showAlertWithMessage:error.localizedDescription];
        });
    }];

    [crop addTarget:filter];
    [filter addTarget:self.movieWriter];

    self.movieToWrite.audioEncodingTarget = self.movieWriter;
    [self.movieToWrite enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];

    [self.movieWriter startRecordingInOrientation:txf];
    [self.movieToWrite startProcessing];
}


- (void)uploadVideo:(NSURL *)videoUrl {
    if (!self.video) {
        NSString *title = self.challengeTitleTextField.text;
        NSInteger challengers = [self.challengersTextField.text integerValue];
        BOOL isPublic = !self.publicSwitch.on;
        NSString *hashTags = self.hashtagsTextField.text;
        UIImage *thumb = self.thumbImages[selectedFilter];
        
        [[APIManager sharedManager] uploadThumbnail:[Me me]
                                              image:thumb
                                            success:^(NSString *url)
         {
             [[APIManager sharedManager] postVideo:[Me me]
                                    challengeTitle:title
                                       challengers:challengers
                                            public:isPublic
                                          hashTags:hashTags
                                          videoURL:videoUrl
                                         thumbnail:url
                                          progress:^(NSInteger progress)
              {
                  [SVProgressHUD showProgress:progress / 100.0 status:@"Uploading"];
              }
                                           success:^(Video *video)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                      [self.navigationController popToRootViewControllerAnimated:YES];
                  });
              }
                                            failed:^(NSString *message, NSError *error)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                      
                      if (message) {
                          [Common showAlertWithMessage:message];
                      } else if (error) {
                          [Common showAlertWithMessage:error.localizedDescription];
                      } else {
                          [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
                      }
                  });
              }];
         }
                                             failed:^(NSString *message, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 
                 if (message) {
                     [Common showAlertWithMessage:message];
                 } else if (error) {
                     [Common showAlertWithMessage:error.localizedDescription];
                 } else {
                     [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
                 }
             });
         }];
    } else {
        // Challenge Video
        UIImage *thumb = self.thumbImages[selectedFilter];
        
        [SVProgressHUD showWithStatus:@"Uploading"];
        
        [[APIManager sharedManager] uploadThumbnail:[Me me]
                                              image:thumb
                                            success:^(NSString *url)
         {
             [[APIManager sharedManager] challengeVideo:[Me me]
                                                  video:self.video
                                                    url:videoUrl
                                              thumbnail:url
                                               progress:^(NSInteger progress)
              {
                  [SVProgressHUD showProgress:progress / 100.0 status:@"Uploading"];
              }
                                           success:^(NSString *message)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                      [self.navigationController popToRootViewControllerAnimated:YES];
                  });
              }
                                            failed:^(NSString *message, NSError *error)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                      
                      if (message) {
                          [Common showAlertWithMessage:message];
                      } else if (error) {
                          [Common showAlertWithMessage:error.localizedDescription];
                      } else {
                          [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
                      }
                  });
              }];
         }
                                             failed:^(NSString *message, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [SVProgressHUD dismiss];
                 
                 if (message) {
                     [Common showAlertWithMessage:message];
                 } else if (error) {
                     [Common showAlertWithMessage:error.localizedDescription];
                 } else {
                     [Common showAlertWithMessage:@"Unexpected error occured. Please try again later."];
                 }
             });
         }];
    }
}

- (IBAction)didSelectChallengers:(id)sender {
    [self.challengersTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageFilters.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FilterCollectionViewCell" forIndexPath:indexPath];

    cell.layer.borderColor = [UIColor colorWithRed:1 green:226.0/255 blue:32.0/255 alpha:1].CGColor;
    cell.layer.borderWidth = (selectedFilter == indexPath.item ? 1 : 0);
    cell.thumbImage = self.thumbImages[indexPath.item];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedFilter = indexPath.item;
    [collectionView reloadData];
    
    GPUImageFilter *filter = self.imageFilters[selectedFilter];
    
    [self.gpuImageMovie removeAllTargets];
    [self.gpuImageMovie addTarget:filter];
    [filter setInputRotation:kGPUImageRotateRight atIndex:0];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 11;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.challengersTextField.text = [NSString stringWithFormat:@"%ld", (long)row];
}

@end
