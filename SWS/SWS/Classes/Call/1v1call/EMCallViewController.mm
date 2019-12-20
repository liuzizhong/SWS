//
//  EMCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"
#import "UserCacheManager.h"
#import "DemoCallManager.h"
#import "EMVideoInfoViewController.h"
#import "UIImageView+EMWebCache.h"

//3.3.9 new 自定义视频数据
#import "VideoCustomCamera.h"

@interface EMCallViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *topRegionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *centerRemoteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerRegionLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *remoteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *networkLabel;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *showVideoInfoButton;

@property (strong, nonatomic) AVAudioPlayer *ringPlayer;
@property (strong, nonatomic) NSTimer *timeTimer;
@property (nonatomic) int timeLength;
@property (strong, nonatomic) UIVisualEffectView *visualEffectView;

@property (strong, nonatomic) EMVideoInfoViewController *videoInfoController;

//3.3.9 new 自定义视频数据
@property (weak, nonatomic) IBOutlet UIView *videoFormatView;
@property (weak, nonatomic) IBOutlet UIButton *videoMoreButton;

@property (nonatomic) VideoInputModeType videoModel;
@property (strong, nonatomic) VideoCustomCamera *videoCamera;

@property (strong, nonatomic) UITapGestureRecognizer *localViewTap;
@property (strong, nonatomic) UITapGestureRecognizer *remoteViewTap;

@end


@implementation EMCallViewController

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
{
    NSString *xibName = @"EMCallViewController";
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
        _callSession = aCallSession;
        _isDismissing = NO;
        
        if (aCallSession.type == EMCallTypeVideo) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            BOOL ret = [audioSession setActive:NO error:nil];
            if (!ret) {
                NSLog(@"1234567");
            }
        }
    }
    
    return self;
}

//3.3.9 new 自定义视频数据
- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
                       isCustomData:(BOOL)aIsCustom
{
    self = [self initWithCallSession:aCallSession];
    if (self) {
        _videoModel = VIDEO_INPUT_MODE_NONE;
        if (aIsCustom) {
            _videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
        }
    }
    return self;
}

- (UITapGestureRecognizer *)localViewTap {
    if (_localViewTap) { return _localViewTap; }
    _localViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(localViewDidTap:)];
    return _localViewTap;
}

- (UITapGestureRecognizer *)remoteViewTap {
    if (_remoteViewTap) { return _remoteViewTap; }
    _remoteViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remoteViewDidTap:)];
    return _remoteViewTap;
}

- (void)viewDidLoad {
    if (self.isDismissing) {
        return;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self _layoutSubviews];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isDismissing) {
        return;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isDismissing) {
        return;
    }
    
    [super viewDidAppear:animated];
}

#pragma mark - private

- (void)_layoutSubviews
{
    self.timeLabel.hidden = YES;

    UserCacheInfo *userInfo = [UserCacheManager getUserInfo:self.callSession.remoteName];
    
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"icon_personalavatar"]];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.visualEffectView.backgroundColor = [COLOR(68, 68, 68) colorWithAlphaComponent:0.9];//[UIColor colorWithWhite:0 alpha:0.8];
    self.visualEffectView.alpha = 0.80;
    self.visualEffectView.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:self.visualEffectView aboveSubview:self.bgImageView];
    
    BOOL isCaller = self.callSession.isCaller;
    switch (self.callSession.type) {
        case EMCallTypeVoice:
        {//语言通话
            
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"icon_personalavatar"]];
            self.iconImageView.layer.cornerRadius = 80;
            self.remoteNameLabel.hidden = YES;
            self.topRegionLabel.hidden = YES;
            
            self.centerRemoteNameLabel.text = userInfo.nickName;
            self.centerRegionLabel.text = self.regionStr;
            
            if (isCaller) {
                self.rejectButton.hidden = YES;
                self.answerButton.hidden = YES;
            } else {
                self.hangupButton.hidden = YES;
            }
        }
            break;
        case EMCallTypeVideo:
        {// 视频通话
            self.showVideoInfoButton.hidden = YES;
//            self.speakerOutButton.hidden = YES;
//            self.switchCameraButton.hidden = YES;
            
            self.bgImageView.hidden = NO;
            self.iconImageView.hidden = YES;
            self.centerRemoteNameLabel.hidden = YES;
            self.centerRegionLabel.hidden = YES;
            self.remoteNameLabel.text = userInfo.nickName;
            self.topRegionLabel.text = self.regionStr;
            
            if (isCaller) {
                self.rejectButton.hidden = YES;
                self.answerButton.hidden = YES;
                self.bgImageView.hidden = YES;
                self.visualEffectView.hidden = YES;
            } else {
                self.hangupButton.hidden = YES;
            }
            
            [self _setupLocalVideoView];
            
            self.videoMoreButton.hidden = YES;
            if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
                self.videoMoreButton.hidden = NO;
                [self openVideoCamera];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)_setupRemoteVideoView
{
    if (self.callSession.type == EMCallTypeVideo && self.callSession.remoteVideoView == nil) {
        NSLog(@"\n########################_setupRemoteView");
        self.callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.callSession.remoteVideoView.hidden = YES;
        self.callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        [self.view addSubview:self.callSession.remoteVideoView];
        self.remoteViewTap.enabled = NO;
        [self.callSession.remoteVideoView addGestureRecognizer:self.remoteViewTap];
        [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        
        __weak EMCallViewController *weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.callSession.remoteVideoView.hidden = NO;
        });
    }
}

- (void)_setupLocalVideoView
{
    //2.自己窗口
//    CGFloat width = 80;
    CGSize size = [UIScreen mainScreen].bounds.size;
//    CGFloat height = size.height / size.width * width;
    self.callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.view addSubview:self.callSession.localVideoView];
    [self.view sendSubviewToBack:self.callSession.localVideoView];
    self.callSession.localVideoView.backgroundColor = [UIColor clearColor];
    self.callSession.localVideoView.scaleMode = EMCallViewScaleModeAspectFill;
    
    if (self.videoModel != VIDEO_INPUT_MODE_NONE) {
        self.callSession.localVideoView.previewDirectly = NO;
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - private ring

- (void)_beginRing
{
    [self.ringPlayer stop];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    self.ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.ringPlayer setVolume:1];
    self.ringPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    if([self.ringPlayer prepareToPlay])
    {
        [self.ringPlayer play]; //播放
    }
}

- (void)_stopRing
{
    [self.ringPlayer stop];
}

#pragma mark - private timer

- (void)timeTimerAction:(id)sender
{
    self.timeLength += 1;
    self.timeLabel.text = [self getCallDuration];
}

- (NSString *)getCallDuration
{
    if (self.timeLength) {
        int hour = self.timeLength / 3600;
        int m = (self.timeLength - hour * 3600) / 60;
        int s = self.timeLength - hour * 3600 - m * 60;
        
        if (hour > 0) {
            return [NSString stringWithFormat:@"%.2i:%.2i:%.2i", hour, m, s];
        }
        else if(m > 0){
            return [NSString stringWithFormat:@"%.2i:%.2i", m, s];
        }
        else{
            return [NSString stringWithFormat:@"00:%.2i", s];
        }
    } else {
        return @"已取消       ";
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)_startTimeTimer
{
    self.timeLength = 0;
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)_stopTimeTimer
{
    if (self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

#pragma mark - action

/**
 扬声器按钮点击

 @param sender 按钮
 */
- (IBAction)speakerOutAction:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.speakerOutButton.selected = !self.speakerOutButton.selected;
}

/**
 静音按钮点击

 @param sender 按钮
 */
- (IBAction)silenceAction:(id)sender
{
    self.silenceButton.selected = !self.silenceButton.selected;
    if (self.silenceButton.selected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (IBAction)switchCameraAction:(id)sender
{
    //3.3.9 new 自定义视频数据
    self.switchCameraButton.selected = !self.switchCameraButton.selected;
    if (self.videoModel == VIDEO_INPUT_MODE_NONE) {
        [self.callSession switchCameraPosition:!self.switchCameraButton.selected];
    } else {
        [self.videoCamera swapCameraWithPosition:(self.switchCameraButton.selected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront)];
    }
}

- (IBAction)showVideoInfoAction:(id)sender
{
    if (self.videoInfoController == nil) {
        self.videoInfoController = [[EMVideoInfoViewController alloc] initWithNibName:@"EMVideoInfoViewController" bundle:nil];
        self.videoInfoController.callSession = self.callSession;
    }
    
    self.videoInfoController.currentTime = self.timeLabel.text;
    [self.videoInfoController startTimer:self.timeLength];
    self.videoInfoController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:self.videoInfoController animated:YES completion:nil];
}

- (IBAction)answerAction:(id)sender
{
    [self _stopRing];
    [[DemoCallManager sharedManager] answerCall:self.callSession.callId];
}

- (IBAction)rejectAction:(id)sender
{
    [self _stopTimeTimer];
    [self _stopRing];
    
    [[DemoCallManager sharedManager] hangupCallWithReason:EMCallEndReasonDecline];
}

- (IBAction)hangupAction:(id)sender
{
    [self _stopTimeTimer];
    [self _stopRing];
    
    [[DemoCallManager sharedManager] hangupCallWithReason:EMCallEndReasonHangup];
}

#pragma mark - public

- (void)stateToConnecting
{
//    if (self.callSession.isCaller) {
    self.statusLabel.text = NSLocalizedString(@"连接中...", @"连接中...");
//    } else {
//        self.statusLabel.text = NSLocalizedString(@"call.connecting", "Incomimg call");
//    }
}

- (void)stateToConnected
{
    if (self.callSession.isCaller) {
        self.statusLabel.text = NSLocalizedString(@"正在等待对方接受邀请...", @"正在等待对方接受邀请...");
    } else {
        if (self.callSession.type == EMCallTypeVideo) {
            self.statusLabel.text = NSLocalizedString(@"邀请您视频通话", @"邀请您视频通话");
        } else {
            self.statusLabel.text = NSLocalizedString(@"邀请您语音通话", @"邀请您语音通话");
        }
//    self.statusLabel.text = NSLocalizedString(@"call.finished", "Establish call finished");
    }
}

/**
 通话已接通，
 */
- (void)stateToAnswered
{
    [self _startTimeTimer];
    
//    if (self.callSession.type == EMCallTypeVideo) {
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//    }
    
    NSString *connectStr = @"None";
    if (_callSession.connectType == EMCallConnectTypeRelay) {
        connectStr = @"Relay";
    } else if (_callSession.connectType == EMCallConnectTypeDirect) {
        connectStr = @"Direct";
    }
    
    self.statusLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"call.speak", @"Can speak..."), connectStr];
    self.timeLabel.hidden = NO;
    self.hangupButton.hidden = NO;
    self.statusLabel.hidden = YES;
    self.rejectButton.hidden = YES;
    self.answerButton.hidden = YES;
    self.silenceButton.hidden = NO;
    [self _setupRemoteVideoView];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.callSession.localVideoView.frame = CGRectMake(size.width - 95, [[UIApplication sharedApplication] statusBarFrame].size.height + 44, 80, 107);
    [self.callSession.localVideoView addGestureRecognizer:self.localViewTap];
    [self.view bringSubviewToFront:self.callSession.localVideoView];
    
    switch (self.callSession.type) {
        case EMCallTypeVoice:
        {//语言通话
            self.speakerOutButton.hidden = NO;
        }
            break;
        case EMCallTypeVideo:
        {// 视频通话
            self.switchCameraButton.hidden = NO;
            self.bgImageView.hidden = YES;
            self.visualEffectView.hidden = YES;
        }
            break;
        default:
            break;
    }
    
    if (self.speakerOutButton.selected) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        [audioSession setActive:YES error:nil];
    }
    
}

- (void)localViewDidTap:(UITapGestureRecognizer *)gesture
{
    NSLog(@"localViewDidTap");
    self.localViewTap.enabled = NO;
    self.remoteViewTap.enabled = YES;
    
    self.callSession.localVideoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);//;
    [self.view sendSubviewToBack:self.callSession.localVideoView];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.callSession.remoteVideoView.frame = CGRectMake(size.width - 95, [[UIApplication sharedApplication] statusBarFrame].size.height + 44, 80, 107);
    
    [self.view bringSubviewToFront:self.callSession.remoteVideoView];
}

- (void)remoteViewDidTap:(UITapGestureRecognizer *)gesture
{
    NSLog(@"remoteViewDidTap");
    self.localViewTap.enabled = YES;
    self.remoteViewTap.enabled = NO;
    
    self.callSession.remoteVideoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);//;
    [self.view bringSubviewToFront:self.callSession.localVideoView];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.callSession.localVideoView.frame = CGRectMake(size.width - 95, [[UIApplication sharedApplication] statusBarFrame].size.height + 44, 80, 107);
    
    [self.view sendSubviewToBack:self.callSession.remoteVideoView];
}

- (void)setNetwork:(EMCallNetworkStatus)aStatus
{
    if (aStatus == EMCallNetworkStatusUnstable) {
        self.networkLabel.text = @"网络不稳定";
    } else if (aStatus == EMCallNetworkStatusNoData) {
        self.networkLabel.text = @"无数据";
    } else {
        self.networkLabel.text = @"";
    }
}

- (void)setStreamType:(EMCallStreamingStatus)aType
{
    NSString *str = @"Unkonw";
    switch (aType) {
        case EMCallStreamStatusVoicePause:
            str = @"Audio Mute";
            break;
        case EMCallStreamStatusVoiceResume:
            str = @"Audio Unmute";
            break;
        case EMCallStreamStatusVideoPause:
            str = @"Video Pause";
            break;
        case EMCallStreamStatusVideoResume:
            str = @"Video Resume";
            break;
            
        default:
            break;
    }
    
//    [self showHint:str];
}

- (void)clearData
{
    //3.3.9 new 自定义视频数据
    [self closeVideoCamera];
    
    [self.videoInfoController dismissViewControllerAnimated:YES completion:nil];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    self.callSession.remoteVideoView.hidden = YES;
    self.callSession.remoteVideoView = nil;
    _callSession = nil;
    
    [self _stopTimeTimer];
    [self _stopRing];
}

#pragma mark - 3.3.9 new 自定义视频数据

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection*)connection
{
    if(!self.callSession || self.videoModel == VIDEO_INPUT_MODE_NONE){
        return;
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (imageBuffer == NULL) {
        return ;
    }
    
    CVOptionFlags lockFlags = kCVPixelBufferLock_ReadOnly;
    CVReturn ret = CVPixelBufferLockBaseAddress(imageBuffer, lockFlags);
    if (ret != kCVReturnSuccess) {
        return ;
    }
    
    static size_t const kYPlaneIndex = 0;
    static size_t const kUVPlaneIndex = 1;
    uint8_t* yPlaneAddress = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, kYPlaneIndex);
    size_t yPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kYPlaneIndex);
    size_t uvPlaneHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, kUVPlaneIndex);
    size_t uvPlaneBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, kUVPlaneIndex);
    size_t frameSize = yPlaneBytesPerRow * yPlaneHeight + uvPlaneBytesPerRow * uvPlaneHeight;
    
    // set uv for gray color
    uint8_t * uvPlaneAddress = yPlaneAddress + yPlaneBytesPerRow * yPlaneHeight;
    memset(uvPlaneAddress, 0x7F, uvPlaneBytesPerRow * uvPlaneHeight);
    if(self.videoModel == VIDEO_INPUT_MODE_DATA){
        [[EMClient sharedClient].callManager inputVideoData:[NSData dataWithBytes:yPlaneAddress length:frameSize] callId:self.callSession.callId widthInPixels:yPlaneWidth heightInPixels:yPlaneHeight format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    }
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, lockFlags);
    
    if(self.videoModel == VIDEO_INPUT_MODE_SAMPLE_BUFFER) {
        [[EMClient sharedClient].callManager inputVideoSampleBuffer:sampleBuffer callId:self.callSession.callId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    } else if(self.videoModel == VIDEO_INPUT_MODE_PIXEL_BUFFER) {
        [[EMClient sharedClient].callManager inputVideoPixelBuffer:imageBuffer callId:self.callSession.callId format:EMCallVideoFormatNV12 rotation:0 completion:nil];
    }
}

- (IBAction)moreAction:(id)sender
{
    self.videoFormatView.hidden = NO;
}

- (IBAction)videoModelValueChanged:(UISegmentedControl *)sender
{
    
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.videoModel = VIDEO_INPUT_MODE_SAMPLE_BUFFER;
            break;
        case 1:
            self.videoModel = VIDEO_INPUT_MODE_PIXEL_BUFFER;
            break;
        case 2:
            self.videoModel = VIDEO_INPUT_MODE_DATA;
            break;
            
        default:
            break;
    }
}

- (IBAction)closeVideoFormatViewAction:(id)sender
{
    self.videoFormatView.hidden = YES;
}

- (void)openVideoCamera
{
    if(self.videoCamera){
        return ;
    }
    
    self.videoCamera = [[VideoCustomCamera alloc] initWithQueue:dispatch_get_main_queue()];
    [self.videoCamera syncSetDataDelegate:self onDone:nil];
    BOOL ok = [self.videoCamera syncOpenWithWidth:640 height:480 onDone:nil];
    if(!ok){
        [self.videoCamera syncClose:nil];
        self.videoCamera = nil;
    }
    
}

- (void)closeVideoCamera
{
    if(self.videoCamera){
        [self.videoCamera syncClose:^(id obj, NSError *error) {}];
        self.videoCamera = nil;
    }
}


@end
