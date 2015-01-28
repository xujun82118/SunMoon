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
#import "AminationCustom.h"


#define KEY_IS_GIVE_FIRST_LIGHT       @"reminderGiveFirstLight"
#define KEY_REMINDER_PAN_FOR_LIGHT    @"reminderPanForLight"
#define KEY_REMINDER_GETINTO_CAMERA    @"reminderGetIntoCamera"
#define KEY_REMINDER_PHOTO_COUNT_OVER  @"reminderPhotoCountOver"
#define KEY_REMINDER_SUCC_GET_LIGHT    @"reminderSuccGetLight"
#define KEY_REMINDER_GIVE_LIGHT        @"reminderGiveLight"

//控制在秒内全部释放完成，2秒内完成
#define POP_OUT_ALL_LIGHT_TIME  1
#define POP_OUT_ANIMATION_LIGHT_TIME  3
//左右摆动的时间
#define SWIM_AROUND_LIGHT_TIME  2
//延迟一定时间才能召回，要等动画完成定位后,包括释放动画，摇摆动画(距离较小，不计)
#define DELAY_TIME_FOR_POP_BACK 1//召回所有的光的时间
#define POP_BACK_ALL_LIGHT_TIME  3
#define POP_BACK_ANIMATION_LIGHT_TIME  2


//左右摆动的距离
#define SWIM_AROUND_LIGHT_DISTANCE  10


@interface MainSunMoonViewController ()
{
    GuidController* guidInfo;
    
    BOOL  isHaveFirstlyOpen; //第一次登录
    //BOOL  isHaveOpenUI;  //第一次打开主界面，用于区分第一次登录，和第一次打开主界面
    
    BOOL  isGiveFirstLight;
    
    EAIntroView *intro ;
    
    BOOL  isFromHeaderBegin;
    BOOL  isFromSunMoonBegin;
    UIImageView*  lightSkySunOrMoonView; //太阳或月亮闪烁动画View
    UIImageView*  lightBowSkyUserHeaderView; //头像爆闪烁动画View
    UIImageView* lightUserHeader;//头像闪烁动画View, 7个闪烁光环
    UIImageView* panTracelight;  //拖动轨迹
    NSInteger  panTraceligntTag; //拖动轨迹的TAG
    CALayer *panBackSunOrMoonlayer;  //拖动后，弹回的动画图层
    
    UIPanGestureRecognizer *panSunOrMoonGusture;  //拖动动画识别
    UITapGestureRecognizer *tapSunOrMoonGusture; //点击太阳的识别
    UITapGestureRecognizer *tapHeaderView;
    
    
    UIImageView* swimTracelight;  //游动的光
    NSMutableArray * swimTracelightArray;
    NSInteger  swimTraceligntTag; //游动的光的TAG
    CALayer *swimBackSunOrMoonlayer;  //游动的光的，弹回的动画图层
    
    BOOL isStartSunOrmoonImageMoveToHeaderAnimation;//起动了向头像移动光的动画
    BOOL isStartSunOrmoonImageMoveToSunMoonAnimation;//起动了向日月移动光的动画
    
    BOOL isPopOutIntoCameraBtn;  //是否已弹出
    BOOL isPopOutShowBringLightBtn;
    
    NSInteger giveLingtCout; //奖励光的个数
    
    BOOL isGetinToHome; //是进入小屋的点击
    
    CGRect srcIntoCameraBtnFrame ;
    CGPoint srcIntoCameraBtnCenter;
    CGRect destIntoCameraBtnFrame ;
    CGPoint destIntoCameraBtnCenter;

    
    CGRect srcShowBringLightBtnFrame;
    CGRect destShowBringLightBtnFrame;
    
    
    CGRect jumpSmallShowBringLightBtnFrame;
    BOOL  startJump;
    NSTimer*  JumpTimer;
    
    UIImageView* bowLightView; //日月闪爆闪
    UIImageView* bowLightBringView; //育成光爆闪
    
    CustomAlertView* customAlertAutoDis;
    CustomAlertView* customAlertAutoDisYes;
    
    UIImageView* userHeaderline; //头像的横线
    
    CGAffineTransform inToCameraBtnTransform;
    
    BOOL needStopIntoCamera; //用于停止IntoCamera的动画
    
    AminationCustom* addVauleAnimation;
    CustomAnimation* simOutAnimation;
    NSMutableArray*  simOutAnimationArray;
    NSMutableArray*  simOutRedImageViewArray; //红精灵组
    NSMutableArray*  simOutBlueImageViewArray; //蓝精灵组
    NSTimer* swimAroundTimer; //随进四处游荡timer

    NSInteger repeatCount;
    
    
    NSDictionary * lightTypeCountInfo;
}

@end

@implementation MainSunMoonViewController

@synthesize intoCameraBtn=_intoCameraBtn,mainBgImage,menuBtn,userInfo,userDB,userHeaderImageView = _userHeaderImageView;
@synthesize skySunorMoonImage =_skySunorMoonImage,panSunorMoonImageView =_panSunorMoonImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"---->viewDidLoad");

	// Do any additional setup after loading the view, typically from a nib.
    
    //注册本地通知
    NSNotificationCenter  * notificationCenter = [ NSNotificationCenter  defaultCenter];
    [notificationCenter removeObserver:self name:NOTIFY_LOCAL_NEED_CHANGE_UI object:nil];
    [notificationCenter addObserver: self  selector:@selector (reFreshSunOrMoonUI:) name:NOTIFY_LOCAL_NEED_CHANGE_UI  object:nil];

    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    //isHaveOpenUI = [userBaseData boolForKey:@"isHaveOpenUI"];
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
        
        //[guidInfo updateFirstlyOpenGuidCtl:YES];

    }else
    {
        NSLog(@"Opened normally!");
        self.userInfo = [self.userInfo getUserInfoAtNormalOpen];
        
    }

    //获取同一个数据库，注：userDB不能放到userInfo中，会发生错误，原因不明
    userDB = [[UserDB alloc] init];
    
    NSLog(@"db path=%@", [userDB getDBPath]);

    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    //选择背景时间与日月图片等
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        [mainBgImage setImage:[UIImage imageNamed:@"主页底图004.png"]];
        [_skySunorMoonImage setImage:[UIImage imageNamed:@"sun.png"]];

        
    }else
    {
        [mainBgImage setImage:[UIImage imageNamed:@"moon-home.png"]];
        [_skySunorMoonImage setImage:[UIImage imageNamed:@"moon.png"]];


    }
    
    //起动时间监视
    [self startAlertTimerForSunMoonTime];
    
    //加载头像
    NSInteger wHeader = SCREEN_WIDTH/3;
    NSInteger hHeader = wHeader;
    NSInteger xHeader = SCREEN_WIDTH/2 - wHeader/2;
    NSInteger yHeadr  = SCREEN_HEIGHT - 50 - hHeader;
    if (!_userHeaderImageView) {
        _userHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xHeader, yHeadr, wHeader, hHeader)];
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
            _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
        }else
        {
            _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
            
        }
        _userHeaderImageView.layer.borderWidth = 3.5f;
        _userHeaderImageView.userInteractionEnabled = YES;
        _userHeaderImageView.backgroundColor = [UIColor blackColor];
        tapHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapUserHeader:)];
        tapHeaderView.numberOfTouchesRequired = 1;
        tapHeaderView.numberOfTapsRequired = 1;
        _userHeaderImageView.userInteractionEnabled = YES;
        [_userHeaderImageView addGestureRecognizer:tapHeaderView];
        [self.view addSubview:_userHeaderImageView];
        
    }
    
    self.userHeaderImageView.image = self.userInfo.userHeaderImage;
    
    
    addVauleAnimation = [[AminationCustom alloc] initWithKey:@"addValueinEdite"];
    addVauleAnimation.aminationCustomDelegate =  self;
    
    

}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"---->viewWillAppear");




    //重取一次数
    [self.userInfo  getUserCommonData];

    self.navigationController.navigationBarHidden = YES;

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"---->viewDidAppear");

    
    
    needStopIntoCamera = FALSE;

    //检查日月时间是否变化
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    if (![userBaseData objectForKey:KEY_BACK_GROUND_TIME]) {
        [userBaseData setObject:[CommonObject getCurrentDate] forKey:KEY_BACK_GROUND_TIME];
        [userBaseData synchronize];
    }
    if (![userBaseData objectForKey:KEY_BACK_GROUND_TIME_SUNMOON]) {
        [userBaseData setInteger:[CommonObject checkSunOrMoonTime] forKey:KEY_BACK_GROUND_TIME_SUNMOON];
        [userBaseData synchronize];
    }
    
    //上次回到后台的时间不是今天, 或早上晚上已变化
    if (![[CommonObject getCurrentDate] isEqualToString:[userBaseData objectForKey:KEY_BACK_GROUND_TIME]] || [CommonObject checkSunOrMoonTime] != [userBaseData integerForKey:KEY_BACK_GROUND_TIME_SUNMOON])
        
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCAL_NEED_CHANGE_UI object:self];
    }


    
    //创建拖动轨迹识别
    panSunOrMoonGusture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePanSunOrMoon:)];
    [self.view addGestureRecognizer:panSunOrMoonGusture];
    
    //拖动动画图层
    panBackSunOrMoonlayer=[[CALayer alloc]init];
    
    
    
    //初始化头像闪烁动画图
    for (int i=0 ; i<7; i++) {
         lightUserHeader = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
        
        if (!lightUserHeader) {
            lightUserHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"空白图.png"]];
            lightUserHeader.tag = TAG_LIGHT_USER_HEADER+i;
            lightUserHeader.userInteractionEnabled=YES;
            lightUserHeader.contentMode=UIViewContentModeScaleToFill;
            lightUserHeader.hidden = YES;
            [self.view addSubview:lightUserHeader];
        }
        
    }
    
    
    //增加点击识别，进入拍照，或回归光到头像, 拖动也可让光回到头像
    //只设置点击 闪烁功能
    tapSunOrMoonGusture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSkySumOrMoonhandle:)];
    tapSunOrMoonGusture.numberOfTouchesRequired = 1;
    tapSunOrMoonGusture.numberOfTapsRequired = 1;
    _skySunorMoonImage.userInteractionEnabled = YES;
    [_skySunorMoonImage addGestureRecognizer:tapSunOrMoonGusture];
    

    
    //定位camera button
//    NSInteger inTocameraBtnWidth = SCREEN_WIDTH/3;
//    NSInteger inTocameraBtnHeight = inTocameraBtnWidth;
//    srcIntoCameraBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
//    destIntoCameraBtnFrame = CGRectMake(20,_skySunorMoonImage.center.y+inTocameraBtnHeight/5*1, inTocameraBtnWidth,inTocameraBtnHeight);
//    srcIntoCameraBtnCenter =  _skySunorMoonImage.center;
//    destIntoCameraBtnCenter = CGPointMake(destIntoCameraBtnFrame.origin.x+destIntoCameraBtnFrame.size.width/2, destIntoCameraBtnFrame.origin.y+destIntoCameraBtnFrame.size.height/2);
//    //[_intoCameraBtn setFrame:srcIntoCameraBtnFrame];
//    //[_intoCameraBtn setCenter:srcIntoCameraBtnCenter];
//    [_intoCameraBtn setTag:TAG_INTO_CAMERA_BTN];

    
    
    //定位养育光环
//    NSInteger bringLightBtnWidth = SCREEN_WIDTH/3;
//    NSInteger bringLightBtnHeight = bringLightBtnWidth;
//    srcShowBringLightBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
//    destShowBringLightBtnFrame = CGRectMake(SCREEN_WIDTH-bringLightBtnWidth-20,_skySunorMoonImage.center.y+bringLightBtnHeight/5*1, bringLightBtnWidth, bringLightBtnHeight);
//    [_showBringLightBtn setFrame:srcShowBringLightBtnFrame];
//    [_showBringLightBtn setTag:TAG_BRING_LING_BTN];

    
//    NSInteger bringLightJumpWidth = bringLightBtnWidth/3;
//    NSInteger bringLightJumpHeight = bringLightBtnHeight/3;
//    jumpSmallShowBringLightBtnFrame = CGRectMake(destShowBringLightBtnFrame.origin.x+(bringLightBtnWidth-bringLightJumpWidth)/2,destShowBringLightBtnFrame.origin.y+(bringLightBtnHeight-bringLightJumpHeight)/2, bringLightJumpWidth, bringLightJumpHeight);
    

    //isPopOutIntoCameraBtn = NO;
    //isPopOutShowBringLightBtn = NO;
    
    
    //初始化弹出按钮, 位置在太阳月亮中, 是否有光在育成
//    NSInteger inTocameraBtnWidth = SCREEN_WIDTH/3;
//    NSInteger inTocameraBtnHeight = inTocameraBtnWidth;
//    srcIntoCameraBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
////    NSLog(@"viewDidAppear---%f, %f, %f, %f ",srcIntoCameraBtnFrame.origin.x, srcIntoCameraBtnFrame.origin.y, srcIntoCameraBtnFrame.size.width,srcIntoCameraBtnFrame.size.height);
//    destIntoCameraBtnFrame = CGRectMake(20,_skySunorMoonImage.center.y+inTocameraBtnHeight/5*1, inTocameraBtnWidth,inTocameraBtnHeight);
////    NSLog(@"viewDidAppear---%f, %f, %f, %f ",destIntoCameraBtnFrame.origin.x, destIntoCameraBtnFrame.origin.y, destIntoCameraBtnFrame.size.width,destIntoCameraBtnFrame.size.height);
    
//    NSInteger bringLightBtnWidth = SCREEN_WIDTH/3;
//    NSInteger bringLightBtnHeight = bringLightBtnWidth;
//    srcShowBringLightBtnFrame = CGRectMake(_skySunorMoonImage.center.x, _skySunorMoonImage.center.y, 0,0);
//    destShowBringLightBtnFrame = CGRectMake(SCREEN_WIDTH-bringLightBtnWidth-20,_skySunorMoonImage.center.y+bringLightBtnHeight/5*1, bringLightBtnWidth, bringLightBtnHeight);
//    
//    NSInteger bringLightJumpWidth = bringLightBtnWidth/3;
//    NSInteger bringLightJumpHeight = bringLightBtnHeight/3;
//    jumpSmallShowBringLightBtnFrame = CGRectMake(destShowBringLightBtnFrame.origin.x+(bringLightBtnWidth-bringLightJumpWidth)/2,destShowBringLightBtnFrame.origin.y+(bringLightBtnHeight-bringLightJumpHeight)/2, bringLightJumpWidth, bringLightJumpHeight);
//    
    
//    if (!_intoCameraBtn ) {
//        _intoCameraBtn = [[UIButton alloc] initWithFrame:srcIntoCameraBtnFrame];
//        [_intoCameraBtn addTarget:self action:@selector(intoCamera:) forControlEvents:UIControlEventTouchUpInside];
//        [_intoCameraBtn setTag:TAG_INTO_CAMERA_BTN];
//        [self.view addSubview:_intoCameraBtn];
//        
//        NSLog(@"viewDidAppear--now-3-alloc-%f, %f, %f, %f ",_intoCameraBtn.frame.origin.x, _intoCameraBtn.frame.origin.y, _intoCameraBtn.frame.size.width,_intoCameraBtn.frame.size.height);
//
//    }



    
//    if (!_showBringLightBtn) {
//        _showBringLightBtn = [[UIButton alloc] initWithFrame:srcShowBringLightBtnFrame];
//        [_showBringLightBtn addTarget:self action:@selector(getBringedUpLight:) forControlEvents:UIControlEventTouchUpInside];
//        [_showBringLightBtn setTag:TAG_BRING_LING_BTN];
//        [self.view addSubview:_showBringLightBtn];
//
//    }
    



     
    //初始化日月动画图
    //不能放到veiwDidload 和viewWillapear中
    NSInteger IntervalWidth = 5;// 光环向日月外扩的宽度,日月的光晕较大
    NSInteger lightSkySunOrMoonViewWidth = _skySunorMoonImage.frame.size.width+IntervalWidth*2;
    NSInteger lightSkySunOrMoonViewHeigth = _skySunorMoonImage.frame.size.height+IntervalWidth*2;
    if (!lightSkySunOrMoonView) {
        lightSkySunOrMoonView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"空白图"]];
        lightSkySunOrMoonView.userInteractionEnabled=YES;
        lightSkySunOrMoonView.contentMode=UIViewContentModeScaleToFill;

        [lightSkySunOrMoonView setFrame:CGRectMake(_skySunorMoonImage.center.x-lightSkySunOrMoonViewWidth/2, _skySunorMoonImage.center.y-lightSkySunOrMoonViewHeigth/2, lightSkySunOrMoonViewWidth, lightSkySunOrMoonViewHeigth)];
        
        
        [self.view addSubview:lightSkySunOrMoonView];
    }

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
    
    

    
    //初始化头像爆闪动画图
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
    
//    WeatherLoc* testWeather = [[WeatherLoc alloc] init];
//    [testWeather startGetWeather];
//    [testWeather startGetWeatherSimple];
    

    //引导结束，执行一般打开状态
    if (guidInfo.guidStepNumber >guidStep_mainView_End)
    {
        [self whenCommonOpenViewHandle];
    }
    
    
    //始终保持两控件在最上面
    [self.view bringSubviewToFront:_intoCameraBtn];
    [self.view bringSubviewToFront:menuBtn];
    
    
    
    //起动引导滑屏
    [self  HandleGuidProcess:guid_Start];



}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    

    needStopIntoCamera = TRUE;

    
    //记录离开主界面时间，防止回来时，日月时间变化
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:[CommonObject getCurrentDate] forKey:KEY_BACK_GROUND_TIME];
    [userBaseData setInteger:[CommonObject checkSunOrMoonTime] forKey:KEY_BACK_GROUND_TIME_SUNMOON];
    [userBaseData synchronize];
    
}


-(void)whenFirstlyOpenViewHandle
{

    //第一次打开，奖励一个光值
    [self.userInfo  addSunOrMoonValue:1];
    [self.userInfo updateisBringUpSunOrMoon:YES];
    isGiveFirstLight = YES;//later

    
    //启动第一个光的引导
    [self HandleGuidProcess:giudStep_guidFirstlyGiveLight];


    //更新光育成时间
    [self.userInfo updateSunorMoonBringupTime:[NSDate date]];

    NSLog(@"等待点击光环。。");
    
}

-(void)whenCommonOpenViewHandle
{
    //判断是否是新登录, 新登录，连续登录值置为1， 连续登录，连续值加1
    //连续登录可得阳光，月光值1个
    if (![self.userInfo checkLoginLastDateIsToday])
    {
        NSLog(@"当天新登录,更新当天照片未加光值");
        [self.userInfo updateIsHaveAddSunValueForTodayPhoto:NO];
        [self.userInfo updateIsHaveAddMoonValueForTodayPhoto:NO];
        [self refreshIntoCameraBtnState];

        NSLog(@"当天新登录，判断是否连续登录？");
        
        if ([self.userInfo checkLoginLastDateIsYesterday])
        {
            NSLog(@"昨天刚登录过，是连续登录, 连续值+1！");
            [self.userInfo addContinueLogInCount];
            
            //连续登录，阳光月光+1
            [self.userInfo addSunOrMoonValue:1];
            
            //奖励提示
            giveLingtCout = 1;
            

            if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                [self showCustomYesAlertSuperView:@"阳光时间连续登录，奖励一个阳光"  AlertKey:KEY_REMINDER_GIVE_LIGHT];

            }else
            {
                [self showCustomYesAlertSuperView:@"月光时间连续登录，奖励一个月光"  AlertKey:KEY_REMINDER_GIVE_LIGHT];

            }
            
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
    if ([self.userInfo.sun_value intValue] !=0 || [self.userInfo.moon_value intValue]!=0)
    {
        
        
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            //有则，闪烁
            [self animationLightFrameSkySunOrMoon:7];
            NSLog(@"有光在育成， 闪烁。。");


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
    

    
    
    //更新状态,必须在处理登录判定后
    [self refreshIntoCameraBtnState];
    
    
}

#pragma mark - 检查是否要奖励光的动画
-(void) animationGiveLightCout:(NSInteger) count
{
    
    [addVauleAnimation setStartPoint:_intoCameraBtn.center];
    [addVauleAnimation setEndpoint:_skySunorMoonImage.center];
    [addVauleAnimation setUseRepeatCount:giveLingtCout];
    [addVauleAnimation setBkView:self.view];
    [addVauleAnimation setImageName:[CommonObject getUsedSamllLightImageNameByTime]];
    [addVauleAnimation setAminationImageViewframe:CGRectMake(_intoCameraBtn.frame.origin.x, _intoCameraBtn.frame.origin.y, 60, 60)];
    [addVauleAnimation moveLightWithIsUseRepeatCount:YES];
    

    
}
#pragma mark - AminationCustomDelegate

- (void) animationFinishedRuturn:(NSString*) aniKey aniView:(UIImageView*) aniView
{
    if ([aniKey isEqualToString:@"simOutAnimation"]) {
        
    }
    
}

//
//#pragma mark -  弹出动画
//-(void) animationForIntoCameraBtnPop:(BOOL)isPop
//{
//    
//    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
//        
//        if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
//            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun.png"] forState:UIControlStateNormal];
//            
//            
//        }else
//        {
//            
//            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-sun-点.png"] forState:UIControlStateNormal];
//        }
//        
//        
//    }else
//    {
//        
//        if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
//            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon.png"] forState:UIControlStateNormal];
//        }else
//        {
//            
//            [_intoCameraBtn setImage:[UIImage imageNamed:@"拍照环-moon-点.png"] forState:UIControlStateNormal];
//        }
//        
//    }
//    
//    
//    if (isPop) {
//        
//        [UIView beginAnimations:@"popOut_IntoCameraBtn" context:Nil];
//
//        [UIView setAnimationDuration:0.7f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
//        NSLog(@"popOut IntoCameraBtn!");
//        [UIView setAnimationBeginsFromCurrentState:YES];
//
//        [_intoCameraBtn setFrame:destIntoCameraBtnFrame];
//        [_intoCameraBtn setCenter:destIntoCameraBtnCenter];
//
//        
//        [UIView commitAnimations];
//
//        isPopOutIntoCameraBtn = YES;
//        
//    }else
//    {
//        [UIView beginAnimations:@"popBack_IntoCameraBtn" context:Nil];
//        [UIView setAnimationDuration:0.7f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationPopOut:finished:context:)];
//        [UIView setAnimationBeginsFromCurrentState:YES];
//
//
//        
//        NSLog(@"popBack IntoCameraBtn!");
//
//        [_intoCameraBtn setFrame:srcIntoCameraBtnFrame];
//        
//        
//        
//        [UIView commitAnimations];
//        isPopOutIntoCameraBtn = NO;
//    }
//    
//}
//


#pragma mark - 更新状态
-(void) refreshIntoCameraBtnState
{
    
    [_intoCameraBtn setImage:[UIImage imageNamed:[CommonObject getUsedSamllLightImageNameByTime]] forState:UIControlStateNormal];
    
    if (![self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
        
        NSLog(@"今天未得到过光的奖励,  相机提醒！");
        [self animationStartIntoCamera];
        
    }else
    {
        NSLog(@"今天已得到过光的奖励！");

    }
    
}

/*
-(void) refreshShowBringLightBtnState
{
    
    if ([self.userInfo checkIsBringUpinSunOrMoon]) {
        [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun.png"] forState:UIControlStateNormal];
    }else
    {
        [_showBringLightBtn setImage:[UIImage imageNamed:@"环-sun-空.png"] forState:UIControlStateNormal];
        
    }
    
    if ([self.userInfo checkIsBringUpinSunOrMoon]||isContineGiveLight) {
        [self setShowBringLightBtnHaveLight:YES];
    }else
    {
        
        [self setShowBringLightBtnHaveLight:NO];

    }
    
    
}
*/

/*
-(void) animationForShowBringLightBtnPop:(BOOL)isPop
{
    

    //有光在育成才弹出,或是奖励的一个光也弹出
    if (isPop && ([self.userInfo checkIsBringUpinSunOrMoon]||isContineGiveLight)) {
        [UIView beginAnimations:@"popOut_showBringLightBtn" context:Nil];
        [UIView setAnimationDuration:0.7f];
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
        [UIView setAnimationDuration:0.7f];
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
        

        
    }

    
    if ([animationID isEqualToString:@"popBack_showBringLightBtn"]) {

       
        
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
        [CommonObject showAlert:@"停止养育光" titleMsg:Nil DelegateObject:Nil];
        
        NSLog(@"光回到了头像，开启头像闪烁动画！");
        if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
            
        }else
        {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
            
        }
        
    }
    
}

*/




#pragma mark - 相机按钮动画
-(void) animationStartIntoCamera
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationStartIntoCamera)];
    _intoCameraBtn.transform = CGAffineTransformScale(_intoCameraBtn.transform, 1.2, 1.2);
    [UIView commitAnimations];
}

-(void)endAnimationStartIntoCamera
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationStartIntoCameraRepeat)];
    _intoCameraBtn.transform = CGAffineTransformScale(_intoCameraBtn.transform, 1/1.2, 1/1.2);
    [UIView commitAnimations];
    
    
}

-(void)endAnimationStartIntoCameraRepeat
{
    if (!needStopIntoCamera) {
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animationStartIntoCamera) userInfo:nil repeats:NO];
        
        //NSLog(@"---11");

    }else
    {
        //NSLog(@"---");
    }
    

    
}


- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


#pragma mark -  弹出按钮处理
- (IBAction)getBringedUpLight:(id)sender
{
    
    if ([self.userInfo checkIsBringUpinSunOrMoon]) {
        //计算育成的时间，奖励光
        [self caculateAndGiveSunOrMoon];
    }


    [self callBackLight];
    
    
    //移除点击指示
    [guidInfo RemoveTouchIndication];


    
}


//点击头像，或养育光环时，对光的处理
//later
-(void)callBackLight
{
    //有奖励光，且没有光育成时，只移动一个奖励的光
    if (![self.userInfo checkIsBringUpinSunOrMoon]) {
        //奖励时，只移动一个光
        [self moveLightWithRepeatCount:giveLingtCout StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];

        giveLingtCout = 0;

        isStartSunOrmoonImageMoveToHeaderAnimation = YES;
        
        
    }
    
    
    //如果有光在育成且有奖励光时，看到的是全部的光移动，或只要有光在育成，就移动全部的光
    if (([self.userInfo checkIsBringUpinSunOrMoon]) || [self.userInfo checkIsBringUpinSunOrMoon]) {
        
        NSLog(@"停光的育成，移动到头像！");
        
        [self moveLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
        
        isStartSunOrmoonImageMoveToHeaderAnimation = YES;
        
        [self.userInfo updateisBringUpSunOrMoon:NO];

        giveLingtCout = 0;
        
        NSString* temp =[NSString stringWithFormat:@"停止养育%@光",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        [self showCustomDelayAlertBottom:temp];
        
        
        
    }else
    {
        NSLog(@"没有光在育成！");
        
    }
    
    //更新为没有光
    //[self refreshShowBringLightBtnState];
    
    
}


/*
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
*/


- (IBAction)intoCamera:(id)sender {
    
    
    //先判断照片是否超限
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        if ([self.userInfo checkSunPhotoCountOver]) {

            [self showCustomYesAlertSuperView:@"阳光照片超过100张上限，请删除部分，并联系我们"  AlertKey:KEY_REMINDER_PHOTO_COUNT_OVER];
        }
        
        
    }else
    {
        if ([self.userInfo checkMoonPhotoCountOver]) {
            
            [self showCustomYesAlertSuperView:@"月光照片超过100张上限，请删除部分，并联系我们"  AlertKey:KEY_REMINDER_PHOTO_COUNT_OVER];
        }
    }
    
    //引导结束
    [self HandleGuidProcess:guidStep_mainView_End];
    
    
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



#pragma mark -  引导过程处理
- (void) HandleGuidProcess:(GuidStepNum) guidNeedNum
{
 
    //test
    return;
    NSLog(@"Guid Step input=%d, current = %d", guidNeedNum, guidInfo.guidStepNumber);
    //指定步等于当前步时，触发处理过程, 此设计可以任意放置HandleGuidProcess的调用
    //如中途中断，从上一次断的步开始引导
    if (guidNeedNum == guidInfo.guidStepNumber) {
        //执行当前步
        switch (guidInfo.guidStepNumber) {
            case guid_Start:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];
                //起动滑动引导
                [self showIntroWithCrossDissolve];
            }

                break;
            case guid_finishIntro_Start_firstOpen:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];

                //第一打开界面
                [self whenFirstlyOpenViewHandle];

            }
                break;
//            case guid_bring_intro_tofront:
//                [self.view bringSubviewToFront:intro];
//                break;
            case giudStep_guidFirstlyGiveLight:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];

                [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
                
                NSString* temp = [NSString stringWithFormat:@"首次登录\n奖励一个%@光\n点击获取",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
                [self showCustomYesAlertSuperView:temp AlertKey:KEY_IS_GIVE_FIRST_LIGHT];
                
            }
                break;
            case guidStep_guidFirstlyGiveLight_waitForTouchLigh:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];

                //禁止除点击的其它bringLightBtn外的操作,完成后打开
                [self DisableUserInteractionInView:self.view exceptViewWithTag:TAG_BRING_LING_BTN];
            
                //增加点击指示
                //[guidInfo AddTouchIndication:self.view TouchImageName:@"点击手势.png" TouchFrame:_showBringLightBtn.frame];
            
            }
                break;
                
            case giudStep_guidPanToBring:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];

                //禁止所有动作
                [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
                
                NSString* alTemp = [NSString stringWithFormat:(@"拖回%@光\n3小时养成1个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
                [self showCustomYesAlertSuperView:alTemp AlertKey:KEY_REMINDER_PAN_FOR_LIGHT];
                
                
            }
                break;
                case giudStep_guidPanToBring_waitForPan:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];

                //禁止除拖动以外的所有动作(点OK时，会再次被打开,故需再一次)
                [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];

                
                //增加拖动指示
                [guidInfo AddTouchIndication:self.view TouchImageName:@"拖动手势.png" TouchFrame:self.view.frame];

                //打开self.view的拖动，点OK后打开
                panSunOrMoonGusture.enabled = YES;
            }
                break;
            case guidStep_guidIntoCamera:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];
                
                //禁止所有动作
                [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];

                NSString* temp = [NSString stringWithFormat:@"进入相机\n大声说出你的%@光宣言",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
                [self showCustomYesAlertSuperView:temp AlertKey:KEY_REMINDER_GETINTO_CAMERA];

                [guidInfo RemoveTouchIndication];
                
            }
                break;
            case guidStep_guidIntoCamera_waitForTouch:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];
                
                [self DisableUserInteractionInView:self.view exceptViewWithTag:TAG_INTO_CAMERA_BTN];
                
                [guidInfo AddTouchIndication:self.view TouchImageName:@"点击手势.png" TouchFrame:_intoCameraBtn.frame];

            }
                break;
            case guidStep_mainView_End:
            {
                [guidInfo updateGuidStepNumber:guid_oneByOne];
                
                [guidInfo RemoveTouchIndication];
                
                //主界面引导结束...
                
            }
            default:
                break;
                
        }
        
        if (guidInfo.guidStepNumber > guidStep_mainView_End) {
            //主界面引导结束,打开所有的
            [self EnableUserInteractionInView:self.view];
        }

        
    }

    
}



#pragma mark - userInterFace Disable, Enable
-(void)DisableUserInteractionInView:(UIView *)superView exceptViewWithTag:(NSInteger)enableViewTag
{
    
    NSLog(@"----DisableUserInteractionInView");
    [CommonObject DisableUserInteractionInView:superView exceptViewWithTag:enableViewTag];
    
    //其它需要禁止的
    panSunOrMoonGusture.enabled = NO;
    tapSunOrMoonGusture.enabled = NO;
    tapHeaderView.enabled = NO;
}

-(void)EnableUserInteractionInView:(UIView *)superView
{
    
    NSLog(@"*****EnableUserInteractionInView");

    [CommonObject EnableUserInteractionInView:self.view];
    
    panSunOrMoonGusture.enabled = YES;
    tapSunOrMoonGusture.enabled = YES;
    tapHeaderView.enabled = YES;

    
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
    [self presentViewController:fitler animated:NO completion:NULL];
    
    
    
}

- (void)cancelCamera
{
    
    
}

#pragma mark - imagefilter delegate
#pragma mark - 照完象， 存用户据
- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData
{
    //存图片到数据库

    if ([[imageFilterData objectForKey:CAMERA_LIGHT_COUNT] integerValue]!=0)
    {
        giveLingtCout = [[imageFilterData objectForKey:CAMERA_LIGHT_COUNT] integerValue];
        [self showCustomYesAlertSuperView:@"完成阳光自拍，奖励一个阳光"  AlertKey:KEY_REMINDER_GIVE_LIGHT];

    }
    
    //[self refreshShowBringLightBtnState];
    [self refreshIntoCameraBtnState];

    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCAL_NEED_CHANGE_UI object:self];
        }
        
    }
    
}


#pragma mark -  change sun or moon UI
-(void) reFreshSunOrMoonUI:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:NOTIFY_LOCAL_NEED_CHANGE_UI])
    {
        
        [UIView beginAnimations:@"reFreshSunMoonUI_DisPre" context:(__bridge void *)(mainBgImage)];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
        NSLog(@"Disapear old UI : %@", [mainBgImage.image description]);
        mainBgImage.alpha = 0.5;
        [UIView commitAnimations];
    }
    
}



- (void)reFreshSunMoonUIAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_DisPre"]) {
        
        
        [UIView beginAnimations:@"reFreshSunMoonUI_ShowNew" context:(__bridge void *)(mainBgImage)];
        [UIView setAnimationDuration:3.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
        
        if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
            [mainBgImage setImage:[UIImage imageNamed:@"主页底图004.png"]];
            [_skySunorMoonImage setImage:[UIImage imageNamed:@"sun.png"]];


            
            
        }else
        {
            [mainBgImage setImage:[UIImage imageNamed:@"moon-home.png"]];
            [_skySunorMoonImage setImage:[UIImage imageNamed:@"moon.png"]];
        }
        
        
        [self refreshIntoCameraBtnState];
        //[self refreshShowBringLightBtnState];
        
        NSLog(@"Change new  UI to %@", [mainBgImage.image description]);

        
        mainBgImage.alpha = 1.0;
        [UIView commitAnimations];

    }
    
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_ShowNew"]) {
        
        //切换相当于新的时间新登录，处理一下登录打开的流程
        [self whenCommonOpenViewHandle];
        
    }
    
}


#pragma mark -  getter
//- (UIImageView *)userHeaderImageView {
//    
//    NSInteger w = SCREEN_WIDTH/2;
//    NSInteger Y = w;
//    [_userHeaderImageView setFrame:CGRectMake(_userHeaderImageView.frame.origin.x, _userHeaderImageView.frame.origin.y, w, Y)];
//    [_userHeaderImageView.layer setCornerRadius:(_userHeaderImageView.frame.size.height/2)];
//    _userHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    [_userHeaderImageView.layer setMasksToBounds:YES];
//    [_userHeaderImageView setContentMode:UIViewContentModeScaleAspectFill];
//    [_userHeaderImageView setClipsToBounds:YES];
//    _userHeaderImageView.layer.shadowColor = [UIColor clearColor].CGColor;
//    _userHeaderImageView.layer.shadowOffset = CGSizeMake(4, 4);
//    _userHeaderImageView.layer.shadowOpacity = 0.5;
//    _userHeaderImageView.layer.shadowRadius = 2.0;
//    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
//        _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//
//    }else
//    {
//        _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//
//    }
//    _userHeaderImageView.layer.borderWidth = 3.5f;
//    _userHeaderImageView.layer.cornerRadius =_userHeaderImageView.frame.size.width/2;
//    _userHeaderImageView.userInteractionEnabled = YES;
//    _userHeaderImageView.backgroundColor = [UIColor blackColor];
//    tapHeaderView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapUserHeader)];
//    [_userHeaderImageView addGestureRecognizer:tapHeaderView];
//    
//    
//    return _userHeaderImageView;
//}


#pragma mark -  handle Pan

#pragma mark 点击日月,只爆闪
-(void)TapSkySumOrMoonhandle:(UITapGestureRecognizer *)gestureRecognizer
{
    
    
    //test
    //[self animationLightSwimOutCount:1];

    //self animationLightSwimOutKeyFrameCount:15];
    [self getAndPopOutSpirite];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [bowLightView startAnimating];
        
        //later 点击后，太阳回到太阳，再弹出
    
    }

}


#pragma mark 拖动识别
- (void)HandlePanSunOrMoon:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if ([self.userInfo.sun_value integerValue]==0  ) {
            NSLog(@"sun_value==0 handlePan return");
            return;
        }
        
        _panSunorMoonImageView.image =[UIImage imageNamed:@"sun-小.png"];
        
    }else
    {
        if ([self.userInfo.moon_value integerValue] == 0) {
            NSLog(@"moon_value==0 handlePan return");
            return;
        }
        _panSunorMoonImageView.image =[UIImage imageNamed:@"moon-小.png"];

        
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
                _panSunorMoonImageView.hidden =  YES;
                
            }else
            {
                NSLog(@" 开始拖动手势： 起点：头像之外！");
                isFromHeaderBegin = NO;
            }
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {

            
            if (isFromHeaderBegin) {
                _panSunorMoonImageView.hidden =  YES;
                _panSunorMoonImageView.center = location;
                _panSunorMoonImageView.alpha = 1.0;
                
                panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[CommonObject getUsedSamllLightImageNameByTime]]];
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

                    NSString* time = [NSString stringWithFormat:@"开始养育%@光了", ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
                    NSLog(@"%@", time);
                    [self showCustomDelayAlertBottom:time];
                    
                    
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
                _panSunorMoonImageView.hidden =  YES;
                
                
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
                _panSunorMoonImageView.hidden = YES;
                
                if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sun-小.png"]];
                    
                }else
                {
                    panTracelight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon-小.png"]];
                    
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

                    
                    [self callBackLight];
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

#pragma mark - 光游动而出, 又返回
/**
 *  贝塞尔 曲线游动而出
 *
 *  @param count 最大为2，不能为0
 */
-(void) animationLightSwimOutBazierLightType:(LightType) type srcView:(UIImageView*) srcView  start:(CGPoint) startPoint end:(CGPoint) endPoint

{
    
    NSMutableArray* posionArry = [self getRadomPosionWithSize:CGSizeMake(15, 15) inFrame:CGRectMake(0, 0-200, SCREEN_WIDTH, SCREEN_HEIGHT-_userHeaderImageView.frame.size.height) exceptFrame:_skySunorMoonImage.frame Count:2];

    
    if (!posionArry) {
        return;
    }
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:srcView];
    
    if (!simOutAnimationArray) {
        simOutAnimationArray=[NSMutableArray arrayWithCapacity:0];
    }
    [simOutAnimationArray addObject:customAnimation];
    
    CGRect bazier_1 = [[posionArry objectAtIndex:0] CGRectValue];
    CGPoint bazierPoint_1 = CGPointMake(bazier_1.origin.x, bazier_1.origin.y);
    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
    
    CGRect bazier_2 = [[posionArry objectAtIndex:1] CGRectValue];
    CGPoint bazierPoint_2 = CGPointMake(bazier_2.origin.x, bazier_2.origin.y);
    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageView:srcView];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartSize:CGSizeMake(30, 30)];
    [customAnimation setAniEndSize:CGSizeMake(30, 30)];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniImage:srcView.image];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:@"animation_swim_bazier_out"];
    [customAnimation setAniRepeatCount:1];
    [customAnimation setAniDuration:POP_OUT_ANIMATION_LIGHT_TIME];
    
    [customAnimation startCustomAnimation];
    
    
}

#pragma mark - 光游动而出, 关键帧动画
/**
 *  光游动而出，再返回, 关键帧动画
 *
 *  @param count 随机关键帧点的个数,不包括开始点,与结束点
 */
-(void) animationLightSwimOutKeyFrameCount:(NSInteger) count lightType:(LightType) type srcView:(UIImageView*) srcView
{
    //count = 4;
    
    NSMutableArray* posionArry = [self getRadomPosionWithSize:CGSizeMake(15, 15) inFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-300) exceptFrame:_skySunorMoonImage.frame Count:count];
    if (!posionArry) {
        return;
    }
    
    simOutAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:srcView];
    
    if (!simOutAnimationArray) {
        simOutAnimationArray=[NSMutableArray arrayWithCapacity:0];
    }
    [simOutAnimationArray addObject:simOutAnimation];
    
    CGPoint startPoint = _skySunorMoonImage.center;
    CGPoint endPoint =CGPointMake([CommonObject getRandomNumber:0+15 to:SCREEN_WIDTH-15], [CommonObject getRandomNumber:0+15 to:SCREEN_HEIGHT-_userHeaderImageView.frame.size.height]);
    
    [simOutAnimation setAniType:KEY_FRAME_POSION_TYPE];
    [simOutAnimation setAniImageView:srcView];
    [simOutAnimation setBkLayer:self.view.layer];
    [simOutAnimation setAniStartSize:CGSizeMake(30, 30)];
    [simOutAnimation setAniStartPoint:startPoint];
    [simOutAnimation setAniEndpoint:endPoint];
    [simOutAnimation setAniEndSize:CGSizeMake(30, 30)];
    [simOutAnimation setAniImage:[CommonObject getLightImageByLightType:type]];
    [simOutAnimation setCustomAniDelegate:self];
    [simOutAnimation setAnikey:@"animation_swim_key_frame"];
    [simOutAnimation setAniRepeatCount:1];
    [simOutAnimation setAniDuration:POP_OUT_ANIMATION_LIGHT_TIME];
    
    //开始点,结束点也算一帧
    [simOutAnimation setAniKeyframePointCount:count+2];

    for (int i=0; i<count; i++) {
        
        //关键帧点
        CGRect rectSrc =[[posionArry objectAtIndex:i] CGRectValue];
        CGPoint pointKey = CGPointMake(rectSrc.origin.x, rectSrc.origin.y);
        [simOutAnimation setAniKeyframePoint:pointKey];
        
    }
    
    [simOutAnimation startCustomAnimation];

}




-(void) animationLightSwimBackKeyFrameWithAni:(CustomAnimation*) srcAni
{
    
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:srcAni.aniImageView];
    
    CGPoint startPoint = srcAni.aniImageView.center;
    CGPoint endPoint = _skySunorMoonImage.center;
    
    CGPoint bazierPoint_1 = CGPointMake(startPoint.x+(endPoint.x-startPoint.x)/2 + 50, startPoint.y+(endPoint.y-startPoint.y)/2+50);
    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
    
    CGPoint bazierPoint_2 = CGPointMake(startPoint.x+(endPoint.x-startPoint.x)/2 + 70, startPoint.y+(endPoint.y-startPoint.y)/2+70);
    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageView:srcAni.aniImageView];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartSize:CGSizeMake(30, 30)];
    [customAnimation setAniEndSize:CGSizeMake(30, 30)];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniImage:srcAni.aniImageView.image];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:@"animation_swim_back"];
    [customAnimation setAniRepeatCount:1];
    [customAnimation setAniDuration:[CommonObject getRandomNumber:1 to:POP_BACK_ANIMATION_LIGHT_TIME]];
    
    
    [customAnimation startCustomAnimation];
    
    
}


/**
 *  起点位置左右随机变动位置
 *
 *  @param aroundView 运动的view
 */
-(void)swimAroundReapt:(UIImageView*) aroundView
{
    
    [self animationLightSwimAround:aroundView];
    
}

-(void) animationLightSwimAround:(UIImageView*) aroundView
{
    
    //当前位置为起点
    CGPoint startPoint = CGPointMake(aroundView.frame.origin.x+aroundView.frame.size.width/2, aroundView.frame.origin.y+aroundView.frame.size.height/2);
    //30像素范围内随机变化
   // CGPoint endPoint = CGPointMake(startPoint.x+[CommonObject getRandomNumber:0 to:30], startPoint.y+[CommonObject getRandomNumber:0 to:30]);
    CGPoint endPoint = startPoint;
    
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:aroundView];
    
    [customAnimation setAniBazierCenterPoint1:CGPointMake(startPoint.x+[CommonObject getRandomNumber:-SWIM_AROUND_LIGHT_DISTANCE to:SWIM_AROUND_LIGHT_DISTANCE], startPoint.y+[CommonObject getRandomNumber:-SWIM_AROUND_LIGHT_DISTANCE to:SWIM_AROUND_LIGHT_DISTANCE])];
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartSize:CGSizeMake(30, 30)];
    [customAnimation setAniEndSize:CGSizeMake(30, 30)];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniImage:aroundView.image];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:@"animation_swim_around"];
    [customAnimation setAniRepeatCount:1];
    [customAnimation setAniDuration:SWIM_AROUND_LIGHT_TIME];
    
    [customAnimation setAniEndpoint:endPoint];
    
    [customAnimation startCustomAnimation];
    
    
}


//在相机以上的区域，随机放置光
-(NSMutableArray*) getRadomPosionWithSize:(CGSize) size inFrame:(CGRect) inFrame  exceptFrame:(CGRect)exceptFrame   Count:(NSInteger) count
{
    
    if (!count || !size.width || !size.height || !inFrame.size.width || !inFrame.size.height) {
        NSLog(@"ERROR: getRadomPosionWithFrame");
        return Nil;
    }
    
    
    //解释。。。。
    NSInteger start_x = inFrame.origin.x+ size.width/2;
    NSInteger end_x = inFrame.origin.x+inFrame.size.width - size.width/2;

    
    NSInteger start_y = inFrame.origin.y+size.height/2;
    NSInteger end_y = inFrame.origin.y+inFrame.size.height - size.height/2;
    
    
    //获取随机frame
    NSMutableArray * radomPosionArray = [NSMutableArray arrayWithCapacity:count];
    for (int i =0 ; i<count; i++) {
        //随机x
        NSInteger radomX = [CommonObject getRandomNumber:start_x to:end_x];

        //随机y
        NSInteger radomY = [CommonObject getRandomNumber:start_y to:end_y];

        CGRect getRect = CGRectMake(radomX, radomY, size.width, size.height);
        if (CGRectIntersectsRect(exceptFrame, getRect)) {
            i--;
            continue;
        }else
        {
            [radomPosionArray addObject:[NSValue valueWithCGRect:CGRectMake(radomX, radomY, size.width, size.height)]];

        }
        
    }
    

    return radomPosionArray;
    
}

#pragma mark -  ****** customAnimation  Delegate
- (void) customAnimationFinishedRuturn:(NSString*) aniKey srcView:(UIImageView *)srcView
{
    
    //NSLog(@"customAnimationFinishedRuturn ---- %@", aniKey);
    
    if ([aniKey isEqualToString:@"animation_swim_bazier_out"]) {
        
        if (srcView == ((CustomAnimation*)simOutAnimationArray.lastObject).aniImageView) {
            //最后一个动画完成
            [self EnableUserInteractionInView:self.view];
        }
        
        [self swimAroundReapt:srcView];
        
    }
    
    if ([aniKey isEqualToString:@"animation_swim_around"])
    {
        [self swimAroundReapt:srcView];
        
    }
    
    if ([aniKey isEqualToString:@"animation_swim_back"]) {
        
        if (srcView == ((CustomAnimation*)simOutAnimationArray.lastObject).aniImageView) {
            //最后一个动画完成
            [self EnableUserInteractionInView:self.view];
            [simOutAnimationArray removeAllObjects];
        }
        
        //删除精灵原图
        [srcView removeFromSuperview];
        [srcView setHidden:YES];
        
    }
    
    
    
}


#pragma mark - 放出光

/**
 *  每隔指定时音，放出指定个数的光
 *
 *  @param count 放出光的个数
 *  @param type  光的类型
 *  @param srcView  待操作的原view
 */
- (void) popOutLightCount:(NSInteger) count lightType:(LightType) type srcViewArray:(NSMutableArray*) srcViewArray
{
    
    //控制在2秒内全部释放完成
    float timeInterval = POP_OUT_ALL_LIGHT_TIME / count;
    
    NSDictionary * timerUserInfo =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type], @"popOutLightType",
    [NSNumber numberWithInt:count], @"popOutLightCount",
    srcViewArray,@"popOutLightViewArray",
    nil];

    repeatCount =0;
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(popOutLight:) userInfo:timerUserInfo repeats:YES];
    
    
}

- (void) popOutLight:(NSTimer*) timer
{
    
    
    NSDictionary *timerUserInfo = (NSDictionary *)timer.userInfo;
    LightType type = [[timerUserInfo objectForKey:@"popOutLightType"] integerValue];
    NSInteger count = [[timerUserInfo objectForKey:@"popOutLightCount"] integerValue];
    NSMutableArray * viewArray =(NSMutableArray*)[timerUserInfo objectForKey:@"popOutLightViewArray"];
    
    if (repeatCount != count) {
        //弹出 count 个精灵
        [self animationLightSwimOutBazierLightType:type srcView:[viewArray objectAtIndex:repeatCount] start:_skySunorMoonImage.center end:CGPointMake([CommonObject getRandomNumber:0+15 to:SCREEN_WIDTH-15], [CommonObject getRandomNumber:0 to:SCREEN_HEIGHT-_userHeaderImageView.frame.size.height])];
        
        repeatCount ++;
        
    }else
    {
        [timer invalidate];
        repeatCount = 0;
    }
    
}


#pragma mark - 计算光的类型
-(void)caculateLightTypeAndCountByCount:(NSInteger) count
{
    
    
    NSInteger sumCount = count;
    
    //计算红点点个数,20个光生成1个红点点
    NSInteger redCount = sumCount/20;
    //计算蓝点点个数，100个红生成一个蓝
    NSInteger blueCount = redCount/100;
    NSInteger redCountLeft = redCount%100;

    
    lightTypeCountInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:sumCount], KEY_LIGHT_TYPE_SUM_COUNT,[NSNumber numberWithInt:redCount], KEY_LIGHT_TYPE_RED_COUNT,[NSNumber numberWithInt:blueCount], KEY_LIGHT_TYPE_BLUE_COUNT,[NSNumber numberWithInt:redCountLeft], KEY_LIGHT_TYPE_RED_COUNT_LEFT,nil];
    
    NSLog(@"caculateLightTypeAndCount : %@",lightTypeCountInfo);
    
    
}

#pragma mark - ***************召唤并释放精灵 或 召回

/**
 *  召唤并释放精灵
 */
-(void) getAndPopOutSpirite
{
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];
    
    NSInteger count;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        count = self.userInfo.sun_value.integerValue;
    }else
    {
        count = self.userInfo.moon_value.integerValue;
    }
    
    //test
    count = 20;
    
    [self caculateLightTypeAndCountByCount:count];
    
    
    NSInteger getCount,leftCount;
    //召唤红
    getCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_RED_COUNT] integerValue];
    leftCount=[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_RED_COUNT_LEFT] integerValue];
    if (leftCount>0) {
        getCount = leftCount;
    }
    
    if (getCount) {
        //构造红精灵
        if (!simOutRedImageViewArray) {
            simOutRedImageViewArray = [NSMutableArray arrayWithCapacity:getCount];
        }
        [simOutRedImageViewArray removeAllObjects];
        for (int i = 0; i<getCount; i++) {
            UIImageView* redView = [[UIImageView alloc]initWithImage:[CommonObject getLightImageByLightType:lightTypeRed]];
            redView.frame = CGRectMake(0, 0, 0, 0);
            [simOutRedImageViewArray addObject:redView];
            [self.view addSubview:redView];
            
        }
        //先大范围弹出，结束后，再小范围游动，以便在召回时，位置可知
        [self popOutLightCount:getCount  lightType:lightTypeRed srcViewArray:simOutRedImageViewArray];
    }
    

    
    
    
     //召唤蓝
    getCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_BLUE_COUNT] integerValue];
    if (getCount) {
        //构造蓝精灵
        if (!simOutBlueImageViewArray) {
            simOutBlueImageViewArray = [NSMutableArray arrayWithCapacity:getCount];
        }
        [simOutBlueImageViewArray removeAllObjects];
        for (int i = 0; i<getCount; i++) {
            UIImageView* blueView = [[UIImageView alloc]initWithImage:[CommonObject getLightImageByLightType:lightTypeBlue]];
            blueView.frame = CGRectMake(0, 0, 0, 0);
            [simOutBlueImageViewArray addObject:blueView];
            [self.view addSubview:blueView];
        }
        [self popOutLightCount:getCount  lightType:lightTypeBlue srcViewArray:simOutBlueImageViewArray];
    }

    
    
}


-(void) stopAndGetBackSpirite
{
    
    if (simOutAnimationArray.count == 0) {
        NSLog(@"Notify: no spirite need to be call back");
        return;
    }
    
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];

    //控制在2秒内全部释放完成
    float timeInterval = POP_BACK_ALL_LIGHT_TIME / simOutAnimationArray.count;

    repeatCount = 0;
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(getBackSpirite:) userInfo:nil repeats:YES];
    
}

-(void) getBackSpirite:(NSTimer *)timer
{
    
    CustomAnimation* backAni = [simOutAnimationArray objectAtIndex:repeatCount];
    [self animationLightSwimBackKeyFrameWithAni:backAni];

    repeatCount++;
    
    if(repeatCount == simOutAnimationArray.count)
    {
        [timer invalidate];
        timer = nil;
    }
    
    
}

#pragma mark - 计算光的奖励
//return 奖励的个数
-(NSInteger) caculateAndGiveSunOrMoon
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
        return 0 ;
    }
    
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    
    int totalHours = days*24+hours;
    //每3小时奖励一个光
    int giveCount = totalHours / 3;
    [self.userInfo addSunOrMoonValue:giveCount];
    
    
    NSString* timeshow = [NSString stringWithFormat:(@"从%@ 开始养育 (%d) 光，养育了%d 小时，奖励 %d 个光"), startDate, [CommonObject checkSunOrMoonTime], totalHours, giveCount];
    NSLog(@"%@", timeshow);
    
//    if (totalHours==0) {
//        customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"提示框v1.png"  yesBtnImageName:nil posionShowMode:viewCenterBig];
//        [customAlertAutoDis setAlertMsg:@"Oh,养育时间太短了"];
//        [customAlertAutoDis RunCumstomAlert];
//
//    }
    
    if (totalHours>0 && totalHours<3) {
        //NSString* timeAlert = [NSString stringWithFormat:(@"%@光托管了%d小时\n每3个小时奖励1个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        //[self showCustomYesAlertSuperView:timeAlert AlertKey:KEY_REMINDER_SUCC_GET_LIGHT];
        
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        
        return 0;

    }
    
    if (totalHours>3) {
        NSString* timeAlert = [NSString stringWithFormat:(@"%@光养育了%d小时\n养成%d个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours, giveCount,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        [self showCustomYesAlertSuperView:timeAlert AlertKey:KEY_REMINDER_SUCC_GET_LIGHT];

        
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        
        return giveCount;
    }
    
    
    
    //清空光育成时间
    [self.userInfo updateSunorMoonBringupTime:0];
    
    return 0;

    
}

#pragma mark - Animation
-(void) moveLightWithRepeatCount:(NSInteger)repeatCount  StartPoint:(CGPoint) start  EndPoint:(CGPoint) end  IsUseRepeatCount:(BOOL) isUseRepeatCount
{
    NSString* imageName = NULL;
    if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
        imageName = @"sun-小.png";
        
        if (!isUseRepeatCount) {
            repeatCount = [self.userInfo.sun_value intValue];
        }
        NSLog(@"移动 %d 个阳光", repeatCount);

        
    }else
    {
        imageName = @"moon-小.png";
        
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
    
    panBackSunOrMoonlayer.contents=_panSunorMoonImageView.layer.contents;
    panBackSunOrMoonlayer.frame=_panSunorMoonImageView.frame;
    panBackSunOrMoonlayer.opacity=1;
    [self.view.layer addSublayer:panBackSunOrMoonlayer];
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
        animation.repeatDuration = 3;
        animation.repeatCount = 10;

        
    }
    [panBackSunOrMoonlayer addAnimation:animation forKey:@"moveLight"];
 
    
 
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
        
        //第一个光回到头像后，起动拖动光的引导:giudStep_guidPanToBring
        [self HandleGuidProcess:giudStep_guidPanToBring];
        
        //删除拖动动画图层
        [panBackSunOrMoonlayer removeFromSuperlayer];
        
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
            //panTracelight.hidden =YES;
            [panTracelight removeFromSuperview];
        }
        
        //如果是进入小屋触发的动画，则完成时进入小屋
        if (isGetinToHome) {
            [self performSegueWithIdentifier:@"getintoHome" sender:nil];
        }

        
        [self stopAndGetBackSpirite];
        
    }
    
    if (isStartSunOrmoonImageMoveToSunMoonAnimation) {
        
        
        //判断是否完成了引导拖动
        //起动：guidStep_guidIntoCamera
        [self HandleGuidProcess:guidStep_guidIntoCamera];
        
        //删除拖动动画图层
        [panBackSunOrMoonlayer removeFromSuperlayer];
        
        _panSunorMoonImageView.hidden = YES;
        
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
        
        
        //计算并召唤精灵
        [self getAndPopOutSpirite];

        
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
    
    if (realRange == 0) {
        return;
    }

    NSLog(@"开启头像闪烁动画, range=%d！", realRange);
    
    NSInteger bigRang = realRange/7+1;
    NSInteger smallRang = realRange%7+1;
    
    //此版本无效
    NSInteger rainBowCount = bigRang/7;
    if (rainBowCount>=1) {
        NSLog(@"超过7个光环，增加提示框v1！");
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
            //定位第一个环的位置
            lightBowSkyUserHeaderViewWidth = _userHeaderImageView.frame.size.width+75;
            lightBowSkyUserHeaderViewHeigth = _userHeaderImageView.frame.size.height+75;
        }else
        {
            lightBowSkyUserHeaderViewWidth = lightBowSkyUserHeaderViewWidth+IntervalWidth*2;
            lightBowSkyUserHeaderViewHeigth = lightBowSkyUserHeaderViewHeigth+IntervalWidth*2;
        }

        [lightUserHeaderTag setFrame:CGRectMake(_userHeaderImageView.center.x-lightBowSkyUserHeaderViewWidth/2, _userHeaderImageView.center.y-lightBowSkyUserHeaderViewHeigth/2, lightBowSkyUserHeaderViewWidth, lightBowSkyUserHeaderViewHeigth)];
        lightUserHeaderTag.animationDuration=1.0;
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
    //test
     [self stopAndGetBackSpirite];
    //[self.frostedViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"-MainSunMoonViewController----ReceiveMemoryWarning!");
    
}

#pragma mark - Customer alert
-(void) showCustomYesAlertSuperView:(NSString*) msg  AlertKey:(NSString*) alertKey
{
    
    customAlertAutoDisYes = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:@"提示框v1.png"  yesBtnImageName:@"YES.png" posionShowMode:userSet  AlertKey:alertKey];
    [customAlertAutoDisYes setStartCenterPoint:self.view.center];
    [customAlertAutoDisYes setEndCenterPoint:self.view.center];
    [customAlertAutoDisYes setStartAlpha:0.1];
    [customAlertAutoDisYes setEndAlpha:1.0];
    [customAlertAutoDisYes setStartHeight:0];
    [customAlertAutoDisYes setStartWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndHeight:customAlertAutoDisYes.endWidth];
    [customAlertAutoDisYes setDelayDisappearTime:5.0];
    [customAlertAutoDisYes setMsgFrontSize:45];
    [customAlertAutoDisYes setAlertMsg:msg];
    [customAlertAutoDisYes setCustomAlertDelegate:self];
    [customAlertAutoDisYes RunCumstomAlert];
    
}

- (void)yesButtonHandler:(id)sender
{
    [customAlertAutoDisYes yesButtonHandler:nil];
    [customAlertAutoDis yesButtonHandler:nil];

    
}

-(void) showCustomDelayAlertBottom:(NSString*) msg
{
    customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:@"延时提示框.png"  yesBtnImageName:nil posionShowMode:userSet AlertKey:nil];
    [customAlertAutoDis setStartHeight:0];
    [customAlertAutoDis setStartWidth:SCREEN_WIDTH-30];
    [customAlertAutoDis setEndWidth:SCREEN_WIDTH-30];
    [customAlertAutoDis setEndHeight:60];
    [customAlertAutoDis setStartCenterPoint:CGPointMake(SCREEN_WIDTH/2, -customAlertAutoDis.endHeight/2)];
    [customAlertAutoDis setEndCenterPoint:CGPointMake(SCREEN_WIDTH/2, customAlertAutoDis.endHeight/2+60)];
    [customAlertAutoDis setStartAlpha:0.1];
    [customAlertAutoDis setEndAlpha:0.8];
    [customAlertAutoDis setDelayDisappearTime:5.0];
    [customAlertAutoDis setMsgFrontSize:30];
    [customAlertAutoDis setAlertMsg:msg];
    [customAlertAutoDis RunCumstomAlert];
    
}

#pragma mark - CustomAlertDelegate
- (void) CustomAlertOkAnimationFinish:(NSString*) alertKey
{
    NSLog(@"custom aler ok return");
    if ([alertKey isEqualToString:KEY_IS_GIVE_FIRST_LIGHT]) {
        //起动：guidStep_guidFirstlyGiveLight_waitForTouchLigh
        [self HandleGuidProcess:guidStep_guidFirstlyGiveLight_waitForTouchLigh];


    }
    
    
    if ([alertKey isEqualToString:KEY_REMINDER_PAN_FOR_LIGHT]) {
        
        //起动：giudStep_guidPanToBring_waitForPan
        [self HandleGuidProcess:giudStep_guidPanToBring_waitForPan];

        
    }
    
    if ([alertKey isEqualToString:KEY_REMINDER_GETINTO_CAMERA]) {
        
        //起动：guidStep_guidIntoCamera_waitForTouch
        [self HandleGuidProcess:guidStep_guidIntoCamera_waitForTouch];
        
        
    }
    
    if ([alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT]) {
        
        [self animationGiveLightCout:giveLingtCout];
    }
    
    //点击头像，有光在养育，有奖励，点OK后，进入小屋
    if ([alertKey isEqualToString:KEY_REMINDER_SUCC_GET_LIGHT]) {
        
        if (isGetinToHome) {
            [self performSegueWithIdentifier:@"getintoHome" sender:nil];
        }
        
        
    }
    
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


#pragma mark - 引导滑屏
- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    EAIntroPage *page2 = [EAIntroPage page];
    EAIntroPage *page3 = [EAIntroPage page];


    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    
    if (SCREEN_HEIGHT>480) {
        page1.titleImage = [UIImage imageNamed:@"引导1.png"];
        page2.titleImage = [UIImage imageNamed:@"引导2.png"];
        page3.titleImage = [UIImage imageNamed:@"引导3.png"];

    }else
    {
        page1.titleImage = [UIImage imageNamed:@"引导1-4.png"];
        page2.titleImage = [UIImage imageNamed:@"引导2-4.png"];
        page3.titleImage = [UIImage imageNamed:@"引导3-4.png"];

    }
 
    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    
    
    
    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    [intro.skipButton setHidden:YES];

    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:2.0];
    //[self.view addSubview:intro];
    
}


- (void)introDidFinish
{
    //引导完成的第一次起动处理
    //起动:guid_finishIntro_Start_firstOpen
    [self HandleGuidProcess:guid_finishIntro_Start_firstOpen];
    //jjj
    //[self whenFirstlyOpenViewHandle];
}

- (void)introDidEndScrollAt:(NSInteger) currentIndex  TotalCount:(NSInteger)pageCount
{
    
    if (currentIndex == pageCount-1) {
        //最后一页
        [intro.skipButton setFrame:CGRectMake(SCREEN_WIDTH/2-20, SCREEN_HEIGHT-100, 30, 30)];
        [intro.skipButton setTitle:@"" forState:UIControlStateNormal];
        [intro.skipButton setHidden:NO];

    }
    
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
-(void)handleTapUserHeader:(UITapGestureRecognizer *)gestureRecognizer
{
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
//        _userHeaderImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    //进不来，原因不明
//    }
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
//        
//        _userHeaderImageView.layer.borderColor = [[UIColor orangeColor] CGColor];
//    }
    
    
    if (self.userInfo.userType == USER_TYPE_NEW || (self.userInfo.userType == USER_TYPE_NEED_CARE && [self.userHeaderImageView isEqual:[UIImage imageNamed:@"默认头像.png"]])) {
        [self.userInfo updateUserType:USER_TYPE_TYE];
        [self editUserHeader];
    }else
    {
        //进入小屋,先收回的育成才能进入
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            
            //计算育成的时间，奖励光
            if ([self caculateAndGiveSunOrMoon]>0) {
                //等用户点击OK时进入小屋
            }else
            {
                [self callBackLight];
                //待完成收回动画后，再进入小屋

            }
            isGetinToHome =  YES;


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
                
                //计算育成的时间，奖励光
                if ([self caculateAndGiveSunOrMoon]>0) {
                    //等用户点击OK时进入小屋
                }else
                {
                    [self callBackLight];
                    //待完成收回动画后，再进入小屋
                    
                }
                isGetinToHome =  YES;


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
    
   //[_userCloud upateUserInfo:userInfo];
    
    
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
