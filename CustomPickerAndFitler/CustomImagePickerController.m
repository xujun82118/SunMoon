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
#import "CustomAlertView.h"

@interface CustomImagePickerController ()

{
    UIView *overlyView;
    UIImageView* sunMoonImageViewTop;
    UIImageView* bowLightView;
    
    UIImageView* voiceValueView;
    UIImageView* giveMaxView;
    //UILabel *voiceValueLabel ;
    //UILabel *giveValueLabel;


    UIButton *cameraBtn;
    UIButton *voicePressedBtn;
    UIButton *mergedBtn;
    
    UIButton *delayBtn;
    
    UIButton *voiceReplayBtn;
    
    float maxVoiceValue;
    NSInteger srcVoiceValueHeight;
    
    BOOL isOverMaxVoiceValue;
    
    BOOL voiceAnimationLock;
    BOOL voiceBackAnimationLock;
    
    AminationCustom* addVauleAnimation;
    BOOL isHaveAddValue;  //第二次触发语音，不再奖励光

   CustomAlertView* customAlertAutoDis;

}
@end

@implementation CustomImagePickerController

@synthesize customDelegate = _customDelegate, isSingle=_isSingle, iSunORMoon=iSunORMoon,progressView =_progressView,customRangeBar=_customRangeBar,voiceName=_voiceName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization


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
    //self.userInfo= [UserInfo  sharedSingleUserInfo];
    self.userData  = self.userInfo.userDataBase;
    
    //语音名子 “time_日月”
    _voiceName = [NSString stringWithFormat:@"%@_%d", [CommonObject getCurrentDate], [CommonObject checkSunOrMoonTime]];
    
    
    pressedVoice = [VoicePressedHold alloc];
    pressedVoice.getPitchDelegate = self;
    
    addVauleAnimation = [[AminationCustom alloc] initWithKey:@"addValueinEdite"];
    addVauleAnimation.aminationCustomDelegate =  self;
    isHaveAddValue = NO;
    isOverMaxVoiceValue = NO;
    
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera){
   

        
        [self setShowsCameraControls:NO];
        

        
        //日月最上方的
        UIImage *sunMoonImageTop;
        if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
            sunMoonImageTop = [UIImage imageNamed:@"sun.png"];
            
        }else
        {
            sunMoonImageTop = [UIImage imageNamed:@"moon.png"];
            
        }
        NSInteger sunMoonImageTopWidth = 200;
        NSInteger sunMoonImageTopHeigth =200;
        sunMoonImageViewTop = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - sunMoonImageTopWidth/2, -140, sunMoonImageTopWidth, sunMoonImageTopHeigth)];
        sunMoonImageViewTop.image = sunMoonImageTop;
        UITapGestureRecognizer *recognizerSunMoon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSunMoonInTakePhotoHandler:)];
        recognizerSunMoon.numberOfTouchesRequired = 1;
        recognizerSunMoon.numberOfTapsRequired = 1;
        [sunMoonImageViewTop setUserInteractionEnabled:YES];
        [sunMoonImageViewTop addGestureRecognizer:recognizerSunMoon];
        [self.view addSubview:sunMoonImageViewTop];
        
        
        UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];

        
        //日月闪烁
        NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<3; i++) {
            
            NSString *name=[NSString stringWithFormat:@"headerFrameBow_%d",i];
            UIImage *image=[UIImage imageNamed:name];
            
            [iArr addObject:image];
            
        }
        
        NSInteger IntervalWidth = LIGHT_ANIMATION_INTERVAL;// 光环向头像外扩的宽度
        NSInteger lightBowSkySunMoonViewWidth = sunMoonImageViewTop.frame.size.width+IntervalWidth*2;
        NSInteger lightBowSkySunMoonViewHeigth = sunMoonImageViewTop.frame.size.height+IntervalWidth*2;
        
        bowLightView = [[UIImageView alloc] initWithFrame:CGRectMake(sunMoonImageViewTop.center.x-lightBowSkySunMoonViewWidth/2, sunMoonImageViewTop.center.y-lightBowSkySunMoonViewWidth/2, lightBowSkySunMoonViewWidth, lightBowSkySunMoonViewHeigth)];
        bowLightView.image=[UIImage imageNamed:@"空白图"];
        bowLightView.userInteractionEnabled=YES;
        bowLightView.contentMode=UIViewContentModeScaleToFill;
        bowLightView.animationImages=iArr;
        bowLightView.animationDuration=0.5;
        bowLightView.animationRepeatCount = 1;
        bowLightView.hidden = NO;
        [PLCameraView addSubview:bowLightView];
        [PLCameraView bringSubviewToFront:sunMoonImageViewTop];

        
        
        //相机方向
        NSInteger deviceImageWidth = 30;
        NSInteger deviceImageHeigth =25;
        UIImage *deviceImage = [UIImage imageNamed:@"相机方向.png"];
        UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceBtn setImage:deviceImage forState:UIControlStateNormal];
        [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [deviceBtn setFrame:CGRectMake(250, 30, deviceImageWidth, deviceImageHeigth)];
        [PLCameraView addSubview:deviceBtn];
        
        //音量动画图,上升的光
        maxVoiceValue = 0;
        voiceAnimationLock = NO;
        voiceBackAnimationLock = NO;
        NSInteger voiceValueViewWidth = SCREEN_WIDTH+200;
        NSInteger voiceValueViewHeigth =voiceValueViewWidth;
        srcVoiceValueHeight = 10;
        voiceValueView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-voiceValueViewWidth/2, SCREEN_HEIGHT-srcVoiceValueHeight, voiceValueViewWidth,voiceValueViewHeigth)];
        
        if(iSunORMoon == IS_SUN_TIME) {
            voiceValueView.image = [UIImage imageNamed:@"voiceValueSun.png"];
            
        }else if (iSunORMoon == IS_MOON_TIME)
        {
            voiceValueView.image = [UIImage imageNamed:@"voiceValueMoon.png"];
            
        }
        voiceValueView.alpha = 0.3;
        [PLCameraView addSubview:voiceValueView];

        
        //音量显示
//        NSInteger voiceLabelWidth = 30;
//        NSInteger voiceLabelHeigth =30;
//        voiceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2-voiceLabelWidth/2, voiceValueView.frame.origin.y-30, voiceLabelWidth, voiceLabelHeigth)];
//        voiceValueLabel.tag = TAB_VOICE_VALUE;
//        voiceValueLabel.text = @"0";
//        UIColor *color;
//        if (iSunORMoon==IS_SUN_TIME ) {
//            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sun.png"]];
//        }else
//        {
//            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"moon.png"]];
//        }        [voiceValueLabel setBackgroundColor:color];
//        voiceValueLabel.hidden = YES;
//        voiceValueLabel.font = [UIFont fontWithName:@"Arial" size:20];
//        voiceValueLabel.textColor = [UIColor whiteColor];
//        voiceValueLabel.textAlignment = NSTextAlignmentCenter;
//        voiceValueLabel.adjustsFontSizeToFitWidth = YES;
//        [PLCameraView addSubview:voiceValueLabel];
      
        //奖励光的最大音量
//        NSInteger giveMaxViewWidth = SCREEN_WIDTH+200;
//        NSInteger giveMaxViewHeigth =giveMaxViewWidth;
//        NSInteger giveY=SCREEN_HEIGHT/2;
//        giveMaxView =[[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2-giveMaxViewWidth/2, giveY, giveMaxViewWidth,giveMaxViewHeigth)];
//        
//        if(iSunORMoon == IS_SUN_TIME) {
//            giveMaxView.image = [UIImage imageNamed:@"voiceValueSun.png"];
//            
//        }else if (iSunORMoon == IS_MOON_TIME)
//        {
//            giveMaxView.image = [UIImage imageNamed:@"voiceValueMoon.png"];
//            
//        }
//        giveMaxView.hidden = YES;
//        [PLCameraView addSubview:giveMaxView];

        
        

        
        NSInteger overlyViewWidth = SCREEN_WIDTH;
        NSInteger overlyViewHeigth =70;
        overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 70, overlyViewWidth, overlyViewHeigth)];
        [overlyView setBackgroundColor:[UIColor clearColor]];
        
        //控件背景图
        NSInteger overlyViewBKWidth = SCREEN_WIDTH-20;
        NSInteger overlyViewBKHeigth =overlyViewHeigth-10;
        UIImageView* overlyViewBk = [[UIImageView alloc] initWithFrame:CGRectMake(overlyViewWidth/2-overlyViewBKWidth/2, overlyViewWidth/2-overlyViewBKWidth/2, overlyViewBKWidth, overlyViewBKHeigth)];
        overlyViewBk.image = [UIImage imageNamed:@"拍照控件底图001.png"];
        [overlyView addSubview:overlyViewBk];
      
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
        labelSentence.textAlignment = NSTextAlignmentCenter;
        //设置字体大小适应label宽度
        labelSentence.adjustsFontSizeToFitWidth = YES;
        labelSentence.numberOfLines = 4;
        [PLCameraView addSubview:labelSentence];
        
        //语录三点
        UIImageView * sentenceView = [[UIImageView alloc] initWithImage:[UIImage  imageNamed:@"语录三点.png"]];
        NSInteger sentenceViewWidth = 40;
        NSInteger sentenceViewHeigth =10;
        [sentenceView setFrame:CGRectMake(SCREEN_WIDTH/2-sentenceViewWidth/2, labelSentence.frame.origin.y-10, sentenceViewWidth, sentenceViewHeigth)];
        UITapGestureRecognizer *recognizerSentence = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSentencePicker:)];
        recognizerSentence.numberOfTouchesRequired = 1;
        recognizerSentence.numberOfTapsRequired = 1;
        [sentenceView setUserInteractionEnabled:YES];
        [sentenceView addGestureRecognizer:recognizerSentence];
        [PLCameraView addSubview:sentenceView];

        //2秒延迟开关
        NSInteger delayBtnWidth = overlyViewBKHeigth-15;
        NSInteger delayBtnHeigth =delayBtnWidth;
        UIImage *delayBtnImage;
        if (self.userInfo.delayTakePhotoCtl) {
            delayBtnImage = [UIImage imageNamed:@"2秒开关底图.png"];
        }else
        {
            delayBtnImage = [UIImage imageNamed:@"2秒开关底图-关.png"];

        }
        
        delayBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [delayBtn setImage:delayBtnImage forState:UIControlStateNormal];
        [delayBtn setFrame:CGRectMake(20, overlyView.frame.origin.y-delayBtnHeigth-5, delayBtnWidth, delayBtnHeigth)];
        [delayBtn addTarget:self action:@selector(delayBtnChangeHandler:) forControlEvents:UIControlEventTouchUpInside];
        [PLCameraView addSubview:delayBtn];
        
        //2秒字
        UILabel *delayTime = [[UILabel alloc] init];
        delayTime.frame = delayBtn.frame;
        delayTime.text = @"2秒";
        
        //设置标签文本字体和字体大小
        delayTime.font = [UIFont fontWithName:@"Arial" size:20];
        delayTime.textColor = [UIColor whiteColor];
        //设置文本对其方式
        delayTime.textAlignment = NSTextAlignmentCenter;
        //设置字体大小适应label宽度
        delayTime.adjustsFontSizeToFitWidth = YES;
        delayTime.numberOfLines = 1;
        [PLCameraView addSubview:delayTime];
                              
        
        //回放语音按钮
        //优化：有语音时显示
        NSInteger voiceReplayWidth = 25;
        NSInteger voiceReplayHeigth =voiceReplayWidth;
        UIImage *voiceReplayImage;
        if (![pressedVoice checkVoiceFile])
        {
            voiceReplayImage = [UIImage imageNamed:@"放音-空.png"];

        }else
        {
            voiceReplayImage = [UIImage imageNamed:@"放音.png"];
 
        }
        voiceReplayBtn = [[UIButton alloc] initWithFrame:
                                    CGRectMake(delayBtn.frame.origin.x+delayBtnWidth+10,delayBtn.center.y-voiceReplayHeigth/2,voiceReplayWidth, voiceReplayHeigth)];
        [voiceReplayBtn setImage:voiceReplayImage forState:UIControlStateNormal];
        [voiceReplayBtn setImage:[UIImage imageNamed:@"放音-实-关.png"] forState:UIControlStateSelected];
        [voiceReplayBtn addTarget:self action:@selector(rePlayMyVoice) forControlEvents:UIControlEventTouchUpInside];

        
        [PLCameraView addSubview:voiceReplayBtn];

        //按住说语录按钮
        NSInteger voicePressedWidth = overlyViewBKHeigth-15;
        NSInteger voicePressedHeigth =voicePressedWidth;
        UIImage *voicePressedImage = [UIImage imageNamed:@"Voice.png"];
        voicePressedBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-voicePressedWidth-10, overlyViewBk.center.y-voicePressedHeigth/2, voicePressedWidth, voicePressedHeigth)];
        [voicePressedBtn setImage:voicePressedImage forState:UIControlStateNormal];
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(myButtonLongPressed:)];
        gesture.minimumPressDuration =0;
        [voicePressedBtn addGestureRecognizer:gesture];
        [overlyView addSubview:voicePressedBtn];

        
        //拍照按钮
        //优化：未说语录之前，淡化
        NSInteger camerImageWidth = overlyViewBKHeigth-15;
        NSInteger camerImageHeigth =camerImageWidth;
        UIImage *camerImage = [UIImage imageNamed:@"拍照.png"];
        cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2+10, overlyViewBk.center.y-camerImageHeigth/2, camerImageWidth, camerImageHeigth)];
        [cameraBtn setImage:camerImage forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:cameraBtn];
        

        
        
        //合并拍照和语音后的按钮
        NSInteger mergedBtnWidth = overlyViewBKHeigth-15;
        NSInteger mergedBtnHeigth =mergedBtnWidth;
        UIImage *mergedBtnImage = [UIImage imageNamed:@"拍照.png"];
        mergedBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-mergedBtnWidth/2, overlyViewBk.center.y-mergedBtnHeigth/2, mergedBtnWidth, mergedBtnHeigth)];
        [mergedBtn setImage:mergedBtnImage forState:UIControlStateNormal];
        UILongPressGestureRecognizer *gestureMerge = [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(MergeButtonLongPressed:)];
        gestureMerge.minimumPressDuration =0;
        [mergedBtn addGestureRecognizer:gestureMerge];
        mergedBtn.hidden = YES;
        [overlyView addSubview:mergedBtn];
        
        
        //是否延迟
        [self delayBtnChangeHandler:Nil];
        


        
        /*
        //是否延迟
        if (self.userInfo.delayTakePhotoCtl==YES) {
            //隐藏
            [cameraBtn setFrame:CGRectMake(SCREEN_WIDTH/2-cameraBtn.frame.size.width/2, cameraBtn.frame.origin.y,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
            cameraBtn.opaque = YES;
            cameraBtn.hidden = YES;
            
            [voicePressedBtn setFrame:CGRectMake(SCREEN_WIDTH/2-voicePressedBtn.frame.size.width/2, voicePressedBtn.frame.origin.y,voicePressedBtn.frame.size.width,voicePressedBtn.frame.size.height)];
            voicePressedBtn.opaque = YES;
            voicePressedBtn.hidden = YES;
            
            mergedBtn.hidden = NO;
            
        }else
        {
            //不隐藏
            [cameraBtn setFrame:CGRectMake(ScreenWidth/2+10, cameraBtn.frame.origin.y,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
            cameraBtn.opaque = YES;
            cameraBtn.alpha = 1.0;
            cameraBtn.hidden = NO;
            
            [voicePressedBtn setFrame:CGRectMake(ScreenWidth/2-voicePressedBtn.frame.size.width-10,voicePressedBtn.frame.origin.y,voicePressedBtn.frame.size.width,voicePressedBtn.frame.size.height)];
            voicePressedBtn.opaque = YES;
            voicePressedBtn.alpha = 1.0;
            voicePressedBtn.hidden = NO;
            
            mergedBtn.hidden = YES;

            
        }
         */
        

        
        //打开相册按钮
        NSInteger albumImageWidth = 25;
        NSInteger albumImageHeigth =25;
        UIImage *albumImage = [UIImage imageNamed:@"相册.png"];
        UIButton *albumImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-albumImageWidth-15, overlyViewBk.center.y-albumImageHeigth/2, albumImageWidth, albumImageHeigth)];
        [albumImageBtn setImage:albumImage forState:UIControlStateNormal];
        [albumImageBtn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        [overlyView addSubview:albumImageBtn];
        
        //返回按钮
        NSInteger backBtnImageWidth = 40;
        NSInteger backBtnImageHeigth =30;
        UIImage *backImage = [UIImage imageNamed:@"返回.png"];
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, overlyViewBk.center.y-backBtnImageHeigth/2, backBtnImageWidth, backBtnImageHeigth)];
        [backBtn setImage: backImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:backBtn];
        


        
        self.cameraOverlayView = overlyView;
    }
}


- (void)TapSunMoonInTakePhotoHandler:(UITapGestureRecognizer*) gesture
{
    NSLog(@"Tap SunMoon in takephoto UI");
    bowLightView.hidden = NO;
    [bowLightView startAnimating];
    
}




- (void)delayBtnChangeHandler:(id)sender
{

    
    //nil时，只为开启动画，不是按钮触发
    if (sender == Nil) {
        
        if (self.userInfo.delayTakePhotoCtl ==  NO) {
            
            [self animationMergerButton:NO];
            [delayBtn setImage:[UIImage imageNamed:@"2秒开关底图-关.png"] forState:UIControlStateNormal];
            
        }else
        {
            [self animationMergerButton:YES];
            [delayBtn setImage:[UIImage imageNamed:@"2秒开关底图.png"] forState:UIControlStateNormal];
        }

    }else
    {
        if (self.userInfo.delayTakePhotoCtl ==  NO) {
            
            [self.userInfo updateDelayTakePhotoCtl:YES];
            [self animationMergerButton:YES];
            [delayBtn setImage:[UIImage imageNamed:@"2秒开关底图.png"] forState:UIControlStateNormal];
            
        }else
        {
            [self.userInfo updateDelayTakePhotoCtl:NO];
            [self animationMergerButton:NO];
            [delayBtn setImage:[UIImage imageNamed:@"2秒开关底图-关.png"] forState:UIControlStateNormal];
        }
    }

    
    
}

-(void) animationMergerButton:(BOOL) merger
{
    
    if (merger) {
        NSLog(@"合并语音与拍照按钮");
        [UIView beginAnimations:@"MergeAnimation" context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(MergeAnimationDidStop:finished:context:)];
        [cameraBtn setFrame:CGRectMake(SCREEN_WIDTH/2-cameraBtn.frame.size.width/2, cameraBtn.frame.origin.y,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
        cameraBtn.opaque = YES;
        cameraBtn.alpha = 0.2;
        
        [voicePressedBtn setFrame:CGRectMake(SCREEN_WIDTH/2-voicePressedBtn.frame.size.width/2, voicePressedBtn.frame.origin.y,voicePressedBtn.frame.size.width,voicePressedBtn.frame.size.height)];
        voicePressedBtn.opaque = YES;
        voicePressedBtn.alpha = 0.2;
        
        [UIView commitAnimations];
    }else
    {
        NSLog(@"分开 拍照与语音 按钮");
        [UIView beginAnimations:@"deMergeAnimation" context:(__bridge void *)(cameraBtn)];
        
        mergedBtn.hidden = YES;
        
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(deMergeAnimationDidStop:finished:context:)];
        [cameraBtn setFrame:CGRectMake(ScreenWidth/2+10, cameraBtn.frame.origin.y,cameraBtn.frame.size.width,cameraBtn.frame.size.height)];
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


- (void)deMergeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)contentBtn
{
    
    if ([animationID isEqualToString:@"deMergeAnimation"]) {
        NSLog(@"deMerge animation finished");
        
        mergedBtn.hidden = YES;
        
    }
    
}

- (void)MergeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextBtn
{
    
    if ([animationID isEqualToString:@"MergeAnimation"]) {
        NSLog(@"Merge animation finished");
        
        
        cameraBtn.hidden = YES;
        voicePressedBtn.hidden = YES;
        
        mergedBtn.hidden = NO;

    }
    
    
}

- (void) MergeButtonLongPressed:(UILongPressGestureRecognizer *)gesture
{
    //执行语音动作
    //语音名称 “时间_日月”
    [pressedVoice setVoiceName:_voiceName];
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
    [pressedVoice setVoiceName:_voiceName];
    [pressedVoice myButtonLongPressed:gesture];
    
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        if (![pressedVoice checkVoiceFile])
        {
            [voiceReplayBtn setImage:[UIImage imageNamed:@"放音-空.png"] forState:UIControlStateNormal];
            
        }else
        {
            [voiceReplayBtn setImage:[UIImage imageNamed:@"放音.png"] forState:UIControlStateNormal];
        }
        
        
        
        //判断是否奖励光
        if ([self checkwetherAndGiveLight]) {
            //giveMaxView.hidden = YES;
        };
    }

}

-(void)rePlayMyVoice
{

    [pressedVoice setVoiceName:_voiceName];
    
    if (voiceReplayBtn.selected == NO) {
        [pressedVoice playRecording];
    }else
    {
        [pressedVoice stopPlaying];
        
    }
    
    [voiceReplayBtn setSelected:!voiceReplayBtn.selected];
    
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

-(void)viewDidAppear:(BOOL)animated
{
    //判断是否增加阳光月光值
    if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
        if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
            
            
            customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
            [customAlertAutoDis setAlertMsg:@"阳光时间来过了，要每天认真说一次就好呢"];
            [customAlertAutoDis RunCumstomAlert];
            
            
        }
    }else
    {
        if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
            
            customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
            [customAlertAutoDis setAlertMsg:@"月光时间来过了，要每天认真说一次就好呢"];
            [customAlertAutoDis RunCumstomAlert];
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    sunMoonImageViewTop.hidden = YES;
  
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

#pragma mark - pitchDelegate

- (void)setNewPith:(float)pitchValue
{
    
    float newPitchValue = lroundf(pitchValue*700);
    NSLog(@"Voice value pitch = %f,  newPicth=%f", pitchValue,newPitchValue);

    if (newPitchValue <50) {
        //背景噪音干扰
        return;
    }
    
    //需大于原高度,需两个动画都结束
    if (newPitchValue>srcVoiceValueHeight && voiceAnimationLock == NO /*&&voiceBackAnimationLock == NO*/)
    {
        //保证升到最高值
//        float creaseValue;
//        if (newPitchValue > maxVoiceValue) {
//            creaseValue = newPitchValue;
//        }else
//        {
//            creaseValue = maxVoiceValue;
//        }
        [UIView beginAnimations:@"voiceValueAnimation" context:nil];
        [UIView setAnimationDuration:0.8f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(VoiceValueAnimationDidStop:finished:context:)];
        //CGRect temp = CGRectMake(voiceValueView.frame.origin.x, SCREEN_HEIGHT-newPitchValue,voiceValueView.frame.size.width,voiceValueView.frame.size.height);
       // NSLog(@"New rect x=%f  y=%f  w=%f   h=%f", temp.origin.x, temp.origin.y, temp.size.width,temp.size.height);
        //[voiceValueView setFrame:temp];
        
        voiceAnimationLock = YES;
        
        if (maxVoiceValue<newPitchValue) {
            maxVoiceValue = newPitchValue;
            NSLog(@"Max voice value 语音量 = %f", maxVoiceValue);
            
            //音量动画跟随,停在最高点
            [voiceValueView setFrame:CGRectMake(voiceValueView.frame.origin.x, SCREEN_HEIGHT-newPitchValue, voiceValueView.frame.size.width, voiceValueView.frame.size.height)];
            voiceValueView.alpha = 0.6;
            
            //是否超过音量设定
            if (newPitchValue > GIVE_ONE_LIGHT_VOICE_VALUE) {
                isOverMaxVoiceValue = YES;
            }
            
            //显示最大的音量值
            //giveMaxView.hidden = NO;
            //giveMaxView.alpha = 0.3;
            
            //到达或超过最大音量值的位置，则隐藏上升的光
//            if (voiceValueView.center.y <= giveMaxView.center.y) {
//                NSLog(@"超过了最大音量值！");
//                voiceValueView.hidden = YES;
//                giveMaxView.alpha = 0.6;
//
//            }
            
        }


        [UIView commitAnimations];
        

    
    }
    

 

    
    
}

- (void)VoiceValueAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextBtn
{
    if ([animationID isEqualToString:@"voiceValueAnimation"]) {

        voiceAnimationLock = NO;
        
        //延时1秒回原地
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(voiceValueViewBacktoPosition:) userInfo:nil repeats:NO];

    }
    
    if ([animationID isEqualToString:@"voiceValueBackAnimation"]) {
    
        voiceBackAnimationLock = NO;


    }
    
}

- (void)voiceValueViewBacktoPosition:(NSTimer *)timer
{

    if (voiceBackAnimationLock == NO) {
        [UIView beginAnimations:@"voiceValueBackAnimation" context:nil];
        [UIView setAnimationDuration:2.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(VoiceValueAnimationDidStop:finished:context:)];
        //CGRect temp = CGRectMake(voiceValueView.frame.origin.x, SCREEN_HEIGHT - srcVoiceValueHeight,voiceValueView.frame.size.width,voiceValueView.frame.size.height);
        //[voiceValueView setFrame:temp];
        
        voiceBackAnimationLock = YES;
        
        //音量动画跟随
        [voiceValueView setFrame:CGRectMake(voiceValueView.frame.origin.x, SCREEN_HEIGHT - srcVoiceValueHeight, voiceValueView.frame.size.width, voiceValueView.frame.size.height)];
        voiceValueView.alpha = 0.5;


        [UIView commitAnimations];
    }

    
}


-(BOOL)checkwetherAndGiveLight
{
    
    if (isHaveAddValue) {
        return NO;
    }
    
    if (isOverMaxVoiceValue)
    {
        NSLog(@"音量够大，奖励一个光");
        
        //增加光的动画准备
        [addVauleAnimation setStartPoint:self.view.center];
        [addVauleAnimation setEndpoint:sunMoonImageViewTop.center];
        [addVauleAnimation setUseRepeatCount:1];
        [addVauleAnimation setBkView:self.view];
        if (iSunORMoon == IS_SUN_TIME) {
            [addVauleAnimation setImageName:@"sun.png"];
        }else
        {
            [addVauleAnimation setImageName:@"moon.png"];
        }
        [addVauleAnimation setAminationImageViewframe:CGRectMake(voiceValueView.frame.origin.x, voiceValueView.frame.origin.y, 60, 60)];
        
        [addVauleAnimation moveLightWithIsUseRepeatCount:YES];
        isHaveAddValue = YES;
        
        return  YES;
        
    }else
    {
        
        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
        [customAlertAutoDis setAlertMsg:@"亲，多点自信，大点声哦！"];
        [customAlertAutoDis RunCumstomAlert];
        
        return  NO;
    }
    
    
}

#pragma mark - AminationCustomDelegate

- (void) animationFinishedRuturn
{
    
    
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
    sunMoonImageViewTop.hidden = YES;
    [self dismissViewControllerAnimated:NO completion:NULL];
}
- (void)takePicture
{
    if ([pressedVoice checkVoiceFile]) {
            [super takePicture];
    }else
    {
        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
        NSString* temp = [NSString stringWithFormat:@"说出你的%@光宣言，再拍照哦!", (iSunORMoon==IS_SUN_TIME)?@"阳":@"月"];
        [customAlertAutoDis setAlertMsg:temp];
        [customAlertAutoDis RunCumstomAlert];
        
    }


}


- (void)showPhoto
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        [CommonObject showActionSheetOptiontitleMsg:@"大声地说出美丽宣言，自拍后，才能获得阳光" ShowInView:self.view CancelMsg:@"就要用相片" DelegateObject:self Option:@"好嘞"];
        
        
    }else if([CommonObject checkSunOrMoonTime] ==  IS_MOON_TIME)
    {
        [CommonObject showActionSheetOptiontitleMsg:@"大声地说出美丽宣言，自拍后，才能获得阳光" ShowInView:self.view CancelMsg:@"就要用相片" DelegateObject:self Option:@"好嘞"];
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
                                   _voiceName, CAMERA_VOICE_NAEM_KEY,
                                   @"1", CAMERA_LIGHT_COUNT,
                                   nil];
        
        //test
//        NSInteger static i =1;
//        NSString * testDate = [NSString stringWithFormat:@"%d", i++];
//        NSDictionary *imageData = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   image,CAMERA_IMAGE_KEY,
//                                   testDate, CAMERA_TIME_KEY,
//                                   labelSentence, CAMERA_SENTENCE_KEY,
//                                   _voiceName, CAMERA_VOICE_NAEM_KEY,
//                                   nil];
        
        
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
        now = [self.userInfo.sunDataSourceArray objectAtIndex:row];
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        now = [self.userInfo.moonDataSourceArray objectAtIndex:row];
        
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
