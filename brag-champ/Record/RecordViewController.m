//
//  RecordViewController.m
//  brag-champ
//
//  Created by Apple on 12/15/16.
//  Copyright © 2016 Julian. All rights reserved.
//

#import "RecordViewController.h"
#import "Video.h"
#import "PostVideoViewController.h"
#import <LLSimpleCamera.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface RecordViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *cameraView;
@property (nonatomic, weak) IBOutlet UIButton *switchButton;
@property (nonatomic, weak) IBOutlet UIButton *flashButton;
@property (nonatomic, weak) IBOutlet UIButton *snapButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSURL *recordedAsset;

@property (nonatomic) LLSimpleCamera *fullCamera;
@property (nonatomic, strong) UILabel *errorLabel;
@property (strong, nonatomic) UIImageView *cameraRecordIcon;
@property (strong, nonatomic) UILabel *cameraRecordTimeLabel;
@property (strong, nonatomic) NSTimer *cameraRecordTimer;
@property (nonatomic) int cameraTimerInteger;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) BOOL isSnapButtonPressed;
@property (nonatomic) BOOL isCameraStarted;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view layoutIfNeeded];

    self.isCameraStarted = YES;
    self.isSnapButtonPressed = NO;
    self.isRecording = NO;

    self.fullCamera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                                     position:LLCameraPositionRear
                                                 videoEnabled:YES];
    [self.fullCamera start];
    
    // attach to the view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.fullCamera attachToViewController:self withFrame:self.cameraView.bounds];
    [self.cameraView addSubview:self.fullCamera.view];

    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.fullCamera.fixOrientationAfterCapture = YES;
    
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.fullCamera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == LLCameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.fullCamera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if (error.code == LLSimpleCameraErrorCodeCameraPermission ||
               error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
                
                if (weakSelf.errorLabel) {
                    [weakSelf.errorLabel removeFromSuperview];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = @"We need permission for the camera.\nPlease go to your settings.";
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor lightGrayColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.width / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.snapButton addTarget:self action:@selector(snapButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [self.snapButton addTarget:self action:@selector(snapButtonCancelled:) forControlEvents:UIControlEventTouchUpOutside];

    self.switchButton.hidden = (![LLSimpleCamera isFrontCameraAvailable] || ![LLSimpleCamera isRearCameraAvailable]);

    self.cameraRecordTimeLabel = [[UILabel alloc] init];
    self.cameraRecordTimeLabel.frame = CGRectMake(0, 0, 50.0f, 20.0f);
    self.cameraRecordTimeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.cameraRecordTimeLabel];
    
    self.cameraRecordIcon =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    self.cameraRecordIcon.image = [UIImage imageNamed: @"camera-record-icon"];
    [self.view addSubview:self.cameraRecordIcon];

    self.navigationItem.title = @" ";
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
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    /*View layout subviews*/
    //self.fullCamera.view.frame = self.view.contentBounds;
    
    CGRect frame = self.cameraRecordIcon.frame;
    frame.origin.x = self.view.frame.size.width / 2 - 20.0f;
    frame.origin.y = 28.0f;
    self.cameraRecordIcon.frame = frame;
    
    frame = self.cameraRecordTimeLabel.frame;
    frame.origin.x = self.view.frame.size.width/2 + 10.0f;
    frame.origin.y = 28.0f;
    self.cameraRecordTimeLabel.frame = frame;
    
    self.cameraRecordTimeLabel.hidden = YES;
    self.cameraRecordIcon.hidden = YES;
}


- (IBAction)switchCamera:(id)sender {
    [self.fullCamera togglePosition];
}

- (IBAction)flash:(id)sender {
    if(self.fullCamera.flash == LLCameraFlashOff) {
        BOOL done = [self.fullCamera updateFlashMode:LLCameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
        }
    }
    else {
        BOOL done = [self.fullCamera updateFlashMode:LLCameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
        }
    }
}

- (IBAction)photoLibrary:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeVideo];
    picker.videoMaximumDuration = 60;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)back:(id)sender {
    [self.fullCamera stop];
    self.fullCamera = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)next:(id)sender {
    [self performSegueWithIdentifier:@"showPostVideo" sender:nil];
}

#pragma mark Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PostVideoViewController *vc = (PostVideoViewController *)segue.destinationViewController;
    vc.video = self.video;
    vc.recordedAsset = self.recordedAsset;
}



#pragma mark - Private

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)judgeForCameraType
{
    if (self.isSnapButtonPressed == NO) {
        
    } else {
        self.isRecording = YES;
        if (!self.fullCamera.isRecording) {
            self.flashButton.hidden = YES;
            self.switchButton.hidden = YES;
            self.cameraRecordTimeLabel.hidden = NO;
            self.cameraRecordIcon.hidden = NO;
            self.cameraRecordTimeLabel.text = @"1:00";
            
            // start recording
            NSURL *outputURL = [[[self applicationDocumentsDirectory]
                                 URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
            
            [self.fullCamera startRecordingWithOutputUrl:outputURL didRecord:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
                if (error || !outputFileUrl) {
                    return;
                }
                
                self.recordedAsset = outputFileUrl;
                self.nextButton.hidden = NO;
            }];
            
            self.cameraRecordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cameraRecordTimerTick:) userInfo:nil repeats:YES];
            
        }
    }
}

- (void)snapButtonPressed:(UIButton *)button
{
    self.isSnapButtonPressed = YES;
    [self performSelector:@selector(judgeForCameraType) withObject:nil afterDelay:0.2f];
}

- (void)snapButtonReleased:(UIButton *)button
{
    self.isSnapButtonPressed = NO;
    if (self.fullCamera.isRecording) {
        self.flashButton.hidden = NO;
        self.switchButton.hidden = NO;
        self.cameraRecordTimeLabel.hidden = YES;
        self.cameraRecordIcon.hidden = YES;
        self.cameraRecordTimeLabel.text = @"1:00";
        
        [self.fullCamera stopRecording];

        [self.cameraRecordTimer invalidate];
        self.cameraRecordTimer = nil;
        self.cameraTimerInteger = 0;
    }
}


- (void)snapButtonCancelled:(id)sender {
    self.isSnapButtonPressed = NO;
}

- (void)cameraRecordTimerTick:(NSTimer *)timer {
    
    self.cameraRecordIcon.hidden = !self.cameraRecordIcon.hidden;
    
    self.cameraTimerInteger ++;
    if(self.cameraTimerInteger % 2 == 0)
    {
        int totalSecond = self.cameraTimerInteger/2;
        NSLog(@"%@", [self convertToTimeFormat:totalSecond]);
        [self.cameraRecordTimeLabel setText:[self convertToTimeFormat:(60-totalSecond)]];
        if (totalSecond == 60)
            [self snapButtonReleased:self.snapButton];
    }
    
}

- (NSString *) convertToTimeFormat: (int)time{
    
    NSInteger second = (NSInteger)time % 60;
    NSInteger minute = (NSInteger)time / 60;
    
    NSString * secondString = [self convertToSecondFormat:(int)second];
    NSString * minuteString = [NSString stringWithFormat:@"%ld", (long)minute];
    
    return [NSString stringWithFormat:@"%@:%@",minuteString, secondString];
}

- (NSString *) convertToSecondFormat: (int)time{
    NSString* timeString;
    
    if(time < 10){
        if(time == 0){
            timeString = @"00";
        }else{
            timeString = [NSString stringWithFormat:@"0%d", time];
        }
    }else{
        timeString = [NSString stringWithFormat:@"%d", time];
    }
    
    return timeString;
}


#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.recordedAsset = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.nextButton.hidden = NO;
    }];
}


@end
