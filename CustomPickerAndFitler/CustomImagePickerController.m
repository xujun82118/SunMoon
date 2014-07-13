//
//  CustomImagePickerController.m
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import "CustomImagePickerController.h"
#import "IphoneScreen.h"
#import "UIImage+Cut.h"
//#import "ChooseStringViewController.h"

@interface CustomImagePickerController ()

{
    UIView *overlyView;
    UIImageView* sunMoonImageViewTop;
    UIImageView* bowLightView;

    UIButton *cameraBtn;
    UIButton *voicePressedBtn;
    UIButton *mergedBtn;

}
@end

@implementation CustomImagePickerController

@synthesize customDelegate = _customDelegate, isSingle=_isSingle, iSunORMoon=iSunORMoon,progressView =_progressView,customRangeBar=_customRangeBar;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        pressedVoice = [VoicePressedHold alloc];

    }
    return self;
}

#pragma mark get/show the UIView we want
- (UIView *)findView:(UIView *)aView withName:(NSString *)name {
	Class cl = [aView class];
	NSString *desc = [cl description];
	
	if ([name isEqualToString:desc])
		return aView;
	
	for (NSUInteger i = 0; i < [aView.subviews count]; i++) {
		UIView *subView = [aView.subviews objectAtIndex:i];
		subView = [self findView:subView withName:name];
		if (subView)
			return subView;
	}
	return nil;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    UIImage *backgroundImage = [UIImage imageNamed:@"bg_header.png"];
//    if (version >= 5.0) {
//        [navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
//    }
//    else{
//        [navigationController.navigationBar insertSubview:[[UIImageView alloc] initWithImage:backgroundImage] atIndex:1];
//    }
//    
    //获取单例用户数据
    self.userInfo= [UserInfo  sharedSingleUserInfo];
    self.userData  = self.userInfo.userDataBase;
    
    
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera){
   
        UIImage *deviceImage = [UIImage imageNamed:@"camera_button_switch_camera.png"];
        UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceBtn setBackgroundImage:deviceImage forState:UIControlStateNormal];
        [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [deviceBtn setFrame:CGRectMake(250, 30, deviceImage.size.width, deviceImage.size.height)];
        
        UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];
        [PLCameraView addSubview:deviceBtn];
        
        [self setShowsCameraControls:NO];
        

        
        //日月最上方的
        UIImage *sunMoonImageTop;
        if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
            sunMoonImageTop = [UIImage imageNamed:@"sun.png"];
            
        }else
        {
            sunMoonImageTop = [UIImage imageNamed:@"moon.png"];
            
        }
        NSInteger sunMoonImageTopWidth = 60;
        NSInteger sunMoonImageTopHeigth =60;
        sunMoonImageViewTop = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - sunMoonImageTopWidth/2, 20, sunMoonImageTopWidth, sunMoonImageTopHeigth)];
        sunMoonImageViewTop.image = sunMoonImageTop;
        UITapGestureRecognizer *recognizerSunMoon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSunMoonInTakePhotoHandler:)];
        recognizerSunMoon.numberOfTouchesRequired = 1;
        recognizerSunMoon.numberOfTapsRequired = 1;
        recognizerSunMoon.delegate = self;
        [sunMoonImageViewTop setUserInteractionEnabled:YES];
        [sunMoonImageViewTop addGestureRecognizer:recognizerSunMoon];
        [self.view addSubview:sunMoonImageViewTop];
        
        
        //日月闪烁
        NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<10; i++) {
            
            NSString *name=[NSString stringWithFormat:@"abFrame_%d",i%10+1];
            UIImage *image=[UIImage imageNamed:name];
            
            [iArr addObject:image];
            
        }
        bowLightView = [[UIImageView alloc] initWithFrame:CGRectMake(sunMoonImageViewTop.frame.origin.x-10,sunMoonImageViewTop.frame.origin.y-10, sunMoonImageViewTop.frame.size.width+20,sunMoonImageViewTop.frame.size.height+20)];
        bowLightView.image=[UIImage imageNamed:@"abFrame_9"];
        bowLightView.userInteractionEnabled=YES;
        bowLightView.contentMode=UIViewContentModeScaleToFill;
        bowLightView.animationImages=iArr;
        [bowLightView setFrame:CGRectMake(sunMoonImageViewTop.frame.origin.x-10,sunMoonImageViewTop.frame.origin.y-10, sunMoonImageViewTop.frame.size.width+20,sunMoonImageViewTop.frame.size.height+20)];
        bowLightView.animationDuration=1;
        bowLightView.animationRepeatCount = 1;
        bowLightView.hidden = NO;
        [PLCameraView addSubview:bowLightView];
        [PLCameraView bringSubviewToFront:sunMoonImageViewTop];

        
        
        overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 70, 320, 44)];
        [overlyView setBackgroundColor:[UIColor clearColor]];
      
        //语录label
        NSInteger sentenceLabelWidth = 280;
        NSInteger sentenceLabelHeigth =80;
        UILabel *labelSentence = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2-sentenceLabelWidth/2, overlyView.frame.origin.y-sentenceLabelHeigth-40, sentenceLabelWidth, sentenceLabelHeigth)];
        labelSentence.tag = TAG_CAMERA_DECLEAR_LABEL;
        //设置标签文本
        //NSString *preString = @"Say:\n";
        
        if(iSunORMoon == IS_SUN_TIME) {
            labelSentence.text = self.userInfo.current_sun_sentence;

        }else if (iSunORMoon == IS_MOON_TIME)
        {
            labelSentence.text = self.userInfo.current_moon_sentence;

        }
        
        //设置标签文本字体和字体大小
        labelSentence.font = [UIFont fontWithName:@"Arial" size:20];
        labelSentence.textColor = [UIColor whiteColor];
        
        //设置文本对其方式
        labelSentence.textAlignment = UITextAlignmentCenter;
        //设置字体大小适应label宽度
        labelSentence.adjustsFontSizeToFitWidth = YES;
        labelSentence.numberOfLines = 4;
        [PLCameraView addSubview:labelSentence];
        
        //语录三点
        UIImageView * sentenceView = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"语录三点.png"]];
        NSInteger sentenceViewWidth = 25;
        NSInteger sentenceViewHeigth =60;
        [sentenceView setFrame:CGRectMake(SCREEN_WIDTH/2-sentenceViewWidth/2, labelSentence.frame.origin.y+sentenceLabelHeigth+10, sentenceViewWidth, sentenceViewHeigth)];
        UITapGestureRecognizer *recognizerSentence = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSentencePicker:)];
        recognizerSentence.numberOfTouchesRequired = 1;
        recognizerSentence.numberOfTapsRequired = 1;
        recognizerSentence.delegate = self;
        [sentenceView setUserInteractionEnabled:YES];
        [sentenceView addGestureRecognizer:recognizerSentence];
        [PLCameraView addSubview:sentenceView];

        //回放语音按钮
        //优化：有语音时显示
        NSInteger voiceReplayWidth = 25;
        NSInteger voiceReplayHeigth =voiceReplayWidth;
        UIImage *voiceReplayImage = [UIImage imageNamed:@"放音.png"];
        UIButton *voiceReplayBtn = [[UIButton alloc] initWithFrame:
                                    CGRectMake(SCREEN_WIDTH/2-voiceReplayWidth/2,labelSentence.frame.origin.y-voiceReplayHeigth-10,voiceReplayWidth, voiceReplayHeigth)];
        [voiceReplayBtn setImage:voiceReplayImage forState:UIControlStateNormal];
        [voiceReplayBtn addTarget:self action:@selector(rePlayMyVoice) forControlEvents:UIControlEventTouchUpInside];
        [PLCameraView addSubview:voiceReplayBtn];
        

        //按住说语录按钮
        NSInteger voicePressedWidth = 60;
        NSInteger voicePressedHeigth =voicePressedWidth;
        UIImage *voicePressedImage = [UIImage imageNamed:@"Voice.png"];
        voicePressedBtn = [[UIButton alloc] initWithFrame:
                               CGRectMake(ScreenWidth/2-voicePressedWidth-10, 5, voicePressedWidth, voicePressedHeigth)];
        [voicePressedBtn setImage:voicePressedImage forState:UIControlStateNormal];
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(myButtonLongPressed:)];
        gesture.minimumPressDuration =0;
        [voicePressedBtn addGestureRecognizer:gesture];
        [overlyView addSubview:voicePressedBtn];
        


        
        //语音音量进程
        NSInteger progressViewWidth = 150;
        NSInteger progressViewHeigth =20;
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(ScreenWidth/2-progressViewWidth/2, -25, progressViewWidth, progressViewHeigth)];
        [_progressView setProgress:pressedVoice.Pitch];
        [pressedVoice setProgressView:_progressView];
        [overlyView addSubview:_progressView];

        // 另一个音量进程
        /*
        _customRangeBar = [[F3BarGauge alloc] initWithFrame:CGRectMake(ScreenWidth/2-progressViewWidth/2, -15, progressViewWidth, progressViewHeigth)];
        _customRangeBar.value = pressedVoice.Pitch;
        [pressedVoice setCustomRangeBar:_customRangeBar];
        [overlyView addSubview:_customRangeBar];
        */
        

        
        //拍照按钮
        //优化：未说语录之前，淡化
        NSInteger camerImageWidth = 60;
        NSInteger camerImageHeigth =camerImageWidth;
        UIImage *camerImage = [UIImage imageNamed:@"takePhoto.png"];
        cameraBtn = [[UIButton alloc] initWithFrame:
                               CGRectMake(ScreenWidth/2+10, 5, camerImageWidth, camerImageHeigth)];
        [cameraBtn setImage:camerImage forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:cameraBtn];
        
        
        //合并拍照和语音的按钮
        NSInteger mergedBtnWidth = 60;
        NSInteger mergedBtnHeigth =mergedBtnWidth;
        UIImage *mergedBtnImage = [UIImage imageNamed:@"takePhoto.png"];
        mergedBtn = [[UIButton alloc] initWithFrame:
                     CGRectMake(ScreenWidth/2-mergedBtnWidth/2, 5, mergedBtnWidth, mergedBtnHeigth)];
        [mergedBtn setImage:mergedBtnImage forState:UIControlStateNormal];
        UILongPressGestureRecognizer *gestureMerge = [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(MergeButtonLongPressed:)];
        gestureMerge.minimumPressDuration =0;
        [mergedBtn addGestureRecognizer:gestureMerge];
        mergedBtn.hidden = YES;
        [overlyView addSubview:mergedBtn];
        
        //打开相册按钮
        NSInteger albumImageWidth = 40;
        NSInteger albumImageHeigth =30;
        UIImage *albumImage = [UIImage imageNamed:@"takePhoto_0003_相册.png"];
        UIButton *albumImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-albumImageWidth, 5, albumImageWidth, albumImageHeigth)];
        [albumImageBtn setImage:albumImage forState:UIControlStateNormal];
        [albumImageBtn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        [overlyView addSubview:albumImageBtn];
        
        //返回按钮
        NSInteger backBtnImageWidth = 40;
        NSInteger backBtnImageHeigth =30;
        UIImage *backImage = [UIImage imageNamed:@"takePhoto_0004_返回.png"];
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, 5, backBtnImageWidth, backBtnImageHeigth)];
        [backBtn setImage: backImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:backBtn];
        
        
        //2秒延迟开关
        NSInteger switchCtrlDelayWidth = 60;
        NSInteger switchCtrlDelayHeigth =30;
        UISwitch *switchCtrlDelay = [[UISwitch alloc] initWithFrame:CGRectMake(10, overlyView.frame.origin.y -20, switchCtrlDelayWidth, switchCtrlDelayHeigth)];
        [switchCtrlDelay addTarget:self action:@selector(delaySwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
        switchCtrlDelay.on = self.userInfo.delayTakePhotoCtl;
        [overlyView addSubview:switchCtrlDelay];

        
        self.cameraOverlayView = overlyView;
    }
}


- (void)TapSunMoonInTakePhotoHandler:(UITapGestureRecognizer*) gesture
{
    NSLog(@"Tap SunMoon in takephoto UI");
    bowLightView.hidden = NO;
    [bowLightView startAnimating];
    
}




- (void)delaySwitchChangeHandler:(UISwitch *)sender
{
    
    if (sender.on == YES) {
        NSLog(@"合并语音与拍照按钮");
        [UIView beginAnimations:@"MergeAnimation" context:(__bridge void *)(cameraBtn)];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(MergeAnimationDidStop:finished:context:)];
        [cameraBtn setFrame:CGRectMake(SCREEN_WIDTH/2-cameraBtn.frame.size.width/2, cameraBtn.frame.origin.y,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
        cameraBtn.opaque = YES;
        cameraBtn.alpha = 1.0;
        cameraBtn.hidden = YES;
        
        [voicePressedBtn setFrame:CGRectMake(SCREEN_WIDTH/2-voicePressedBtn.frame.size.width/2, voicePressedBtn.frame.origin.y,voicePressedBtn.frame.size.width,voicePressedBtn.frame.size.height)];
        voicePressedBtn.opaque = YES;
        voicePressedBtn.alpha = 1.0;
        voicePressedBtn.hidden = YES;
        
        [UIView commitAnimations];
        
        
    }else
    {
        NSLog(@"分开 拍照与语音 按钮");
        [UIView beginAnimations:@"deMergeAnimation" context:(__bridge void *)(cameraBtn)];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(deMergeAnimationDidStop:finished:context:)];
        [cameraBtn setFrame:CGRectMake(ScreenWidth/2+10, 5,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
        cameraBtn.opaque = YES;
        cameraBtn.alpha = 1.0;
        cameraBtn.hidden = NO;
        
        [voicePressedBtn setFrame:CGRectMake(ScreenWidth/2-voicePressedBtn.frame.size.width-10,voicePressedBtn.frame.origin.y,voicePressedBtn.frame.size.width,voicePressedBtn.frame.size.height)];
        voicePressedBtn.opaque = YES;
        voicePressedBtn.alpha = 1.0;
        voicePressedBtn.hidden = NO;
        
        [UIView commitAnimations];
        
        
    }
    
    
}

- (void)deMergeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)cameraBtn
{
    if ([animationID isEqualToString:@"deMergeAnimation"]) {
        NSLog(@"deMerge animation finished");
        
        mergedBtn.hidden = YES;
        
    }
    
}

- (void)MergeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)cameraBtn
{
    
    if ([animationID isEqualToString:@"MergeAnimation"]) {
        NSLog(@"Merge animation finished");
        
        mergedBtn.hidden = NO;

    }
    
    
}

- (void) MergeButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    //执行语音动作
    [pressedVoice myButtonLongPressed:gesture];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"Voice Long press Ended---take photo： Delay 2s!");
 
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(takePicture)
                                       userInfo:[self userInfo]
                                        repeats:NO];
        
    }
    
    
}

- (void) myButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    //执行语音动作
    [pressedVoice myButtonLongPressed:gesture];
    

}

-(void)rePlayMyVoice
{
    [pressedVoice playRecording];

    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
	// Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    //[super dealloc];
}


#pragma mark - 选择今天的宣言语录
- (IBAction)chooseSentencePicker:(UITapGestureRecognizer *)sender
{
   
    if (defaultPickerView == nil) {
        defaultPickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(0,ScreenHeight-216,320,216) backgroundImage:@"PickerBG.png" shadowImage:@"PickerShadow.png" glassImage:@"pickerGlass.png" title:@"选择宣言"];
        defaultPickerView.dataSource = self;
        defaultPickerView.delegate = self;
        defaultPickerView.rowFont = [UIFont fontWithName:@"Arial" size:20];
        [self.view addSubview:defaultPickerView];
    }
    [defaultPickerView showPicker];
    [defaultPickerView reloadData];
    
    if(iSunORMoon == IS_SUN_TIME) {
        defaultPickerView.selectedRow = self.userInfo.sunSentenceSelect;
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        defaultPickerView.selectedRow = self.userInfo.moonSentenceSelect;

    }
    
    
}


#pragma mark - ButtonAction Methods

- (IBAction)swapFrontAndBackCameras:(id)sender {
    if (self.cameraDevice ==UIImagePickerControllerCameraDeviceFront ) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }else {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}


- (void)closeView
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:NO completion:NULL];
}
- (void)takePicture
{

    [super takePicture];
}


- (void)showPhoto
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        [CommonObject showActionSheetOptiontitleMsg:@"我美丽的公主，你要自拍说出宣言，才能获得阳光" ShowInView:self.view CancelMsg:@"就要用相片" DelegateObject:self Option:@"好嘞，我的太阳王子"];
        
        
    }else if([CommonObject checkSunOrMoonTime] ==  IS_MOON_TIME)
    {
        [CommonObject showActionSheetOptiontitleMsg:@"我美丽的公主，你要自拍说出宣言，才能获得月光" ShowInView:self.view CancelMsg:@"就要用相片" DelegateObject:self Option:@"好嘞，我的月光女神"];
    }
    

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //继续自拍
        
    }else if (buttonIndex == 1) {
        
        //用相片
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [self setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
}

#pragma mark - Camera View Delegate Methods
#pragma mark - 返回并保存数据
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

    
    NSString* labelSentence;
    if(iSunORMoon == IS_SUN_TIME) {
        labelSentence = self.userInfo.current_sun_sentence;
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        labelSentence = self.userInfo.current_moon_sentence;

    }
    
    image = [image clipImageWithScaleWithsize:CGSizeMake(320, 480)] ;
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        NSDictionary *imageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   image,CAMERA_IMAGE_KEY,
                                   [CommonObject getCurrentDate], CAMERA_TIME_KEY,
                                   labelSentence, CAMERA_SENTENCE_KEY,
                                   nil];
        
        [_customDelegate cameraPhoto:imageData];

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if(_isSingle){
        //[picker dismissModalViewControllerAnimated:YES];
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }else{
        if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            //[picker dismissModalViewControllerAnimated:YES];
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}



#pragma mark - AFPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(AFPickerView *)pickerView {
    
    NSInteger count = 0;
    if(iSunORMoon == IS_SUN_TIME) {
        count = [self.userInfo.sunDataSourceArray count];
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        count = [self.userInfo.moonDataSourceArray count];
        
    }
    
    return count;
}


- (NSString *)pickerView:(AFPickerView *)pickerView titleForRow:(NSInteger)row {

    
    NSString *now = nil;
    if(iSunORMoon == IS_SUN_TIME) {
        now = self.userInfo.current_sun_sentence;
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        now = self.userInfo.current_moon_sentence;
        
    }
    
    return now;
}


#pragma mark - AFPickerViewDelegate

- (void)pickerView:(AFPickerView *)pickerView didSelectRow:(NSInteger)row {

    UIView *PLCameraView=[self findView:self.view
                               withName:@"PLCameraView"];
    
    UILabel *label = (UILabel*)[PLCameraView viewWithTag:TAG_CAMERA_DECLEAR_LABEL];
    
    
    if(iSunORMoon == IS_SUN_TIME) {
        [self.userInfo updateSunSentenceSelected:row];
        
        label.text = self.userInfo.current_sun_sentence;
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        [self.userInfo updateMoonSentenceSelected:row];
        label.text = self.userInfo.current_moon_sentence;

        
    }
    
}
@end
