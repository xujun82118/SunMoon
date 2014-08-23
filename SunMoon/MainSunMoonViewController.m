//
//  MainSunMoonViewController.m
//  SunMoon
//
//  Created by songwei on 14-3-30.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "MainSunMoonViewController.h"
#import "EAIntroView.h"
#import "NavBar.h"
#import "UserSetViewController.h"
#import "HomeInsideViewController.h"
#import "TakePhotoViewController.h"
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomImagePickerController.h"
#import "ImageFilterProcessViewController.h"
#import "WeatherLoc.h"
#import "AminationCustom.h"
#import "AddWaterMask.h"
#import "CustomAlertView.h"
#import "GuidController.h"




@interface MainSunMoonViewController ()
{
    GuidController* guidInfo;
    
    BOOL  isHaveFirstlyOpen; //第一次登录
    BOOL  isHaveOpenUI;  //第一次打开主界面，用于区分第一次登录，和第一次打开主界面
    
    BOOL  isGiveFirstLight;
    
    EAIntroView *intro ;
    
    BOOL  isFromHeaderBegin;
    BOOL  isFromSunMoonBegin;
    UIImageView* bringupImageView;    //光育成中要用的动画View
    UIImageView*  lightSkySunOrMoonView; //太阳或月亮闪烁动画View
    UIImageView*  lightBowSkyUserHeaderView; //头像爆闪烁动画View
    UIImageView* lightUserHeader;//头像闪烁动画View, 7个闪烁光环
    UIImageView* panTracelight;  //拖动轨迹
    NSInteger  panTraceligntTag; //拖动轨迹的TAG
    
    CALayer *panSunOrMoonlayer;  //拖动的动画图层
    
    BOOL isStartSunOrmoonImageMoveToHeaderAnimation;//起动了向头像移动光的动画
    BOOL isStartSunOrmoonImageMoveToSunMoonAnimation;//起动了向日月移动光的动画
    
    BOOL isPopOutIntoCameraBtn;  //是否已弹出
    BOOL isPopOutShowBringLightBtn;
    
    BOOL isContineGiveLight; //是连继登录奖励的光
    
    BOOL isGetinToHome; //是进入小屋的点击
    
    CGRect srcIntoCameraBtnFrame ;
    CGRect destIntoCameraBtnFrame ;
    
    CGRect srcShowBringLightBtnFrame;
    CGRect destShowBringLightBtnFrame;
    CGRect jumpSmallShowBringLightBtnFrame;
    BOOL  startJump;
    NSTimer*  JumpTimer;

    
    UIButton* _intoCameraBtn;
    UIButton* _showBringLightBtn;
    
    UIImageView* bowLightView; //日月闪爆闪
    UIImageView* bowLightBringView; //育成光爆闪
    
    CustomAlertView* customAlertAutoDis;
    
}

@end

@implementation MainSunMoonViewController

@synthesize mainBgImage,userInfo,userDB,userHeaderImageView = _userHeaderImageView;
@synthesize skySunorMoonImage =_skySunorMoonImage,panSunorMoonImageView =_panSunorMoonImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"---->viewDidLoad");

	// Do any additional setup after loading the view, typically from a nib.

    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    isHaveOpenUI = [userBaseData boolForKey:@"isHaveOpenUI"];
    isHaveFirstlyOpen = [userBaseData boolForKey:@"isHaveFirstlyOpen"];

    
    //获取用户账号    
    self.userInfo= [UserInfo  sharedSingleUserInfo];
    
    //获取引导配置
    guidInfo = [GuidController sharedSingleUserInfo];
    
    //第一次起动，使用默认用户
    if (!isHaveFirstlyOpen)
    {
        NSLog(@"New User, Opened firstly!");
        [userBaseData setBool:YES forKey:@"isHaveFirstlyOpen"];
        [userBaseData synchronize];

        //初始化用户为新用户
        self.userInfo = [self.userInfo initDefaultInfoAtFirstOpenwithTime:[CommonObject getCurrentTime]];
        
        [guidInfo updateFirstlyOpenGuidCtl:YES];

    }else
    {
        NSLog(@"Opened normally!");
        self.userInfo = [self.userInfo getUserInfoAtNormalOpen];
        
    }

    //获取同一个数据库，注：userDB不能放到userInfo中，会发生错误，原因不明
    userDB = [[UserDB alloc] init];
    

    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    //选择背景时间与日月图片等
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        [mainBgImage setImage:[UIImage imageNamed:@"主页底图002.png"]];
        [_skySunorMoonImage setImage:[UIImage imageNamed:@"sun.png"]];

        
    }else
    {
        [mainBgImage setImage:[UIImage imageNamed:@"moon-home.png"]];
        [_skySunorMoonImage setImage:[UIImage imageNamed:@"moon.png"]];


    }
    
    //起动时间监视
    [self startAlertTimerForSunMoonTime];
    
    
    //加载头像
    self.userHeaderImageView.image = self.userInfo.userHeaderImage;
    
    //创建拖动轨迹识别
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    //拖动动画图层
    panSunOrMoonlayer=[[CALayer alloc]init];
    
    //初始化日月动画图
    lightSkySunOrMoonView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"空白图"]];
    lightSkySunOrMoonView.userInteractionEnabled=YES;
    lightSkySunOrMoonView.contentMode=UIViewContentModeScaleToFill;
    NSInteger IntervalWidth = 0;// 光环向日月外扩的宽度,日月的光晕较大
    NSInteger lightSkySunOrMoonViewWidth = _skySunorMoonImage.frame.size.width+IntervalWidth*2;
    NSInteger lightSkySunOrMoonViewHeigth = _skySunorMoonImage.frame.size.height+IntervalWidth*2;
    
    
    //NSInteger lightSkySunOrMoonViewWidth =50;
    //NSInteger lightSkySunOrMoonViewHeigth = 50;
    
    [lightSkySunOrMoonView setFrame:CGRectMake(_skySunorMoonImage.center.x-lightSkySunOrMoonViewWidth/2, _skySunorMoonImage.center.y-lightSkySunOrMoonViewHeigth/2, lightSkySunOrMoonViewWidth, lightSkySunOrMoonViewHeigth)];


    
    [self.view addSubview:lightSkySunOrMoonView];
    [self.view bringSubviewToFront:_skySunorMoonImage];
    

    
    
    //日月点击爆闪
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<3; i++) {
        
        NSString *name=[NSString stringWithFormat:@"headerFrameBow_%d",i];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];
        
    }
    NSInteger lightBowSkySunMoonViewWidth = _skySunorMoonImage.frame.size.width+IntervalWidth*2;
    NSInteger lightBowSkySunMoonViewHeight = _skySunorMoonImage.frame.size.height+IntervalWidth*2;

    bowLightView = [[UIImageView alloc] initWithFrame:CGRectMake(_skySunorMoonImage.center.x-lightBowSkySunMoonViewWidth/2, _skySunorMoonImage.center.y-lightBowSkySunMoonViewWidth/2, lightBowSkySunMoonViewWidth, lightBowSkySunMoonViewHeight)];
    bowLightView.image=[UIImage imageNamed:@"空白图"];
    bowLightView.userInteractionEnabled=YES;
    bowLightView.contentMode=UIViewContentModeScaleToFill;
    bowLightView.animationImages=iArr;
    bowLightView.animationDuration=1;
    bowLightView.animationRepeatCount = 1;
    [self.view addSubview:bowLightView];
    [self.view  bringSubviewToFront:_skySunorMoonImage];
    
    
    
    
    //初始化头像闪烁动画图
    for (int i=0 ; i<7; i++) {
        lightUserHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lightCircle.png"]];
        lightUserHeader.tag = TAG_LIGHT_USER_HEADER+i;
        lightUserHeader.userInteractionEnabled=YES;
        lightUserHeader.contentMode=UIViewContentModeScaleToFill;
        lightUserHeader.hidden = YES;
        [self.view addSubview:lightUserHeader];
        
    }

    
    //增加点击识别，进入拍照，或回归光到头像, 拖动也可让光回到头像
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSkySumOrMoonhandle:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 1;
    _skySunorMoonImage.userInteractionEnabled = YES;
    [_skySunorMoonImage addGestureRecognizer:recognizer];

    
    
    //初始化弹出按钮, 位置在太阳月亮中, 是否有光在育成
    NSInteger inTocameraBtnWidth = 60;
    NSInteger inTocameraBtnHeight = 60;
    srcIntoCameraBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
    destIntoCameraBtnFrame = CGRectMake(20,_skySunorMoonImage.center.y+50, inTocameraBtnWidth,inTocameraBtnHeight);
    
    NSInteger bringLightBtnWidth = 60;
    NSInteger bringLightBtnHeight = 60;
    srcShowBringLightBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
    destShowBringLightBtnFrame = CGRectMake(SCREEN_WIDTH-bringLightBtnWidth-20,_skySunorMoonImage.center.y+50, bringLightBtnWidth, bringLightBtnHeight);

    NSInteger bringLightJumpWidth = bringLightBtnWidth/3;
    NSInteger bringLightJumpHeight = bringLightBtnHeight/3;
    jumpSmallShowBringLightBtnFrame = CGRectMake(destShowBringLightBtnFrame.origin.x+(bringLightBtnWidth-bringLightJumpWidth)/2,destShowBringLightBtnFrame.origin.y+(bringLightBtnHeight-bringLightJumpHeight)/2, bringLightJumpWidth, bringLightJumpHeight);
    
    _intoCameraBtn = [[UIButton alloc] initWithFrame:srcIntoCameraBtnFrame];
    [_intoCameraBtn addTarget:self action:@selector(intoCamera:) forControlEvents:UIControlEventTouchUpInside];

    _showBringLightBtn = [[UIButton alloc] initWithFrame:srcShowBringLightBtnFrame];
    [_showBringLightBtn addTarget:self action:@selector(getBringedUpLight:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun.png"] forState:UIControlStateNormal];
        }else
        {
            
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun-点.png"] forState:UIControlStateNormal];
        }

        
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun.png"] forState:UIControlStateNormal];
        }else
        {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun-空.png"] forState:UIControlStateNormal];
        }

        
    }else
    {

        if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon.png"] forState:UIControlStateNormal];
        }else
        {
            
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon-点.png"] forState:UIControlStateNormal];
        }
        
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon.png"] forState:UIControlStateNormal];
        }else
        {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon-空.png"] forState:UIControlStateNormal];
        }

        
    }

    isPopOutIntoCameraBtn = NO;
    isPopOutShowBringLightBtn = NO;
    //[self.view addSubview:_intoCameraBtn];
    [self.view addSubview:_intoCameraBtn];
    [self.view addSubview:_showBringLightBtn];
    //[self.view insertSubview:_skySunorMoonImage belowSubview:_intoCameraBtn];
    //[self.view insertSubview:_skySunorMoonImage belowSubview:_showBringLightBtn];
    
    /*
    //初始化育成光的爆闪动画，提示点击，5秒不点击则收回
    NSMutableArray *iArrBring=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<8; i++) {
        
        NSString *name=[NSString stringWithFormat:@"headerFrame_%d",i];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArrBring addObject:image];
        
    }
    NSInteger lightBowBringLightViewWidth = destShowBringLightBtnFrame.size.width+IntervalWidth*2;
    NSInteger lightBowBringLightViewHeight = destShowBringLightBtnFrame.size.height+IntervalWidth*2;
    
    bowLightBringView = [[UIImageView alloc] initWithFrame:CGRectMake(destShowBringLightBtnFrame.origin.x, destShowBringLightBtnFrame.origin.y, lightBowBringLightViewWidth, lightBowBringLightViewHeight)];
    bowLightBringView.image=[UIImage imageNamed:@"空白图"];
    bowLightBringView.userInteractionEnabled=YES;
    bowLightBringView.contentMode=UIViewContentModeScaleToFill;
    bowLightBringView.animationImages=iArrBring;
    bowLightBringView.animationDuration=0.3;
    bowLightBringView.animationRepeatCount = 1000;
    [self.view addSubview:bowLightBringView];
    [self.view  bringSubviewToFront:_skySunorMoonImage];
     */
    
    //test
    /*
    userInfo.date_time = [CommonObject getCurrentDate];
    userInfo.sun_value = @"100";
    userInfo.sun_image = UIImagePNGRepresentation([UIImage imageNamed:@"sun.png"]);
    userInfo.sun_image_sentence = @"test...sentence";
    userInfo.sun_image_name = @"test...name";
    [userDB saveUser:userInfo ];

    [userDB deleteUserWithDataTime:userInfo.date_time];
    [userDB getUserDataByDateTime:userInfo.date_time];
    [userDB mergeWithUserByDateTime:userInfo];
    */

    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"---->viewWillAppear");

    //起动引导界面
    if (guidInfo.fristlyOpenGuidCtl) {
        
        [self showIntroWithCrossDissolve];

    }
    


    //重取一次数
    [self.userInfo  getUserCommonData];

    self.navigationController.navigationBarHidden = YES;

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"---->viewDidAppear");
    
    
    //初始化头像爆闪动画图
    //不能放到veiwDidload 和viewWillapear中
    lightBowSkyUserHeaderView=[[UIImageView alloc] init];
    lightBowSkyUserHeaderView.image=[UIImage imageNamed:@"空白图"];
    lightBowSkyUserHeaderView.userInteractionEnabled=YES;
    lightBowSkyUserHeaderView.contentMode=UIViewContentModeScaleToFill;
    
    NSInteger IntervalWidth1 = LIGHT_ANIMATION_INTERVAL;// 光环向头像外扩的宽度
    NSInteger lightBowSkyUserHeaderViewWidth = _userHeaderImageView.frame.size.width+IntervalWidth1*2;
    NSInteger lightBowSkyUserHeaderViewHeigth = _userHeaderImageView.frame.size.height+IntervalWidth1*2;
    [lightBowSkyUserHeaderView setFrame:CGRectMake(_userHeaderImageView.center.x-lightBowSkyUserHeaderViewWidth/2, _userHeaderImageView.center.y-lightBowSkyUserHeaderViewHeigth/2, lightBowSkyUserHeaderViewWidth, lightBowSkyUserHeaderViewHeigth)];
    [self.view addSubview:lightBowSkyUserHeaderView];
    [self.view bringSubviewToFront:_userHeaderImageView];

    //退出了小屋
    isGetinToHome = NO;
    
    //WeatherLoc* testWeather = [[WeatherLoc alloc] init];
   //[testWeather startGetWeather];
    //[testWeather startGetWeatherSimple];
    
    //test
    //self.userInfo.userType =USER_TYPE_NEW;
    
    if (!guidInfo.fristlyOpenGuidCtl)
    {
        //第二次进入主界面时，提示滑屏
        if (!guidInfo.guidPanToBring) {
            customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话-蓝.png"  yesBtnImageName:@"ok.png" posionShowMode:userSet];
            [customAlertAutoDis setStartCenterPoint:_showBringLightBtn.center];
            [customAlertAutoDis setEndCenterPoint:self.view.center];
            [customAlertAutoDis setStartAlpha:0.1];
            [customAlertAutoDis setEndAlpha:1.0];
            [customAlertAutoDis setStartHeight:0];
            [customAlertAutoDis setStartWidth:0];
            [customAlertAutoDis setEndWidth:SCREEN_WIDTH/5*2];
            [customAlertAutoDis setEndHeight:customAlertAutoDis.endWidth];
            [customAlertAutoDis setDelayDisappearTime:5.0];
            [customAlertAutoDis setMsgFrontSize:30];
            NSString* lightType = ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月";
            [customAlertAutoDis setAlertMsg:[NSString stringWithFormat:@"拖动%@到%@，3小时可养成1个%@光哦", lightType,lightType,lightType]];
            [customAlertAutoDis RunCumstomAlert];
            
            [guidInfo updateGuidPanToBring:YES];
        }
        
        [self whenCommonOpenViewHandle];

    }
    
    

    //把引导界面显示到最前面
    if (guidInfo.fristlyOpenGuidCtl) {
    
        [self.view bringSubviewToFront:intro];
        
        //关闭引导
        [guidInfo updateFirstlyOpenGuidCtl:NO];
    }
    

    



}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [self animationForIntoCameraBtnPop:NO];
    
    
    
//    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
//    [userBaseData setBool:YES forKey:@"isHaveOpenUI"];
//    [userBaseData synchronize];
}


-(void)whenFirstlyOpenViewHandle
{
    //第一次打开，奖励一个光值
    [self.userInfo  addSunOrMoonValue:1];
    [self.userInfo updateisBringUpSunOrMoon:YES];
    [self setShowBringLightBtnHaveLight:YES];
    
    //弹出按钮
    [self animationForIntoCameraBtnPop:YES];
    [self animationForShowBringLightBtnPop:YES];
    isGiveFirstLight = YES;


    //更新光育成时间
    [self.userInfo updateSunorMoonBringupTime:[NSDate date]];

    NSLog(@"等待点击光环。。");
    
    

    

    
}

-(void)whenCommonOpenViewHandle
{
    
    //始终弹出相机按键
    [self animationForIntoCameraBtnPop:YES];
    
    //判断是否是新登录, 新登录，连续登录值置为1， 连续登录，连续值加1
    //连续登录可得阳光，月光值1个
    if (![self.userInfo checkLoginLastDateIsToday])
    {
        NSLog(@"当天新登录,更新当天照片未加光值");
        [self.userInfo updateIsHaveAddSunValueForTodayPhoto:NO];
        [self.userInfo updateIsHaveAddMoonValueForTodayPhoto:NO];

        NSLog(@"当天新登录，判断是否连续登录？");
        
        if ([self.userInfo checkLoginLastDateIsYesterday])
        {
            NSLog(@"昨天刚登录过，是连续登录, 连续值+1！");
            [self.userInfo addContinueLogInCount];
            
            //连续登录，阳光月光+1
            [self.userInfo addSunOrMoonValue:1];
            
            //奖励提示
            isContineGiveLight = YES;
            customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
            if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                [customAlertAutoDis setAlertMsg:@"阳光时间连续登录，奖励一个阳光"];

            }else
            {
                [customAlertAutoDis setAlertMsg:@"月光时间连续登录，奖励一个月光"];

            }
            [customAlertAutoDis RunCumstomAlert];
            
            //弹出育成图
            [self animationForShowBringLightBtnPop:YES];
  

            
            //改：光存在了日月里
            //[self moveLightWithRepeatCount:1 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];
            
            //isStartSunOrmoonImageMoveToHeaderAnimation = YES;
            
            
        }else
        {
            NSLog(@"新登录，但未连续登录， 连续值置1！");
            [self.userInfo updateContinueLogInCount:1];
            
        }
        
        
        
    }else{
        
        NSLog(@"同一天已登录过，不再判断是否加值！");
        
    }
    
    //更新登录时间
    [self.userInfo setLoginToday];

    
    //是否有光在育成
    if (self.userInfo.sun_value || self.userInfo.moon_value)
    {
        
        
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            //有则，闪烁
            [self animationLightFrameSkySunOrMoon:7];
            NSLog(@"有光在育成， 闪烁。。");
            
            //弹出育成图
            [self animationForShowBringLightBtnPop:YES];

        }else
        {
            
            //头像闪烁
            if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
                NSLog(@"无光在育成， 开启头像闪烁动画！");
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
                
            }else
            {
                NSLog(@"无光在育成， 开启头像闪烁动画！");
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
                
            }
            
            
        }
        
    }
    
    
}

#pragma mark - CustomAlertDelegate
- (void) CustomAlertOkReturn
{
    NSLog(@"custom aler ok return");
}

#pragma mark -  弹出动画
-(void) animationForIntoCameraBtnPop:(BOOL)isPop
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun.png"] forState:UIControlStateNormal];
        }else
        {
            
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun-点.png"] forState:UIControlStateNormal];
        }
        
        
    }else
    {
        
        if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon.png"] forState:UIControlStateNormal];
        }else
        {
            
            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon-点.png"] forState:UIControlStateNormal];
        }
        
    }
    
    
    if (isPop) {
        [UIView beginAnimations:@"popOut_IntoCameraBtn" context:(__bridge void *)(_intoCameraBtn)];
        [UIView setAnimationDuration:0.8f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
        NSLog(@"popOut IntoCameraBtn!");
        [_intoCameraBtn setFrame:destIntoCameraBtnFrame];
        [UIView commitAnimations];
        
        //[self.view bringSubviewToFront:_intoCameraBtn];
        isPopOutIntoCameraBtn = YES;
        
    }else
    {
        [UIView beginAnimations:@"popBack_IntoCameraBtn" context:Nil];
        [UIView setAnimationDuration:0.8f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
        NSLog(@"popBack IntoCameraBtn!");
        [_intoCameraBtn setFrame:srcIntoCameraBtnFrame];
        [UIView commitAnimations];
        
        //[self.view bringSubviewToFront:_skySunorMoonImage];
        isPopOutIntoCameraBtn = NO;
    }
    
}

-(void) animationForShowBringLightBtnPop:(BOOL)isPop
{
    

    //有光在育成才弹出,或是奖励的一个光也弹出
    if (isPop && ([self.userInfo checkIsBringUpinSunOrMoon]||isContineGiveLight)) {
        [UIView beginAnimations:@"popOut_showBringLightBtn" context:Nil];
        [UIView setAnimationDuration:0.8f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
        NSLog(@"popOut showBringLightBtn!");
        [_showBringLightBtn setFrame:destShowBringLightBtnFrame];
        [UIView commitAnimations];
        isPopOutShowBringLightBtn = YES;
        
        
        //奖励光，但又没有光在育成时，设为有光
        if (isContineGiveLight) {
            [self setShowBringLightBtnHaveLight:YES];
        }

        
    }else
    {
        [UIView beginAnimations:@"popBack_showBringLightBtn" context:Nil];
        [UIView setAnimationDuration:0.8f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
        NSLog(@"popBack showBringLightBtn!");
        [_showBringLightBtn setFrame:srcShowBringLightBtnFrame];
        
        [UIView commitAnimations];
        
        //[self.view bringSubviewToFront:_skySunorMoonImage];
        isPopOutShowBringLightBtn = NO;

        
        
    }
    
}

- (void)animationPopOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    if ([animationID isEqualToString:@"popOut_showBringLightBtn"]) {
        
        if (isGiveFirstLight) {
            customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话-蓝.png"  yesBtnImageName:nil posionShowMode:userSet];
            [customAlertAutoDis setStartCenterPoint:_showBringLightBtn.center];
            [customAlertAutoDis setEndCenterPoint:self.view.center];
            [customAlertAutoDis setStartAlpha:0.1];
            [customAlertAutoDis setEndAlpha:1.0];
            [customAlertAutoDis setStartHeight:0];
            [customAlertAutoDis setStartWidth:0];
            [customAlertAutoDis setEndWidth:SCREEN_WIDTH/5*2];
            [customAlertAutoDis setEndHeight:customAlertAutoDis.endWidth];
            [customAlertAutoDis setDelayDisappearTime:5.0];
            [customAlertAutoDis setMsgFrontSize:30];
            [customAlertAutoDis setAlertMsg:@"首次登录，奖励一个阳光，或月光, 点击光"];
            [customAlertAutoDis RunCumstomAlert];
            isGiveFirstLight = NO;
        }

        
    }

    
    if ([animationID isEqualToString:@"popBack_showBringLightBtn"]) {
        
        if (isContineGiveLight) {
            //奖励时，只移动一个光
            [self moveLightWithRepeatCount:1 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];
            //更新育成光环状态
            [self setShowBringLightBtnHaveLight:NO];
            
            isContineGiveLight = NO;
            isStartSunOrmoonImageMoveToHeaderAnimation = YES;

            
        }else
        {
            
            //移动光到头像
            if ([self.userInfo checkIsBringUpinSunOrMoon]) {
                
                NSLog(@"停光的育成，移动到头像！");
                
                [self moveLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
                
                isStartSunOrmoonImageMoveToHeaderAnimation = YES;
                
                [self.userInfo updateisBringUpSunOrMoon:NO];
                //更新育成光环状态
                [self setShowBringLightBtnHaveLight:NO];
                
                //计算育成的时间，奖励光
                [self caculateAndGiveSunOrMoon];
                
                //清空光育成时间
                [self.userInfo updateSunorMoonBringupTime:0];
                
                //停止跳动动画
//                startJump = NO;
//                if (JumpTimer) {
//                    [JumpTimer invalidate];
//                }
                
//                customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
//                [customAlertAutoDis setAlertMsg:@"停止育成光"];
//                [customAlertAutoDis RunCumstomAlert];
                

                
            }else
            {
                NSLog(@"没有光在育成！");
                
            }
            
        }
        

        
        
    }
    
    
    
    
    if ([animationID isEqualToString:@"JumpToBig_showBringLightBtn"]) {
        
        if (startJump) {
            //再变小
            [self animationForBringLightBtnJump];
        }else
        {
            //停止跳动时，已弹回
            [self animationForShowBringLightBtnPop:NO];
            
        }
        

        
    }
    
    if ([animationID isEqualToString:@"JumpToSmall_showBringLightBtn"]) {
    
        
        if (startJump) {
            //变小后，再变大
            [UIView beginAnimations:@"JumpToBig_showBringLightBtn" context:Nil];
            [UIView setAnimationDuration:0.8f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
            NSLog(@"popOut showBringLightBtn!");
            [_showBringLightBtn setFrame:destShowBringLightBtnFrame];
            [UIView commitAnimations];
        }else
        {
            //停止跳动时，已弹回
            [self animationForShowBringLightBtnPop:NO];
            
        }
        

        
        
    }
    
    /*
    if ([animationID isEqualToString:@"popBack_showBringLightBtn"]) {
        
        
        //移动光到头像
        [self moveLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
        
        //更新为无光在育成
        [self.userInfo updateisBringUpSunOrMoon:NO];
        //更新育成光环状态
        [self setShowBringLightBtnHaveLight:NO];
        
        //计算育成的时间，奖励光
        [self caculateAndGiveSunOrMoon];
        
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        [CommonObject showAlert:@"停止育成光" titleMsg:Nil DelegateObject:Nil];
        
        NSLog(@"光回到了头像，开启头像闪烁动画！");
        if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
            
        }else
        {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
            
        }
        
    }*/
    
}

-(void) animationForBringLightBtnJump
{
    
    [UIView beginAnimations:@"JumpToSmall_showBringLightBtn" context:Nil];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
    NSLog(@"JumpToSmall   showBringLightBtn!");
    [_showBringLightBtn setFrame:jumpSmallShowBringLightBtnFrame];
    
    startJump = YES;
    [UIView commitAnimations];
    
    
}


#pragma mark -  弹出按钮处理
- (void)getBringedUpLight:(id)sender
{
    //弹回光, 动画结束时处理后续
    [self animationForShowBringLightBtnPop:NO];
    
}

-(void)setShowBringLightBtnHaveLight:(BOOL) isLight
{
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if (isLight) {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun.png"] forState:UIControlStateNormal];
        }else
        {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun-空.png"] forState:UIControlStateNormal];
            
        }
    }else
    {
        if (isLight) {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon.png"] forState:UIControlStateNormal];
        }else
        {
            [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon-空.png"] forState:UIControlStateNormal];
            
        }
    }
    
 
    
}

- (void)intoCamera:(id)sender {
    
    CustomImagePickerController *controller = [[CustomImagePickerController alloc] init];
    
    // 拍照
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos])
    {
        
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([self isFrontCameraAvailable])
        {
            controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        
    }
    else
    {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            [controller setIsSingle:YES];
        }
    }
    
    //指向他的委托函数
    [controller setCustomDelegate:self];
    [controller setISunORMoon:[CommonObject checkSunOrMoonTime]];
    [controller setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [controller setUserInfo:self.userInfo];
    [self presentViewController:controller
                       animated:YES
                     completion:^(void){
                         //NSLog(@"Picker View Controller is presented");
                     }];
    
    
    
}

#pragma mark - customimagePicker delegate
- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn
{
    
    //重取一次数,delegate回来时，不会调用viewDidappear等
    [self.userInfo  getUserCommonData];
    
    ImageFilterProcessViewController*  fitler = [[ImageFilterProcessViewController alloc] init];
    
    [fitler setDelegate:self];
    [fitler setISunORMoon:[CommonObject checkSunOrMoonTime]];
    [fitler setUserInfo:self.userInfo];
    fitler.imagePickerData = imagePickerDataReturn;
    [self presentViewController:fitler animated:YES completion:NULL];
    
    
    
}

- (void)cancelCamera
{
    
    
}

#pragma mark - imagefilter delegate
#pragma mark - 照完象， 存用户据
- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData
{
    

    
    //存图片到数据库
    
    //获取时间
    //NSString* imageTime = [CommonObject getCurrentDate];
    //NSLog(@"--image time =%@",  imageTime);
    
    NSLog(@"Save one user data from camera!");
    [self saveUserDataFromCamera:imageFilterData];

    //重取一次数,delegate回来时，不会调用viewDidappear等
    [self.userInfo  getUserCommonData];
    
    //NSLog(@"---path=%@", [userDB getDBPath]);
    
    //UserInfo* userer=[userDB getUserDataByDateTime:imageTime];
    
}



#pragma mark -  定时器
-(void)startAlertTimerForSunMoonTime
{
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkSunMoonChangeTimeMethod:) userInfo:nil repeats:YES];
    
    
}

- (void)checkSunMoonChangeTimeMethod:(NSTimer *)timer
{
    
    NSDate *_date = [NSDate date];
    
    NSDateComponents* comps;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:_date];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];

    
    if (hour==SUN_TIME_MAX || hour==SUN_TIME_MIN) {
        
        //0分0秒时，刷新UI
        if (minute == 0 &&second ==0) {
            NSLog(@"Is time to change UI");
            [self reFreshSunOrMoonUI];

        }
        
    }
    
    //test
//    if (hour==15) {
//        
//        //0分0秒时，刷新UI
//        if (minute == 16 && second ==0) {
//            NSLog(@"Is time to change UI");
//            [self reFreshSunOrMoonUI];
//            
//        }
//        
//    }
    
}

-(void)startTimerForPopBackBringlight
{

    
    JumpTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkIsTimeForBackBringLightMethod:) userInfo:nil repeats:NO];
    
    
}

- (void)checkIsTimeForBackBringLightMethod:(NSTimer *)timer
{
    //收回光环, 后续处理都在收回动画结束后
    [self animationForShowBringLightBtnPop:NO];
    
}

#pragma mark -  change sun or moon UI
-(void) reFreshSunOrMoonUI
{
    
    [UIView beginAnimations:@"reFreshSunMoonUI_DisPre" context:(__bridge void *)(mainBgImage)];
    [UIView setAnimationDuration:2.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
    NSLog(@"Disapear old UI : %@", [mainBgImage.image description]);
    mainBgImage.alpha = 0.2;
    [UIView commitAnimations];
    
    
    
}



- (void)reFreshSunMoonUIAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_DisPre"]) {
        
        
        [UIView beginAnimations:@"reFreshSunMoonUI_ShowNew" context:(__bridge void *)(mainBgImage)];
        [UIView setAnimationDuration:3.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
        
        if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
            [mainBgImage setImage:[UIImage imageNamed:@"主页底图002.png"]];
            [_skySunorMoonImage setImage:[UIImage imageNamed:@"sun.png"]];
            if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
                [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun.png"] forState:UIControlStateNormal];
            }else
            {
                
                [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun-点.png"] forState:UIControlStateNormal];
            }
            if ([self.userInfo checkIsBringUpinSunOrMoon]) {
                [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun.png"] forState:UIControlStateNormal];
            }else
            {
                [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun-空.png"] forState:UIControlStateNormal];
            }
            //test
            //[mainBgImage setImage:[UIImage imageNamed:@"moon-home.png"]];
            
            
        }else
        {
            [mainBgImage setImage:[UIImage imageNamed:@"moon-home.png"]];
            [_skySunorMoonImage setImage:[UIImage imageNamed:@"moon.png"]];
            if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
                [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon.png"] forState:UIControlStateNormal];
            }else
            {
                
                [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon-点.png"] forState:UIControlStateNormal];
            }
            if ([self.userInfo checkIsBringUpinSunOrMoon]) {
                [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon.png"] forState:UIControlStateNormal];
            }else
            {
                [_showBringLightBtn setImage:[UIImage imageNamed:@"环-moon-空.png"] forState:UIControlStateNormal];
            }
        }
        NSLog(@"Change new  UI to %@", [mainBgImage.image description]);
        
        
        mainBgImage.alpha = 1.0;
        [UIView commitAnimations];

    }
    
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_ShowNew"]) {
        if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
            [CommonObject showAlert:NSLocalizedString(@"Change to sun time hi message", @"")  titleMsg:nil DelegateObject:self];
        }else
        {
            [CommonObject showAlert:NSLocalizedString(@"Change to moon time hi message", @"") titleMsg:nil DelegateObject:self];
            
            
        }
        
    }
    
}


#pragma mark -  getter
- (UIImageView *)userHeaderImageView {
    
    [_userHeaderImageView setFrame:CGRectMake(_userHeaderImageView.frame.origin.x, _userHeaderImageView.frame.origin.y, _userHeaderImageView.frame.size.width, _userHeaderImageView.frame.size.height)];
    [_userHeaderImageView.layer setCornerRadius:(_userHeaderImageView.frame.size.height/2)];
    _userHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_userHeaderImageView.layer setMasksToBounds:YES];
    [_userHeaderImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_userHeaderImageView setClipsToBounds:YES];
    _userHeaderImageView.layer.shadowColor = [UIColor clearColor].CGColor;
    _userHeaderImageView.layer.shadowOffset = CGSizeMake(4, 4);
    _userHeaderImageView.layer.shadowOpacity = 0.5;
    _userHeaderImageView.layer.shadowRadius = 2.0;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        _userHeaderImageView.layer.borderColor = [[UIColor orangeColor] CGColor];

    }else
    {
        _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];

    }
    _userHeaderImageView.layer.borderWidth = 3.5f;
    _userHeaderImageView.layer.cornerRadius =40.0;
    _userHeaderImageView.userInteractionEnabled = YES;
    _userHeaderImageView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapUserHeader)];
    [_userHeaderImageView addGestureRecognizer:portraitTap];
    
    
    return _userHeaderImageView;
}


#pragma mark -  handle Pan

//点击日月,弹出按键
-(void)TapSkySumOrMoonhandle:(UITapGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [bowLightView startAnimating];
    
    }
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        //有一个未弹出, 则都置为未弹出
        if (!(isPopOutIntoCameraBtn && isPopOutShowBringLightBtn)) {
            isPopOutShowBringLightBtn = NO;
            isPopOutShowBringLightBtn =  NO;
        }
        
        if (isPopOutIntoCameraBtn && !isPopOutShowBringLightBtn) {
            //拍照按钮在外，先收回
            [self animationForIntoCameraBtnPop:NO];

        }else
        {
            if (!isPopOutIntoCameraBtn && isPopOutShowBringLightBtn) {
                //光环在外，先收回
                [self animationForShowBringLightBtnPop:NO];

            }
            
            if (isPopOutIntoCameraBtn && isPopOutShowBringLightBtn) {
                //如果都在外面，都收回
                [self animationForIntoCameraBtnPop:NO];
                [self animationForShowBringLightBtnPop:NO];
            }else
            {
                //如果都在内，都弹出
                [self animationForIntoCameraBtnPop:YES];
                [self animationForShowBringLightBtnPop:YES];
            }

            
        }


    }

}

//拖动识别
- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if (self.userInfo.sun_value==0  ) {
            NSLog(@"sun_value==0 handlePan return");
            return;
        }
        
        _panSunorMoonImageView.image =[UIImage imageNamed:@"sun.png"];
        
    }else
    {
        if (self.userInfo.moon_value == 0) {
            NSLog(@"moon_value==0 handlePan return");
            return;
        }
        _panSunorMoonImageView.image =[UIImage imageNamed:@"moon.png"];

        
    }
    
    
    
    CGPoint location = [gestureRecognizer locationInView:self.view];
    
    //**************从头像拖动到日月*************
    BOOL isLightInHeader = NO;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if (self.userInfo.isBringUpSun == NO  ) {
            //光在头像中
            isLightInHeader = YES;
        }
    }else
    {
        if (self.userInfo.isBringUpMoon == NO  ) {
            //光在头像中
            isLightInHeader = YES;
            
        }
        
    }
    
    
    if (isLightInHeader) {
        //有光在头像中，可以开始从头像的拖动识别！
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
            
            NSInteger w = _userHeaderImageView.frame.size.width;
            NSInteger h = _userHeaderImageView.frame.size.height;
            CGRect tapRect = CGRectMake(location.x-w/2, location.y-h/2, w, h);
            
            CGRect intersect = CGRectIntersection(_userHeaderImageView.frame, tapRect);
            //同一区域
            if (intersect.size.height>50 || intersect.size.width>50)
            {
                NSLog(@" 开始拖动手势： 起点：头像之内！");
                isFromHeaderBegin = YES;
                _panSunorMoonImageView.center = _userHeaderImageView.center;
                _panSunorMoonImageView.alpha = 1.0;
                _panSunorMoonImageView.hidden =  NO;
                
            }else
            {
                NSLog(@" 开始拖动手势： 起点：头像之外！");
                isFromHeaderBegin = NO;
            }
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {

            
            if (isFromHeaderBegin) {
                _panSunorMoonImageView.hidden =  NO;
                _panSunorMoonImageView.center = location;
                _panSunorMoonImageView.alpha = 1.0;
                
                if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun.png"]];
                    
                }else
                {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon.png"]];
                    
                }
                [panTracelight setFrame:CGRectMake(location.x, location.y, 15, 15)];
                panTracelight.tag = TAG_LIGHT_TRACE+(++panTraceligntTag);
                panTracelight.contentMode=UIViewContentModeScaleToFill;
                [self.view addSubview:panTracelight];
            }

            
        }
        
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            //是否在太阳，月亮区
            NSInteger w = _skySunorMoonImage.frame.size.width;
            NSInteger h = _skySunorMoonImage.frame.size.height;
            CGRect tapRect = CGRectMake(location.x-w/2, location.y-h/2, w, h);
            
            CGRect intersect = CGRectIntersection(_skySunorMoonImage.frame, tapRect);
            //同一区域
            if (intersect.size.height>h/5*4 || intersect.size.width>w/5*4)
            {
                
                NSLog(@" 结束拖动手势： 终点：日月之内！");
                if (isFromHeaderBegin) {
                    NSLog(@"光被拖回日月育成！");
                    [self moveLightWithRepeatCount:0 StartPoint:_userHeaderImageView.center EndPoint:_skySunorMoonImage.center IsUseRepeatCount:NO];
                    isStartSunOrmoonImageMoveToSunMoonAnimation = YES;
                    
                    //更新为有光在育成
                    [self.userInfo updateisBringUpSunOrMoon:YES];
                    //更新光育成时间
                    [self.userInfo updateSunorMoonBringupTime:[NSDate date]];
                    //更新育成光环状态
                    [self setShowBringLightBtnHaveLight:YES];

                    //动画完成后，弹出育成光环

                    NSString* time = [NSString stringWithFormat:@"开始养育%@光了", ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
                    NSLog(@"%@", time);
                    customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
                    [customAlertAutoDis setAlertMsg:time];
                    [customAlertAutoDis RunCumstomAlert];
                    
                    
                }else
                {
                    NSLog(@"不是从 头像 开始！");

                }
                
                isFromHeaderBegin = NO;
                
                
            }else
            {
                
                NSLog(@" 结束拖动手势： 终点：日月之外, 回到日月！");
                //需以头像为起点
                if (isFromHeaderBegin) {
                    
                    //回到头像里动画
                    [self moveLightWithRepeatCount:1 StartPoint:location EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];

                    isStartSunOrmoonImageMoveToHeaderAnimation = YES;
                    
                }else
                {
                    NSLog(@"不是从 头像 开始！");
                    
                }
                
                
            }
            
        }


    }else
    {
        //@"无光在头像中，不可以拖动"
        
    }
    
    
     //***************************

    //**************从日月拖动到头像*************
    BOOL isLightBringup = NO;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if (self.userInfo.isBringUpSun == YES  ) {
            //光在日月中！
            isLightBringup = YES;

        }
    }else
    {
        if (self.userInfo.isBringUpMoon == YES  ) {
            //光在日月中
            isLightBringup = YES;
            
        }
    }
    
    if (isLightBringup) {
        //有光在日月中育成，可以开始从日月的拖动识别"
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
            
            NSInteger w = _skySunorMoonImage.frame.size.width;
            NSInteger h = _skySunorMoonImage.frame.size.height;
            CGRect tapRect = CGRectMake(location.x-w/2, location.y-h/2, w, h);
            
            CGRect intersect = CGRectIntersection(_skySunorMoonImage.frame, tapRect);
            //同一区域
            if (intersect.size.height>h/5*4 || intersect.size.width>w/5*4)
            {
                NSLog(@" 开始拖动手势： 起点：日月之内！");
                isFromSunMoonBegin = YES;
                _panSunorMoonImageView.center = _skySunorMoonImage.center;
                _panSunorMoonImageView.alpha = 1.0;
                _panSunorMoonImageView.hidden =  NO;
                
                
            }else
            {
                NSLog(@" 开始拖动手势： 起点：日月之外！");
                isFromSunMoonBegin = NO;
            }
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {


            if (isFromSunMoonBegin) {
                
                _panSunorMoonImageView.center = location;
                _panSunorMoonImageView.alpha = 1.0;
                _panSunorMoonImageView.hidden = NO;
                
                if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun.png"]];
                    
                }else
                {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon.png"]];
                    
                }
                [panTracelight setFrame:CGRectMake(location.x, location.y, 15, 15)];
                panTracelight.tag = TAG_LIGHT_TRACE+(++panTraceligntTag);
                panTracelight.contentMode=UIViewContentModeScaleToFill;
                [self.view addSubview:panTracelight];
            }
            
        }
        
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            //是否在头像区
            NSInteger w = _userHeaderImageView.frame.size.width;
            NSInteger h = _userHeaderImageView.frame.size.height;
            CGRect tapRect = CGRectMake(location.x-w/2, location.y-h/2, w, h);
            
            CGRect intersect = CGRectIntersection(_userHeaderImageView.frame, tapRect);
            //同一区域
            if (intersect.size.height>50 || intersect.size.width>50)
            {
                
                NSLog(@" 结束拖动手势： 终点：头像之内！");

                if (isFromSunMoonBegin) {
                    NSLog(@"光被拖回头像！");
                    
                    //收回育成光环，收回动画完成后，开始移动光到头像
                    [self animationForShowBringLightBtnPop:NO];
                    
                    isStartSunOrmoonImageMoveToHeaderAnimation = YES;
                    
                    isFromSunMoonBegin = NO;

                }else{
                    NSLog(@"不是从 日月 开始的！");

                }
                

                
                
            }else
            {
                
                NSLog(@" 结束拖动手势： 终点：头像之外， 回到日月！");
                //需以头像为起点
                if (isFromSunMoonBegin) {
                    
                    //回到日月里动画
                    
                    [self moveLightWithRepeatCount:1 StartPoint:location EndPoint:_skySunorMoonImage.center IsUseRepeatCount:YES];
                    
                    isStartSunOrmoonImageMoveToSunMoonAnimation = YES;

                }else{
                    NSLog(@"不是从 日月 开始的！");
                    
                }
                
                
            }
            
        }


    }else
    {
        //无光在日月中育成，不可以拖动
        
    }
    

    
    //***************************

    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //删除拖动轨迹
        for (NSInteger i=0; i<=panTraceligntTag; i++) {
            UIImageView* tempTrace = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_TRACE+i)];
            tempTrace.hidden = YES;
        }

    }
    
    
    
    [gestureRecognizer setTranslation:location inView:self.view];

    
}



#pragma mark - 计算光的奖励
-(void) caculateAndGiveSunOrMoon
{
    NSTimeInterval time;
    NSDate* startDate;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        time =[[NSDate date] timeIntervalSinceDate:self.userInfo.startBringupSunTime];
        startDate = self.userInfo.startBringupSunTime;

    }else
    {
        time =[[NSDate date] timeIntervalSinceDate:self.userInfo.startBringupMoonTime];
        startDate = self.userInfo.startBringupMoonTime;

    }
    
    if (startDate == 0) {
        NSLog(@"还未育成过!");
        return;
    }
    
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    
    int totalHours = days*24+hours;
    //每3小时奖励一个光
    int giveCount = totalHours / 3;
    [self.userInfo addSunOrMoonValue:giveCount];
    
    
    NSString* timeshow = [NSString stringWithFormat:(@"从%@ 开始育 (%d) 光，养育了%d 小时，奖励 %d 个光"), startDate, [CommonObject checkSunOrMoonTime], totalHours, giveCount];
    NSLog(@"%@", timeshow);
    
//    if (totalHours==0) {
//        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
//        [customAlertAutoDis setAlertMsg:@"Oh,养育时间太短了"];
//        [customAlertAutoDis RunCumstomAlert];
//    
//    }
    
    if (totalHours>0 && totalHours<3) {
        NSString* timeAlert = [NSString stringWithFormat:(@"%@光养育了%d小时, 每3个小时奖励1个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
        [customAlertAutoDis setAlertMsg:timeAlert];
        [customAlertAutoDis RunCumstomAlert];
    }
    
    if (totalHours>3) {
        NSString* timeAlert = [NSString stringWithFormat:(@"%@光养育了%d小时，奖励%d个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours, giveCount,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
        [customAlertAutoDis setAlertMsg:timeAlert];
        [customAlertAutoDis RunCumstomAlert];
    }

    
}

#pragma mark - Animation
-(void) moveLightWithRepeatCount:(NSInteger)repeatCount  StartPoint:(CGPoint) start  EndPoint:(CGPoint) end  IsUseRepeatCount:(BOOL) isUseRepeatCount
{
    NSString* imageName = NULL;
    if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
        imageName = @"sun.png";
        
        if (!isUseRepeatCount) {
            repeatCount = [self.userInfo.sun_value intValue];
        }
        NSLog(@"移动 %d 个阳光", repeatCount);

        
    }else
    {
        imageName = @"moon.png";
        
        if (!isUseRepeatCount) {
            repeatCount = [self.userInfo.moon_value intValue];
        }
        
        NSLog(@"移动 %d 个月光", repeatCount);

        
    }
    _panSunorMoonImageView.image =[UIImage imageNamed:imageName];
    ///[_panSunorMoonImageView setFrame:CGRectMake(start.x, start.y, 30, 30)];
    [_panSunorMoonImageView setCenter:start];
    _panSunorMoonImageView.alpha = 1.0;
    _panSunorMoonImageView.hidden =  YES;
    
    panSunOrMoonlayer.contents=_panSunorMoonImageView.layer.contents;
    panSunOrMoonlayer.frame=_panSunorMoonImageView.frame;
    panSunOrMoonlayer.opacity=1;
    [self.view.layer addSublayer:panSunOrMoonlayer];
    //动画 终点 都以sel.view为参考系
    CGPoint endpoint=[self.view convertPoint:end fromView:nil];
    UIBezierPath *path=[UIBezierPath bezierPath];
    //动画起点
    CGPoint startPoint=[self.view convertPoint:start fromView:nil];
    [path moveToPoint:startPoint];
    //贝塞尔曲线中间点
    float sx=startPoint.x;
    float sy=startPoint.y;
    float ex=endpoint.x;
    float ey=endpoint.y;
    float x=sx+(ex-sx)/3;
    float y=sy+(ey-sy)*0.5-100;
    CGPoint centerPoint=CGPointMake(x,y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration=0.6;
    animation.delegate=self;
    animation.repeatCount = repeatCount;
    animation.repeatDuration = 1;
    animation.autoreverses= NO;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    if (repeatCount>10) {
        animation.repeatDuration = 5*0.6;
        
    }
    [panSunOrMoonlayer addAnimation:animation forKey:@"moveLight"];
 
    
    /*
    bringupImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    //bringupImageView.frame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 30, 30);
    //无法隐藏，暂放到-100
    bringupImageView.frame = CGRectMake(-100,-100, 30, 30);
    bringupImageView.alpha = 1.0;
    //bringupImageView.hidden = NO;
    //[self.view addSubview:bringupImageView];
    
    
    
    ///*
    CALayer *layer=[[CALayer alloc]init];
    layer.contents=bringupImageView.layer.contents;
    layer.frame=bringupImageView.frame;
    layer.opacity=1;
    [self.view.layer addSublayer:layer];
    //动画 终点 都以sel.view为参考系
    CGPoint endpoint=[self.view convertPoint:_userHeaderImageView.center fromView:nil];
    UIBezierPath *path=[UIBezierPath bezierPath];
    //动画起点
    CGPoint point = CGPointMake(_skySunorMoonImage.center.x,_skySunorMoonImage.center.y);
    CGPoint startPoint=[self.view convertPoint:point fromView:nil];
    [path moveToPoint:startPoint];
    //贝塞尔曲线中间点
    float sx=startPoint.x;
    float sy=startPoint.y;
    float ex=endpoint.x;
    float ey=endpoint.y;
    float x=sx+(ex-sx)/3+10;
    float y=sy+(ey-sy)*0.5-200;
    CGPoint centerPoint=CGPointMake(x,y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.duration=0.8;
    animation.delegate=self;
    animation.repeatCount = repeatCount;
    animation.repeatDuration = 1;
    animation.autoreverses= NO;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    if (repeatCount>10) {
        animation.repeatDuration = 5;

    }
    
    [layer addAnimation:animation forKey:@"addvalue"];
    //*/
    
    //[addAmin setAnimationDidStopSelector:@selector(goPutThemBack:finished:context:)];
}

- (void)goPutThemBack:(NSString *)animationID finished:(NSNumber *)finished context:(id )context
{
    NSLog(@"00000---goPutThemBack");
    UIImageView *dollarView2 = (UIImageView *)context;
    [dollarView2 removeFromSuperview];
}


- (void)animationDidStart:(CAAnimation *)anim
{
    if (isStartSunOrmoonImageMoveToHeaderAnimation) {
    
        [self animationBowLightFrameHeaderView:1];
    
    }
    
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value=[(CAKeyframeAnimation*)anim valueForKey:@"position"];
    NSLog(@"animationDidStop----%@",value);
    
    if (isStartSunOrmoonImageMoveToHeaderAnimation) {
        
        //删除拖动动画图层
        [panSunOrMoonlayer removeFromSuperlayer];
        
        _panSunorMoonImageView.hidden = YES;

        isStartSunOrmoonImageMoveToHeaderAnimation = NO;
        
        //完成移动动画后，开启头像动画
        if ([self.userInfo checkIsBringUpinSunOrMoon]==NO) {
      
            if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
            }else
            {
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
                
            }
            
            NSLog(@"停止 日月 动画！");
            [lightSkySunOrMoonView stopAnimating];
        }
        
        
        for (int i = 0; i<panTraceligntTag; i++) {
            panTracelight = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_TRACE+i)];
            panTracelight.hidden =YES;
        }
        
        //如果是进入小屋触发的动画，则完成时进入小屋
        if (isGetinToHome) {
            [self performSegueWithIdentifier:@"getintoHome" sender:nil];
        }

        
    }
    
    if (isStartSunOrmoonImageMoveToSunMoonAnimation) {
        //删除拖动动画图层
        [panSunOrMoonlayer removeFromSuperlayer];
        
        _panSunorMoonImageView.hidden = YES;

        //弹出育成光环
        [self animationForShowBringLightBtnPop:YES];
        
        isStartSunOrmoonImageMoveToSunMoonAnimation = NO;
        
        if ([self.userInfo checkIsBringUpinSunOrMoon]==YES) {
            //开启日月动画
            if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
                
                [self animationLightFrameSkySunOrMoon:7];
            }else
            {
                
                [self animationLightFrameSkySunOrMoon:7];
                
            }
            
            NSLog(@"停止 头像 动画！");
            //最多7个动画光环
            
            for (int i =0; i<7; i++) {
                UIImageView* lightUserHeaderTag = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
                lightUserHeaderTag.hidden = YES;
                [lightUserHeaderTag stopAnimating];
            }
        }

        
    }
    


}


//增加彩虹
-(void) animationRainbow:(NSInteger) count
{
    for (int i=0; i<count; i++) {
        //向上累加彩虹
        UIImage* rainBow = [UIImage imageNamed:@"rainBow.png"];
        NSInteger rainBowImageWidth = SCREEN_WIDTH;
        NSInteger rainBowImageHeight = 60;
        UIImageView* rainBowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - rainBowImageHeight*i+1, rainBowImageWidth, rainBowImageHeight)];
        rainBowView.image = rainBow;
        [self.view addSubview:rainBowView];

    }
    
}

//头像爆闪
-(void) animationBowLightFrameHeaderView:(NSInteger) repeatCout
{
    
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];

    
    for (int i=0; i<3; i++) {
        
        NSString *name=[NSString stringWithFormat:@"headerFrameBow_%d",i];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];
        
    }
    
    lightBowSkyUserHeaderView.animationImages=iArr;
    lightBowSkyUserHeaderView.animationDuration=1;
    lightBowSkyUserHeaderView.animationRepeatCount = repeatCout;
    [lightBowSkyUserHeaderView startAnimating];
    
}


-(void) animationLightFrameHeaderViewSetRange:(NSInteger) range isUseSetRange:(BOOL) isOrNo
{
 
    NSInteger realRange;
    if (isOrNo) {
        realRange = range;
    }else
    {
        
        if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
            realRange = [self.userInfo.sun_value intValue];
        }else
        {
            realRange = [self.userInfo.moon_value intValue];
        }
        
    }
    

    NSLog(@"开启头像闪烁动画, range=%d！", realRange);
    
    NSInteger bigRang = realRange/7+1;
    NSInteger smallRang = realRange%7;
    
    NSInteger rainBowCount = bigRang/7;
    if (rainBowCount>=1) {
        NSLog(@"超过7个光环，增加彩虹！");
        for (int i = 0; i<rainBowCount; i++) {
            [self animationRainbow:rainBowCount];

        }
    }

  
    //NSInteger everyBigRangWidth = 10;
    for (int i = 0; i<bigRang; i++) {
        NSMutableArray *iArr= NULL;
        if (i == bigRang-1) {
            //最后一级，画小光环
            iArr = [self makeSmallRangAnimationSevenLightForHeaderView:smallRang];
        }else
        {
            //前几级，为满级光环
            iArr = [self makeSmallRangAnimationSevenLightForHeaderView:7];
        }
        

        
        UIImageView* lightUserHeaderTag = (UIImageView* )[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
        lightUserHeaderTag.hidden = NO;
        lightUserHeaderTag.animationImages=iArr;
        
        
        NSInteger IntervalWidth = LIGHT_ANIMATION_INTERVAL;// 光环向头像外扩的宽度
        NSInteger lightBowSkyUserHeaderViewWidth;
        NSInteger lightBowSkyUserHeaderViewHeigth;
        if (i==0) {
            lightBowSkyUserHeaderViewWidth = _userHeaderImageView.frame.size.width+56;
            lightBowSkyUserHeaderViewHeigth = _userHeaderImageView.frame.size.height+56;
        }else
        {
            lightBowSkyUserHeaderViewWidth = _userHeaderImageView.frame.size.width+IntervalWidth*2;
            lightBowSkyUserHeaderViewHeigth = _userHeaderImageView.frame.size.height+IntervalWidth*2;
        }

        [lightUserHeaderTag setFrame:CGRectMake(_userHeaderImageView.center.x-lightBowSkyUserHeaderViewWidth/2, _userHeaderImageView.center.y-lightBowSkyUserHeaderViewHeigth/2, lightBowSkyUserHeaderViewWidth, lightBowSkyUserHeaderViewHeigth)];
        lightUserHeaderTag.animationDuration=1;
        [self.view insertSubview:lightUserHeaderTag belowSubview:_userHeaderImageView];
        [lightUserHeaderTag startAnimating];
        
    }

}


-(NSMutableArray*) makeSmallRangAnimationSevenLightForHeaderView:(NSInteger) smallRang
{
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    
    //NSInteger everyBigRangWidth = 20;//每一级光环的宽

        
    for (int j=0; j<smallRang; j++) {
        NSString *name=[NSString stringWithFormat:@"headerFrame_%d",j];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];

    }
    
    return iArr;
}


//太阳，月亮闪烁，提示有光在育成
-(void) animationLightFrameSkySunOrMoon:(NSInteger) range
{
    NSLog(@"开启日月闪烁！");

    
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<range; i++) {
        NSString *name=[NSString stringWithFormat:@"headerFrame_%d",i];
        UIImage *image=[UIImage imageNamed:name];
        [iArr addObject:image];
    }
    
    lightSkySunOrMoonView.animationImages=iArr;
    lightSkySunOrMoonView.animationDuration=2;
    [lightSkySunOrMoonView startAnimating];
    
}




- (void)drawImageForGestureRecognizer:(UIGestureRecognizer *)recognizer
                              atPoint:(CGPoint)centerPoint underAdditionalSituation:(NSString *)addtionalSituation{
    
	NSString *imageName;
   if ([recognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        imageName = @"pan.gif";
    }

}


- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"-MainSunMoonViewController----ReceiveMemoryWarning!");
}

#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"userSet"]) {

        UserSetViewController *destinationVC = (UserSetViewController *)segue.destinationViewController;
        destinationVC.title = @"119";
        //destinationVC.navigationItem.title = @"438";
        //destinationVC.navigationController.navigationBarHidden = NO;

    }
    
    if ([[segue identifier] isEqualToString:@"getintoHome"]){
        
        HomeInsideViewController *destinationVC = (HomeInsideViewController *)segue.destinationViewController;
        destinationVC.user = self.userInfo;
        
    }
    

}



- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    page1.titleImage = [UIImage imageNamed:@"Guid-start"];
    
    
    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1]];
    
    [intro setDelegate:self];
    //[intro showInView:self.view animateDuration:0.0];
    [self.view addSubview:intro];
    
}


- (void)introDidFinish
{

    //引导完成的第一次起动处理
    [self whenFirstlyOpenViewHandle];
}



-(void) saveUserDataFromCamera:(NSDictionary*)imageData
{
    
    //voice name有固定格式，不用存
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        userInfo.date_time = [imageData objectForKey:CAMERA_TIME_KEY];
        userInfo.sun_value = [self.userInfo getMaxUserSunValue];
        userInfo.sun_image = UIImagePNGRepresentation([imageData objectForKey:CAMERA_IMAGE_KEY]);
        userInfo.sun_image_sentence = [imageData objectForKey:CAMERA_SENTENCE_KEY];
        userInfo.sun_image_name = [imageData objectForKey:CAMERA_TIME_KEY];
    }else if ([CommonObject checkSunOrMoonTime] == IS_MOON_TIME)
    {
        userInfo.date_time = [imageData objectForKey:CAMERA_TIME_KEY];
        userInfo.moon_value = [self.userInfo getMaxUserMoonValue];
        userInfo.moon_image = UIImagePNGRepresentation([imageData objectForKey:CAMERA_IMAGE_KEY]);
        userInfo.moon_image_sentence = [imageData objectForKey:CAMERA_SENTENCE_KEY];
        userInfo.moon_image_name = [imageData objectForKey:CAMERA_TIME_KEY];
        
    }

    [self.userInfo saveUserCheckByDataTime:userInfo];
    
    
}




#pragma mark - UserInfoCloudDelegate
- (void) getUserInfoFinishReturn:(UserInfo*) userInfo
{
    
    
}



#pragma mark - 编辑用户头像 或 进入小屋
-(void)handleTapUserHeader
{
    if (self.userInfo.userType == USER_TYPE_NEW || (self.userInfo.userType == USER_TYPE_NEED_CARE && [self.userHeaderImageView isEqual:[UIImage imageNamed:@"默认头像.png"]])) {
        [self.userInfo updateUserType:USER_TYPE_TYE];
        [self editUserHeader];
    }else
    {
        //进入小屋,先收回的育成才能进入
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            [self animationForShowBringLightBtnPop:NO];
            isGetinToHome =  YES;
            //待完成收回动画后，再进入小屋
        }else
        {
            [self performSegueWithIdentifier:@"getintoHome" sender:nil];

        }
        

        
        
   
    }
    
    
}

//弹出选择编辑按钮
- (void)editUserHeader {
    
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:@"请选择头像"
                                                             delegate:self
                                                    cancelButtonTitle:@"下次再说"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    
    if ([actionSheet.title isEqualToString:@"请选择头像"]) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }else
        {
            
            //进入小屋,先收回的育成才能进入
            if ([self.userInfo checkIsBringUpinSunOrMoon]) {
                [self animationForShowBringLightBtnPop:NO];
                isGetinToHome =  YES;
                //待完成收回动画后，再进入小屋
            }else
            {
                [self performSegueWithIdentifier:@"getintoHome" sender:nil];
                
            }

        }
    }
    

}


#pragma mark - UIImagePickerControllerDelegate
//相机或相册的回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - VPImageCropperDelegate
//实现委托函数
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.userHeaderImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        [self.userInfo updateUserHeaderImage:editedImage];
        [self.userInfo updateUserType:USER_TYPE_TYE];

    
    }];
}
//实现委托函数
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    //开辟新的画图区
    UIGraphicsBeginImageContext(targetSize); // this will crop
    //清0
    CGRect thumbnailRect = CGRectZero;
    //定义大小
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    //把源图画到指定位置和大小上
    [sourceImage drawInRect:thumbnailRect];
    //取画好的图
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark - 测试数据

- (IBAction)reCreatDataBase:(id)sender
{
    [userDB deleteDataBaseFile];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[userDB getDBPath]];
    NSLog(@"db path=%@", [userDB getDBPath]);
    if(exist)
    {
        NSLog(@"删除数据库文件失败！！");
    }else{
        NSLog(@"删除数据库文件成功！");
        
    }
    
    userDB = [[UserDB alloc] init];
    [userDB createDataBase];

}

- (IBAction)deleteDataBase:(id)sender {
    
    [userDB deleteDataBaseFile];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[userDB getDBPath]];
    NSLog(@"db path=%@", [userDB getDBPath]);
    if(exist)
    {
        NSLog(@"删除数据库文件失败！！");
    }else{
        NSLog(@"删除数据库文件成功！");
        
    }
    
    
    
}

#pragma mark  - ------测试-------
- (IBAction)testNet:(id)sender {
    
    [_userCloud updateUserImage:Nil];
    
    [_userCloud upateUserInfo:userInfo];
    
    
    /*
     UserInfo * user = [UserInfo new];
     user.name = @"xujun";
     user.user_id = @"001";
     user.sns_id = @"12345";
     user.sun_value = @"11";
     //user.sun_image = UIImagePNGRepresentation(image);
     
     [_userDB saveUser:user];
     
     //test 取数据
     _userData = [NSMutableArray arrayWithArray:[_userDB findWithUid:nil limit:10000]];
     
     
     
     //    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
     //    NSString* _name = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@",@"UserSunMoonDB.sqlite"]];
     //    NSLog(@"*****%@", _name);
     //
     //    NSLog(@"-----***%@", [_userDB getDBPath]);
     
     
     
     //云上传数据
     if ([_userCloud upateUserInfo:user]) {
     
     NSLog(@"Update cloud userinfo succeed!");
     
     }else
     {
     NSLog(@"Update cloud userinfo failed!");
     
     }
     
     
     [_userCloud getUserInfoBySnsId:user.sns_id userName:user.name];
     
     */
}

@end
