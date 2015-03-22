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
#import "ShareByShareSDR.h"






@interface MainSunMoonViewController ()
{
    GuidController* guidInfo;
    
    BOOL  isHaveFirstlyOpen; //第一次登录
    //BOOL  isHaveOpenUI;  //第一次打开主界面，用于区分第一次登录，和第一次打开主界面
    
    //BOOL  isGiveFirstLight;
    
    BOOL isFromLowView; //从下一层view来，不更新视图

    
    EAIntroView *intro ;
    
    UIImageView* userHeaderSpiritBk; //标识现有精灵的个数
    UILabel *spiritCountlabel;
    UIImageView* spiriteViewInUserHeader; //在头像边上的精灵

    
    UIButton* _intoCameraBtn;

    NSString* userDir;

    BOOL alreadyDisable;//标识是否已禁止了触摸
    
    BOOL ToreFreshSky;//是否正在刷新天空
    
    BOOL  isFromHeaderBegin;
    BOOL  isFromSunMoonBegin;
    UIImageView*  lightSkySunOrMoonView; //太阳或月亮闪烁动画View
    UIImageView*  lightBowSkyUserHeaderView; //头像爆闪烁动画View
    UIImageView* lightUserHeader;//头像闪烁动画View, 7个闪烁光环
    UIImageView* panTracelight;  //拖动轨迹
    NSInteger  panTraceligntTag; //拖动轨迹的TAG
    
    UIPanGestureRecognizer *panSunOrMoonGusture;  //拖动动画识别
    UITapGestureRecognizer *tapSunOrMoonGusture; //点击太阳的识别
    UITapGestureRecognizer *tapHeaderView;
    
    
    UIImageView* swimTracelight;  //游动的光
    NSMutableArray * swimTracelightArray;
    NSInteger  swimTraceligntTag; //游动的光的TAG
    CALayer *swimBackSunOrMoonlayer;  //游动的光的，弹回的动画图层
    
    //BOOL isStartSunOrmoonImageMoveToHeaderAnimation;//起动了向头像移动光的动画
    //BOOL isStartSunOrmoonImageMoveToSunMoonAnimation;//起动了向日月移动光的动画
    
    BOOL isPopOutIntoCameraBtn;  //是否已弹出
    BOOL isPopOutShowBringLightBtn;
    
    NSInteger giveLingtCout; //奖励光的个数
    
    BOOL isGetinToHome; //是进入小屋的点击
    
    NSMutableArray *_shareTypeArray;

    CGRect srcIntoCameraBtnFrame ;
    CGPoint srcIntoCameraBtnCenter;
    CGRect destIntoCameraBtnFrame ;
    CGPoint destIntoCameraBtnCenter;

    
    CGRect srcShowBringLightBtnFrame;
    CGRect destShowBringLightBtnFrame;
    
    UIImageView* bowLightView; //日月闪爆闪
    UIImageView* bowLightBringView; //育成光爆闪
    
    CustomAlertView* customAlertAutoDis;
    CustomAlertView* customAlertAutoDisYes;
    
    CGAffineTransform inToCameraBtnTransform;
    
    
    NSMutableArray* swimOutAnimationArray;//所有的动画组
    NSMutableArray* swimOutAnimationLightArray;// 光的动画组,标识有多少个光的动画在外面
    NSMutableArray* swimOutAnimationSpiriteArray;//精灵的动画组

    NSMutableArray*  swimOutBaselightImageViewArray; //小光的view组,全量的,有新增的则补充
    NSMutableArray*  swimOutBaselightImageViewArrayFrame; //小光的view组全量位置，全量的，开始就是全量的


    NSMutableArray*  swimOutSpiriteImageViewArray; //精灵的view组，全量,有新增的则补充

    NSMutableArray* swimOutSpiriteImageViewArrayFrame;//精灵的view组的位置，全量

    NSMutableArray* swimOutSpiriteImageViewArrayaphale;
    
    NSMutableArray* spiriteAutoFlyPointArray; //精灵自动飞行的位置组
    NSInteger spiriteAutoFlyPointCurrentIndex;//精灵自动飞行当前的位置
    BOOL  spiriteFlyIsAuto; //精灵是否在自动飞行状态
    NSTimer* spiriteFlyAutoReapaterTimer;
    
    CustomAnimation* guidPanToSkyAni;
    CustomAnimation* guidTouchIntoCameraAni;


    NSTimer* swimAroundTimer; //随进四处游荡timer

    CGPoint spiritFlyTouchPoint; //精灵要飞向的点击的位置
    
    NSInteger repeatCountLight;
    NSInteger repeatCountLightBack;
    NSInteger repeatCountSpirite;
    NSInteger repeatCountSpiriteBack;
    NSInteger repeatCountSpiriteFlyTrace;
    NSInteger repeatCountMoveSimpleLight; //简单的光移动动画，在太阳与头像之间等
    UIImageView*  lastRepeatCountMoveSimpleLightView; //标识最后一个动画


    BOOL needStopAnimationToCallBack; //是否需要停止动画，以便定位后，召回
    BOOL needStopLightAnimationToCallBackForRefresh; //是否需要停止动画，以便定位后，召回,自动计算光的召回
    BOOL needStopLightAnimationToCallBackForFinal; //手动最终召回
    BOOL needStopSpiriteAnimationToCallBack;
    BOOL needStopSpiriteAnimationToFlyTraceTouch; //为点击精灵飞动，而停止
    BOOL needStopSpiriteAnimationToFlyAuto; //为精灵自动飞动，而停止


    NSDictionary * lightTypeCountInfo;
    
    MONActivityIndicatorView *indicatorView;

    
}

/**
 *	@brief	用户信息更新
 *
 *	@param 	notif 	通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif;

@end

@implementation MainSunMoonViewController

@synthesize mainBgImage,menuBtn,userInfo,userDB,userHeaderImageView = _userHeaderImageView;
@synthesize skySunorMoonImage =_skySunorMoonImage;
@synthesize  panSunorMoonImageView =_panSunorMoonImageView;
@synthesize skyWindow = _skyWindow,lightPostionFrame=_lightPostionFrame;



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"---->viewDidLoad");

	// Do any additional setup after loading the view, typically from a nib.
    
    indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 4;
    indicatorView.radius = SCREEN_WIDTH/50;
    indicatorView.internalSpacing = 4;
    indicatorView.center = self.view.center;
    [self.view addSubview:indicatorView];
    
    
    //shareSdk**********
    //监听用户信息变更
    [ShareSDK removeAllNotificationWithTarget:self];
    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
                               target:self
                               action:@selector(userInfoUpdateHandler:)];
    
    _shareTypeArray = [[NSMutableArray alloc] init];
    
    NSArray *shareTypes = [ShareSDK connectedPlatformTypes];
    for (int i = 0; i < [shareTypes count]; i++)
    {
        NSNumber *typeNum = [shareTypes objectAtIndex:i];
        ShareType type = (ShareType)[typeNum integerValue];
        //id<ISSPlatformApp> app = [ShareSDK getClientWithType:type];
        
        if (type == ShareTypeSinaWeibo || type == ShareTypeTencentWeibo)
        {
            [_shareTypeArray addObject:[NSMutableDictionary dictionaryWithObject:[shareTypes objectAtIndex:i]
                                                                          forKey:@"type"]];
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    userDir= [paths objectAtIndex:0];
    
    NSArray *authList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",userDir]];
    if (authList == nil)
    {
        [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",userDir] atomically:YES];
    }
    else
    {
        for (int i = 0; i < [authList count]; i++)
        {
            NSDictionary *item = [authList objectAtIndex:i];
            for (int j = 0; j < [_shareTypeArray count]; j++)
            {
                if ([[[_shareTypeArray objectAtIndex:j] objectForKey:@"type"] integerValue] == [[item objectForKey:@"type"] integerValue])
                {
                    [_shareTypeArray replaceObjectAtIndex:j withObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                    break;
                }
            }
        }
    }
    //shareSdk**********
    
    
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
    [mainBgImage setImage:[CommonObject getSkyBkImageByTime]];
    [_skySunorMoonImage setImage:[CommonObject getSunMoonImageByTime]];
    [_skyWindow setImage:[CommonObject getSkyWindowImageByTime]];

    //起动时间监视
    [self startAlertTimerForSunMoonTime];
    
    
    //加载头像
    NSInteger wHeader = SCREEN_WIDTH/4;
    NSInteger hHeader = wHeader;
    NSInteger xHeader = SCREEN_WIDTH/2 - wHeader/2;
    NSInteger yHeadr  = SCREEN_HEIGHT - 10 - hHeader;
    if (!_userHeaderImageView) {
        _userHeaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xHeader, yHeadr, wHeader, hHeader)];
        [_userHeaderImageView.layer setCornerRadius:(_userHeaderImageView.frame.size.height/2)];
        _userHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_userHeaderImageView.layer setMasksToBounds:YES];
        [_userHeaderImageView setContentMode:UIViewContentModeScaleToFill];
        [_userHeaderImageView setClipsToBounds:YES];
        _userHeaderImageView.layer.shadowColor = [UIColor clearColor].CGColor;
        _userHeaderImageView.layer.shadowOffset = CGSizeMake(4, 4);
        _userHeaderImageView.layer.shadowOpacity = 0.5;
        _userHeaderImageView.layer.shadowRadius = 2.0;
        _userHeaderImageView.layer.borderColor = [UIColor colorWithRed:234.0/255.0 green:52.0/255.0 blue:7.0/255.0 alpha:1.0].CGColor;
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
    
    //加载头像横标
    if (!userHeaderSpiritBk) {
        UIImage* spiImage = [UIImage imageNamed:@"头像横标.png"];
        float rate = spiImage.size.width/spiImage.size.height;
        float w = _userHeaderImageView.frame.size.width;
        float h = w/rate;
        float x = _userHeaderImageView.frame.origin.x+_userHeaderImageView.frame.size.width/4*3;
        float y = _userHeaderImageView.frame.origin.y+_userHeaderImageView.frame.size.height/2 - h/2;
        userHeaderSpiritBk = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        userHeaderSpiritBk.image = spiImage;
        [self.view insertSubview:userHeaderSpiritBk belowSubview:_userHeaderImageView];
    
    }
    
    //加载精灵个数
    if (!spiritCountlabel) {
        float labelHeight = userHeaderSpiritBk.frame.size.height;
        float labelWidth = labelHeight;
        float x = userHeaderSpiritBk.frame.origin.x+userHeaderSpiritBk.frame.size.width/5*3;
        float y = userHeaderSpiritBk.frame.origin.y + userHeaderSpiritBk.frame.size.height/2 - labelHeight/2;
        spiritCountlabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelWidth,labelHeight)];
        [spiritCountlabel setBackgroundColor:[UIColor clearColor]];
        [spiritCountlabel setText:@"0"];
        [spiritCountlabel setTextAlignment:NSTextAlignmentCenter];
        [spiritCountlabel setFont:[UIFont systemFontOfSize:24.0f]];
        [spiritCountlabel setTextColor:[UIColor whiteColor]];
        [self.view insertSubview:spiritCountlabel aboveSubview:userHeaderSpiritBk];
    }
    
    //加载精灵图片
    if (!spiriteViewInUserHeader) {
        UIImage* spiImage = [CommonObject getStaticImageByLightType:[CommonObject getSpiriteTypeByTime]];
        float interWidthX = spiritCountlabel.frame.origin.x - (_userHeaderImageView.frame.origin.x+_userHeaderImageView.frame.size.width);
        float w = interWidthX * 2;
        float h = w;
        float x = _userHeaderImageView.frame.origin.x+_userHeaderImageView.frame.size.width + interWidthX/2 - w/2;
        float y = userHeaderSpiritBk.center.y - h/4*3;
        spiriteViewInUserHeader = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        spiriteViewInUserHeader.image = spiImage;
        [self.view insertSubview:spiriteViewInUserHeader aboveSubview:userHeaderSpiritBk];
        spiriteViewInUserHeader.hidden = YES;

    }
    
    
    //创建拖动轨迹识别
    panSunOrMoonGusture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePanSunOrMoon:)];
    [self.view addGestureRecognizer:panSunOrMoonGusture];

    
    //增加点击识别，进入拍照，或回归光到头像, 拖动也可让光回到头像
    //只设置点击 闪烁功能
    tapSunOrMoonGusture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSkySumOrMoonhandle:)];
    tapSunOrMoonGusture.numberOfTouchesRequired = 1;
    tapSunOrMoonGusture.numberOfTapsRequired = 1;
    _skySunorMoonImage.userInteractionEnabled = YES;
    [_skySunorMoonImage addGestureRecognizer:tapSunOrMoonGusture];
}




- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"---->viewWillAppear");

    [self.view.layer removeAllAnimations];



    //重取一次数
    [self.userInfo  getUserCommonData];

    self.navigationController.navigationBarHidden = YES;

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
        //如果是重新登录引起的变化，则变化已被执行过，此处是从其它界面而来引起的变化
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOCAL_NEED_CHANGE_UI object:self];
    }


    
    CGFloat cameraBtnHeight = _skySunorMoonImage.frame.size.width/4*2;
    CGFloat cameraBtnwidth = cameraBtnHeight;
    if (!_intoCameraBtn) {
        _intoCameraBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_intoCameraBtn setImage:[CommonObject getUsedCameraImageNameByTime:YES] forState:UIControlStateNormal];
        [_intoCameraBtn setFrame:CGRectMake(_skySunorMoonImage.center.x - cameraBtnwidth/2, _skySunorMoonImage.center.y - cameraBtnHeight/2, cameraBtnwidth, cameraBtnHeight)];
        [_intoCameraBtn addTarget:self action:@selector(intoCamera:) forControlEvents:UIControlEventTouchUpInside];
        [_intoCameraBtn setTag:TAG_INTO_CAMERA_BTN];
        [self.view addSubview:_intoCameraBtn];
        
    }

    
    
    
    //初始化头像闪烁动画图
    for (int i=0 ; i<7; i++) {
         lightUserHeader = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
        
        if (!lightUserHeader) {
            lightUserHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"空白图.png"]];
            lightUserHeader.tag = TAG_LIGHT_USER_HEADER+i;
            lightUserHeader.userInteractionEnabled=YES;
            lightUserHeader.contentMode=UIViewContentModeScaleToFill;
            lightUserHeader.hidden = YES;
            //[self.view addSubview:lightUserHeader];
            [self.view insertSubview:lightUserHeader belowSubview:userHeaderSpiritBk];
        }
        
    }


    
    //初始化日月动画图
    //不能放到veiwDidload 和viewWillapear中
    NSInteger IntervalWidth = 10;// 光环向日月外扩的宽度,日月的光晕较大
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
    
    
    [self refreshLightCircleStatForUserHeaderOrSunMoon];
    [self refreshIntoCameraBtnState];

    
    //从下一级view退回，不进行以下登录过程
    if (isFromLowView) {
        isFromLowView = FALSE;
        return;
    }
    
    //一定是照机回来的，不进行以下登录过程，待优化为判断从任何下一级进入的
    if (giveLingtCout!=0) {
        return;
    }

    //引导结束，执行一般打开状态
    if (guidInfo.guidStepNumber >guidStep_mainView_End)
    {
        [self whenCommonOpenViewHandle];
    }
    
    
    //始终保持两控件在最上面
    [self.view bringSubviewToFront:_intoCameraBtn];
    [self.view bringSubviewToFront:menuBtn];
  
    //判断是否起动引导滑屏
    [self  HandleGuidProcess:guid_Start];



}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    //防止动画的内存泄露
    [self.view.layer removeAllAnimations];

    
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    


    
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
    //第一个光回到头像，随后拖回天空
    [self.userInfo updateisBringUpSunOrMoon:NO];
    [self refreshLightCircleStatForUserHeaderOrSunMoon];
    [self refreshIntoCameraBtnState];
    //isGiveFirstLight = YES;//later
    giveLingtCout = 1;

    
    //启动第一个光的引导
    [self HandleGuidProcess:giudStep_guidFirstlyGiveLight];


    //更新光育成时间
    [self.userInfo updateSunorMoonBringupTime:[NSDate date]];

    NSLog(@"等待点击光环。。");
    
}

-(void)whenCommonOpenViewHandle
{
    //更新天空流程完成
    if (ToreFreshSky)ToreFreshSky = FALSE;
    
    
    //计算当前光和精灵的个数
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        [self caculateLightTypeAndCountByCount:userInfo.sun_value.integerValue];
        
    }else
    {
        [self caculateLightTypeAndCountByCount:userInfo.moon_value.integerValue];
        
    }
    NSInteger lightCount = [[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_LEFT_BASE_COUNT] integerValue];
    NSInteger spiriteCount = [[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue];
    
    //更新光环状态,和天空状态，需在计算奖励之间更新
    if ([self.userInfo checkIsBringUpinSunOrMoon]) {
        //如果是养育状态，且光没有在天空中，说明是新登录，则释放出光
        if ((lightCount!=0 && (!swimOutAnimationLightArray || swimOutAnimationLightArray.count ==0))
            ||(spiriteCount!=0&&(!swimOutAnimationSpiriteArray || swimOutAnimationSpiriteArray.count ==0)))
        {
            [self refreshLightStateForCallBackOrPopout:1];
        }else
        {
            //光在天空中，从后台进入的，天空不变,不做什么。。
            
        }
        
    }

    [self refreshLightCircleStatForUserHeaderOrSunMoon];
    [self refreshSpiritCountInHeaderView];
    
    //判断是否是新登录, 新登录，连续登录值置为1， 连续登录，连续值加1
    //连续登录可得阳光，月光值1个
    if (![self.userInfo checkLoginLastDateIsToday])
    {
        NSLog(@"当天新登录,更新当天照片未加光值");
        [self.userInfo updateIsHaveAddSunOrMoonValueForTodayPhoto:NO];

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
                [self showCustomYesAlertSuperView:@"阳光天空连续登录\n摘得一个阳光"  AlertKey:KEY_REMINDER_GIVE_LIGHT_FROM_CONTINUE_LOGIN];
            }else
            {
                [self showCustomYesAlertSuperView:@"月光天空连续登录\n摘得一个月光"  AlertKey:KEY_REMINDER_GIVE_LIGHT_FROM_CONTINUE_LOGIN];
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
    
    //更新状态,必须在处理登录判定后
    [self refreshIntoCameraBtnState];

}


-(void) checkIsTimeToFinishRefreshUI
{
    if (swimOutAnimationLightArray.count ==0 && swimOutAnimationSpiriteArray.count == 0) {
        
        //都飞回来了，开始其它新天空的更新更新
        [self whenCommonOpenViewHandle];
        
    }
    
    
}


//#pragma mark - AminationCustomDelegate
//
//- (void) animationFinishedRuturn:(NSString*) aniKey aniView:(UIImageView*) aniView
//{
//    if ([aniKey isEqualToString:@"simOutAnimation"]) {
//        
//    }
//    
//}

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


#pragma mark - 更新相机按钮状态
-(void) refreshIntoCameraBtnState
{

    if (![self.userInfo checkIsHaveAddSunOrMoonValueForTodayPhoto]) {

        NSLog(@"今天未得到过光的奖励,  相机提醒！");
        _intoCameraBtn.alpha = 1.0;
        if (guidInfo.guidIntoCamera_waitForTouch) {
            //引导完成之前，不启动提示
            [self endIndicationTouch];
            [self startIndicationTouch:_intoCameraBtn.center];
        }
        [_intoCameraBtn setImage:[CommonObject getUsedCameraImageNameByTime:YES] forState:UIControlStateNormal];
        

//        //移动相机到太阳
//        [UIView beginAnimations:@"MoveCameraToSunMoon" context:(__bridge void *)(_intoCameraBtn)];
//        [UIView setAnimationDuration:1.0f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(moveIntoCameraBtnAnimationDisStop:finished:context:)];
//        _intoCameraBtn.frame = alertRect;
//        [UIView commitAnimations];
        
        
    }else
    {

        
        NSLog(@"今天已得到过光的奖励！");
        _intoCameraBtn.alpha = 0.6;
        [self endIndicationTouch];
        [_intoCameraBtn setImage:[CommonObject getUsedCameraImageNameByTime:NO] forState:UIControlStateNormal];

//
//        //移动相机到太阳
//        [UIView beginAnimations:@"MoveCameraToSide" context:(__bridge void *)(_intoCameraBtn)];
//        [UIView setAnimationDuration:1.0f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(moveIntoCameraBtnAnimationDisStop:finished:context:)];
//        _intoCameraBtn.frame = inToCameraFrame;
//        [UIView commitAnimations];

    }
    
    [self.view bringSubviewToFront:_intoCameraBtn];

    
}


#pragma mark - 更新精灵个数显示状态
/**
 *  更新头像侧面精灵个数的显示
 */
-(void)refreshSpiritCountInHeaderView
{
    //计算当前光和精灵的个数
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        [self caculateLightTypeAndCountByCount:userInfo.sun_value.integerValue];
        
    }else
    {
        [self caculateLightTypeAndCountByCount:userInfo.moon_value.integerValue];
        
    }
    
    NSInteger currentSpiriteCount = [[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue];
    
    if (spiritCountlabel.text.integerValue == 0) {
        
        spiriteViewInUserHeader.hidden = NO;
        //[self animationSpiriteCountInHeaderChanged];
        spiritCountlabel.text = [NSString stringWithFormat:@"%lu", currentSpiriteCount];
    }else
    {
        if (currentSpiriteCount > spiritCountlabel.text.integerValue) {
            //闪烁提示数字变化
            [self animationSpiriteCountInHeaderChanged];
            [self showCustomDelayAlertBottom:[NSString stringWithFormat:NSLocalizedString(@"newCallSpiriteAlert", @""), currentSpiriteCount]];
        }
        
        spiritCountlabel.text = [NSString stringWithFormat:@"%lu", currentSpiriteCount];
    }
    
    //更新精灵图片
    spiriteViewInUserHeader.image = [CommonObject getStaticImageByLightType:[CommonObject getSpiriteTypeByTime]];
    
    
}

-(void)animationSpiriteCountInHeaderChanged
{
    
    //spiritCountlabel.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        //spiritCountlabel.transform = CGAffineTransformIdentity;
        spiritCountlabel.transform = CGAffineTransformMakeScale(3, 3);
        
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.3 animations:^{
            spiritCountlabel.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
   
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
        [self moveSimpleLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
        
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
-(void) startIndicationTouch:(CGPoint) aniPoint
{
  
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = aniPoint;
    self.halo.radius = 0.7 * kMaxRadius;
    self.halo.eerepeatCount = HUGE_VAL;
    self.halo.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
    [self.view.layer insertSublayer:self.halo below:_intoCameraBtn.layer];
    
    
}

-(void)endIndicationTouch
{    
    [self.halo removeFromSuperlayer];
 
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
//- (IBAction)getBringedUpLight:(id)sender
//{
//    
//    if ([self.userInfo checkIsBringUpinSunOrMoon]) {
//        //计算育成的时间，奖励光
//        //[self caculateAndGiveSunOrMoon:<#(NSString *)#>];
//    }
//
//
//    //[self callBackLight];
//    
//    //移除点击指示
//    [guidInfo RemoveTouchIndication];
//    
//    
//}



//
//-(void) isTimeProcessBackLight
//{
//    
//    //如果有光移动全部的光，回头像
//    if (([self.userInfo checkIsBringUpinSunOrMoon])) {
//        
//        NSLog(@"停光的育成，移动到头像！");
//        
//        [self moveSimpleLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
//        
//        isStartSunOrmoonImageMoveToHeaderAnimation = YES;
//        
//        [self.userInfo updateisBringUpSunOrMoon:NO];
//        
//        giveLingtCout = 0;
//        
//        NSString* temp =[NSString stringWithFormat:@"停止养育%@光",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
//        [self showCustomDelayAlertBottom:temp];
//        
//        
//        
//    }else
//    {
//        NSLog(@"ERROR: 没有光在育成, 无法召回！");
//        
//    }
//    
//    
//}


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


#pragma mark -  截屏分享

/**
 *  截屏分享
 *
 *  @param sender
 */
- (IBAction)screenShare:(id)sender
{

 
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareTitle = NSLocalizedString(@"appName", @"");
    share.shareImage =[CommonObject screenShot:self.view];
    //压缩图片
    share.shareImage = [CommonObject reduceImage:share.shareImage percent:0.4];

    share.shareImage = [CommonObject imageWithImageSimple:share.shareImage scaledToSize:CGSizeMake(320, 320*share.shareImage.size.height/share.shareImage.size.width)];
    
    share.shareMsg = [NSString stringWithFormat:NSLocalizedString(@"CutScreenShareMsg", @""), [CommonObject getLightCharactorByTime]];
    share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
    share.shareMsgPreFix  = [NSString stringWithFormat:NSLocalizedString(@"MySkyInfo", @""), [CommonObject getLightCharactorByTime], [self.userInfo getMaxuserValueByTime],[CommonObject getLightCharactorByTime],[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue],[CommonObject getLightCharactorByTime]];
    
    share.customDelegate = self;
    
    [share shareImageNews];

}

//delegate
-(void) ShareStart
{
    
    [indicatorView startAnimating];
}

-(void) ShareCancel
{
    
    [indicatorView stopAnimating];
    
    [self showCustomDelayAlertBottom:@"取消分享"];
}

-(void) ShareReturnSucc
{
    
    [indicatorView stopAnimating];
    
    
    [self showCustomDelayAlertBottom:@"分享成功"];
    
}

-(void) ShareReturnFailed
{
    [indicatorView stopAnimating];
    
    [self showCustomYesAlertSuperView:@"分享失败\n请检查网络" AlertKey:@"shareFailed"];
}



//增加用户信息时，才会调用，删除鉴权时不会
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSMutableDictionary *item = [_shareTypeArray objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
        }else
        {
            //取消另一个授权，保持只有一个
            [ShareSDK cancelAuthWithType:type];
            
        }
    }
    
    
    //存用户授权信息
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",userDir]];
    if (authList == nil)
    {
        authList = [NSMutableArray array];
    }
    
    NSString *platName = nil;
    //NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    switch (plat)
    {
        case ShareTypeSinaWeibo:
            platName = NSLocalizedString(@"TEXT_SINA_WEIBO", @"新浪微博");
            break;
            
        case ShareTypeTencentWeibo:
            platName = NSLocalizedString(@"TEXT_TENCENT_WEIBO", @"腾讯微博");
            break;
            
        default:
            platName = NSLocalizedString(@"TEXT_UNKNOWN", @"未知");
    }
    
    //id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists)
    {
        NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 platName,
                                 @"title",
                                 [NSNumber numberWithInteger:plat],
                                 @"type",
                                 [userInfo nickname],
                                 @"username",
                                 nil];
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",userDir] atomically:YES];
    
    
    //更新本地用户信息
    [self.userInfo updateSns_ID:[userInfo uid] PlateType:[userInfo type]];
    [self.userInfo updateuserName:[userInfo nickname]];
    
    NSURL *portraitUrl = [NSURL URLWithString:[userInfo profileImage]];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [self.userInfo updateUserHeaderImage:protraitImg];
    
}



- (IBAction)intoCamera:(id)sender {
    
    //如有引导提示，删除
    [self.haloToReminber removeFromSuperlayer];
    [guidTouchIntoCameraAni removeAniLayer];
    
    
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
    
    NSLog(@"Guid Step input=%u, current should be = %lu", guidNeedNum, guidInfo.guidStepNumber);
    
    //判断是否已执行过，执行过则返回，未执行过继续顺次执行
    //引导耦合性太强，中间不能断，断了无法从上次断的地方执行，也无法进入whenCommonOpenViewHandle,待优化
    switch (guidNeedNum) {
        case guid_Start:
            if(guidInfo.guidStart && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case guid_finishIntro_Start_firstOpen:
            if(guidInfo.guidFinishIntroStartFirstOpen && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case giudStep_guidFirstlyGiveLight:
            if(guidInfo.guidFirstlyGiveLight && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case giudStep_guidPanToBring:
            if(guidInfo.guidPanToBring && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case giudStep_guidPanToBring_waitForPan:
            if(guidInfo.guidPanToBring_waitForPan && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case guidGet_spirite_count:
            if(guidInfo.guidGet_spirite_count && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case guidStep_guidIntoCamera:
            if(guidInfo.guidIntoCamera && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case guidStep_guidIntoCamera_waitForTouch:
            if(guidInfo.guidIntoCamera_waitForTouch && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        case guidStep_mainView_End:
            if(guidInfo.mainView_End && guidInfo.guidStepNumber > guidStep_mainView_End)return;
            break;
            
        default:
            break;
            
    }
    
    
    
     if (guidNeedNum == guidInfo.guidStepNumber)
     {
         //执行当前步
         switch (guidInfo.guidStepNumber) {
         case guid_Start:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         //起动滑动引导
         [self showIntroWithCrossDissolve];
         
         [guidInfo setGuidStart:YES];
         }
         
         break;
         case guid_finishIntro_Start_firstOpen:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         //第一打开界面
         [self whenFirstlyOpenViewHandle];
         
         [guidInfo setGuidFinishIntroStartFirstOpen:YES];
         
         }
         break;
         case giudStep_guidFirstlyGiveLight:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
         
         NSString* temp = [NSString stringWithFormat:@"首次登录\n摘得一个%@光\n",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
         [self showCustomYesAlertSuperView:temp AlertKey:KEY_IS_GIVE_FIRST_LIGHT];
         
         [guidInfo setGuidFirstlyGiveLight:YES];
         
         }
         break;
         
         case giudStep_guidPanToBring:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         //禁止所有动作
         [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
         
         NSString* alTemp = [NSString stringWithFormat:(@"拖动%@光到%@\n%d小时养成1个%@光\n也可以拖回头像"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"太阳":@"月亮",BRING_UP_LIGHT_HOUR,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
         [self showCustomYesAlertSuperView:alTemp AlertKey:KEY_REMINDER_PAN_FOR_LIGHT];
         
         [guidInfo setGuidPanToBring:YES];
         
         
         }
         break;
         case giudStep_guidPanToBring_waitForPan:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         //禁止除拖动以外的所有动作(点OK时，会再次被打开,故需再一次)
         [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
         
         
         //增加拖动指示
         guidPanToSkyAni = [self addPanLightToSkyGuidAnimationFrom:_userHeaderImageView.center toEnd:_skySunorMoonImage.center withAniKey:KEY_ANIMATION_GUID_PAN_LIGHT_TO_SKY duration:1.5];
             
         
         //打开self.view的拖动，点OK后打开
         //panSunOrMoonGusture.enabled = YES;
         [self.view addGestureRecognizer:panSunOrMoonGusture];
         
         [guidInfo setGuidPanToBring_waitForPan:YES];
         }
         break;
         case guidGet_spirite_count:
         {
             [guidInfo setGuidStepNumber:guid_oneByOne];
             [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];

             //增加精灵数提示
             self.haloToReminber = [PulsingHaloLayer layer];
             self.haloToReminber.position = spiritCountlabel.center;
             self.haloToReminber.radius = 0.6 * kMaxRadius;
             self.haloToReminber.animationDuration = 0.8;
             self.haloToReminber.pulseInterval = 0.8;
             self.haloToReminber.eerepeatCount = HUGE_VAL;
             self.haloToReminber.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
             [self.view.layer addSublayer:self.haloToReminber];
             
             NSString* temp = [NSString stringWithFormat:NSLocalizedString(@"reminderHowToGetSpirite", @""),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
             [self showCustomYesAlertSuperView:temp AlertKey:KEY_REMINDER_HOW_TO_GET_SPIRITE];
             
             [guidInfo setGuidGet_spirite_count:YES];
             
         }
             break;
         case guidStep_guidIntoCamera:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         //禁止所有动作
         [self DisableUserInteractionInView:self.view exceptViewWithTag:BIGGEST_NUMBER];
             
          guidTouchIntoCameraAni = [self addGuidTouchAnimationAtPoint:_intoCameraBtn.center withAniKey:KEY_ANIMATION_GUID_TOUCH_CAMEREA];
         
         NSString* temp = [NSString stringWithFormat:@"进入相机\n说出你的%@光宣言",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
         [self showCustomYesAlertSuperView:temp AlertKey:KEY_REMINDER_GETINTO_CAMERA];
             
         [guidInfo setGuidIntoCamera:YES];
         
         }
         break;
         case guidStep_guidIntoCamera_waitForTouch:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         [self DisableUserInteractionInView:self.view exceptViewWithTag:TAG_INTO_CAMERA_BTN];

         self.haloToReminber = [PulsingHaloLayer layer];
         self.haloToReminber.position = _intoCameraBtn.center;
         self.haloToReminber.radius = 0.8 * kMaxRadius;
         self.haloToReminber.animationDuration = 0.8;
         self.haloToReminber.pulseInterval = 0.8;
         self.haloToReminber.eerepeatCount = HUGE_VAL;
         self.haloToReminber.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
         [self.view.layer addSublayer:self.haloToReminber];
         
         [guidInfo setGuidIntoCamera_waitForTouch:YES];
         
         }
         break;
         case guidStep_mainView_End:
         {
         [guidInfo setGuidStepNumber:guid_oneByOne];
         
         
         //主界面引导结束,打开所有的
         [self EnableUserInteractionInView:self.view];
         
         [guidInfo setMainView_End:YES];
         
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

-(CustomAnimation*) addPanLightToSkyGuidAnimationFrom:(CGPoint) start toEnd:(CGPoint)end withAniKey:(NSString*)aniKey duration:(CGFloat) duration
{
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    //计算此精灵的最终位置
    CGPoint startPoint =start;
    CGPoint endPoint =end;
    //计算此精灵的最终大小
    CGSize  startSize = CGSizeMake(SCREEN_WIDTH/3, SCREEN_WIDTH/3);
    CGSize endSize = startSize;
    
    [customAnimation setAniBazierCenterPoint1:CGPointMake(self.view.center.x+30, self.view.center.y)];
    
    UIImageView* srcView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch.png"]];
    srcView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:srcView];
    
    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcView, KEY_ANIMATION_VIEW,
                                [NSNumber numberWithInteger:(LightType)guidImageTouch], KEY_ANIMATION_LIGHT_TYPE,nil];
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniRepeatCount:HUGE_VAL];
    [customAnimation setAniDuration:duration];
    
    [customAnimation startCustomAnimation];
    
    return customAnimation;
    
}


-(CustomAnimation*) addGuidTouchAnimationAtPoint:(CGPoint)touchPoint  withAniKey:(NSString*)aniKey
{
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    //计算此精灵的最终位置
    CGPoint startPoint =touchPoint;
    CGPoint endPoint =touchPoint;
    CGSize  startSize = CGSizeMake(SCREEN_WIDTH/3, SCREEN_WIDTH/3);
    CGSize endSize = startSize;
    
    [customAnimation setAniBazierCenterPoint1:touchPoint];
    
    UIImageView* srcView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"touch.png"]];
    srcView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview:srcView];
    
    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcView, KEY_ANIMATION_VIEW,
                                [NSNumber numberWithInteger:(GuidImageType)guidImageTouch], KEY_ANIMATION_LIGHT_TYPE,nil];
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniRepeatCount:HUGE_VAL];
    [customAnimation setAniDuration:1];
    
    [customAnimation setAniImageFrameCount:2];
    [customAnimation setAniImageArrayType:guidImageTouch];
    [customAnimation displayLinkAnimationEnable];
    
    [customAnimation startCustomAnimation];
    
    return customAnimation;
    
}

-(void)removePanLightToSkyGuidAnimation
{
    
    
}

#pragma mark - userInterFace Disable, Enable
-(void)DisableUserInteractionInView:(UIView *)superView exceptViewWithTag:(NSInteger)enableViewTag
{
    
    
    if (!alreadyDisable) {
        NSLog(@"----DisableUserInteractionInView");
        [CommonObject DisableUserInteractionInView:superView exceptViewWithTag:enableViewTag];
        
        //其它需要禁止的
        //panSunOrMoonGusture.enabled = NO;
        [self.view removeGestureRecognizer:panSunOrMoonGusture];
        //tapSunOrMoonGusture.enabled = NO;
        [_skySunorMoonImage removeGestureRecognizer:tapSunOrMoonGusture];
        //tapHeaderView.enabled = NO;
        [_userHeaderImageView removeGestureRecognizer:tapHeaderView];

        alreadyDisable = YES;
    }else
    {
        NSLog(@"----alreadyDisable, can not DisableUserInteractionInView");

    }

}

-(void)DisableUserInteractionAllView:(UIView *)superView
{
    [superView setUserInteractionEnabled:NO];
    
}

-(void)EnableUserInteractionInView:(UIView *)superView
{
    
    NSLog(@"*****EnableUserInteractionInView");

    [CommonObject EnableUserInteractionInView:self.view];
    
    //panSunOrMoonGusture.enabled = YES;
    //tapSunOrMoonGusture.enabled = YES;
    //tapHeaderView.enabled = YES;
    
    [self.view addGestureRecognizer:panSunOrMoonGusture];
    [_skySunorMoonImage addGestureRecognizer:tapSunOrMoonGusture];
    [_userHeaderImageView addGestureRecognizer:tapHeaderView];


    alreadyDisable = NO;

}

-(void)EnableUserInteractionAllView:(UIView *)superView
{
    [superView setUserInteractionEnabled:YES];

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
        
        if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
            [self showCustomYesAlertSuperView:@"完成阳光自拍\n摘得一个阳光"  AlertKey:KEY_REMINDER_GIVE_LIGHT_FROM_CAMERA];
        }else
        {
            [self showCustomYesAlertSuperView:@"完成月光自拍\n摘得一个月光"  AlertKey:KEY_REMINDER_GIVE_LIGHT_FROM_CAMERA];
        }


    }
    
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
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];

    if ([[notification name] isEqualToString:NOTIFY_LOCAL_NEED_CHANGE_UI])
    {
        
        [UIView beginAnimations:@"reFreshSunMoonUI_DisPre" context:(__bridge void *)(mainBgImage)];
        [UIView setAnimationDuration:1.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
        NSLog(@"Disapear old UI : %@", [mainBgImage.image description]);
        if ([CommonObject checkSunOrMoonTime] != [userBaseData integerForKey:KEY_BACK_GROUND_TIME_SUNMOON]) {
            //如果日月有变化，才变天背景
            mainBgImage.alpha = 0.8;

        }
        [UIView commitAnimations];
        
        
        //如果有光在天空,先召回
        ToreFreshSky =  TRUE;
        if (([CommonObject checkSunOrMoonTime] != [userBaseData integerForKey:KEY_BACK_GROUND_TIME_SUNMOON])
            &&
            ((swimOutAnimationLightArray&&swimOutAnimationLightArray.count !=0) || (swimOutAnimationSpiriteArray&&swimOutAnimationSpiriteArray.count !=0))) {
            //如果日月变化，且原天空有光，则召回光
            //完成飞回光到太阳动画后，再更新其它界面元素
            [self refreshLightStateForCallBackOrPopout:0];

        }else
        {
            //如日月无变化，则不需要召回现有的天空光，但需更新计算其它的
            [self whenCommonOpenViewHandle];
        }
        
        //更新记录后台时的时间
        [userBaseData setObject:[CommonObject getCurrentDate] forKey:KEY_BACK_GROUND_TIME];
        [userBaseData setInteger:[CommonObject checkSunOrMoonTime] forKey:KEY_BACK_GROUND_TIME_SUNMOON];
        [userBaseData synchronize];

    }
    
}



- (void)reFreshSunMoonUIAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_DisPre"]) {
        
        
        [UIView beginAnimations:@"reFreshSunMoonUI_ShowNew" context:(__bridge void *)(mainBgImage)];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(reFreshSunMoonUIAnimationDidStop:finished:context:)];
        
        
        [mainBgImage setImage:[CommonObject getSkyBkImageByTime]];
        [_skySunorMoonImage setImage:[CommonObject getSunMoonImageByTime]];
        [_skyWindow setImage:[CommonObject getSkyWindowImageByTime]];

        [self refreshIntoCameraBtnState];
        
        NSLog(@"Change new  UI to %@", [mainBgImage.image description]);

        
        mainBgImage.alpha = 1.0;
        [UIView commitAnimations];

    }
    
    
    if ([animationID isEqualToString:@"reFreshSunMoonUI_ShowNew"]) {
        

        
    }
    
}


//#pragma mark -  getter
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
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [bowLightView startAnimating];
    }

}


#pragma mark 拖动识别
- (void)HandlePanSunOrMoon:(UIPanGestureRecognizer *)gestureRecognizer {
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if ([self.userInfo.sun_value integerValue]==0  ) {
            NSLog(@"sun_value==0 handlePan return");
            return;
        }
        
        //_panSunorMoonImageView.image =[CommonObject getBaseLightImageByTime];
        
    }else
    {
        if ([self.userInfo.moon_value integerValue] == 0) {
            NSLog(@"moon_value==0 handlePan return");
            return;
        }
        //_panSunorMoonImageView.image =[CommonObject getBaseLightImageByTime];

        
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
//                _panSunorMoonImageView.center = _userHeaderImageView.center;
//                _panSunorMoonImageView.alpha = 1.0;
//                _panSunorMoonImageView.hidden =  YES;
                
            }else
            {
                NSLog(@" 开始拖动手势： 起点：头像之外！");
                isFromHeaderBegin = NO;
            }
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {

            
            if (isFromHeaderBegin) {
//                _panSunorMoonImageView.hidden =  YES;
//                _panSunorMoonImageView.center = location;
//                _panSunorMoonImageView.alpha = 1.0;
                
                panTracelight = [[UIImageView alloc] initWithImage:[CommonObject getBaseLightImageByTime]];
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

                    //刷新光到天空
                    [self refreshLightStateForCallBackOrPopout:1];
                   
                    //先更新为有光在育成，再动画，否则会判断无光在养成，后续流程被终止
                    [self.userInfo updateisBringUpSunOrMoon:YES];
                    [self refreshLightCircleStatForUserHeaderOrSunMoon];
                    //更新光育成时间
                    [self.userInfo updateSunorMoonBringupTime:[NSDate date]];

//                    NSString* time = [NSString stringWithFormat:@"开始养育%@光了", ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
//                    NSLog(@"%@", time);
//                    [self showCustomDelayAlertBottom:time];
                    
                    //消除拖动指示
                    [guidPanToSkyAni removeAniLayer];

                    
                    
                }else
                {
                    NSLog(@"不是从 头像 开始！");

                }
                
                isFromHeaderBegin = NO;
                
                
            }else
            {
                
                NSLog(@" 结束拖动手势： 终点：日月之外, 回到头像！");
                //需以头像为起点
                if (isFromHeaderBegin) {
                    
                    //回到头像里动画
                    NSMutableArray * twoPointArray = [self getSeveralTracePointFromPan:2];
                    [self moveSimpleLightWithRepeatCount:1 StartPoint:location EndPoint:_userHeaderImageView.center totalTime:1  aniKey:KEY_ANIMATION_PAN_TO_SKY_FAILED_TO_USERHEADER withBazierP1:[[twoPointArray objectAtIndex:0] CGPointValue] bazierP2:[[twoPointArray objectAtIndex:1] CGPointValue]];

                    
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
//                _panSunorMoonImageView.center = _skySunorMoonImage.center;
//                _panSunorMoonImageView.alpha = 1.0;
//                _panSunorMoonImageView.hidden =  YES;
                
                
            }else
            {
                NSLog(@" 开始拖动手势： 起点：日月之外！");
                isFromSunMoonBegin = NO;
            }
            
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
        {


            if (isFromSunMoonBegin) {
                
//                _panSunorMoonImageView.center = location;
//                _panSunorMoonImageView.alpha = 1.0;
//                _panSunorMoonImageView.hidden = YES;
                panTracelight = [[UIImageView alloc] initWithImage:[CommonObject getBaseLightImageByTime]];
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
                    
                    if ([self caculateAndGiveSunOrMoon:KEY_REMINDER_GIVE_LIGHT_FROM_PAN_TO_USERHEADER]>0)
                    {
                        //等待用户点击OK后，光再返回头像
                    }else
                    {
                        
                        //无奖励，光直接返回头像
                        [self refreshLightStateForCallBackOrPopout:0];
                        //更新为光无养育
                        [self.userInfo updateisBringUpSunOrMoon:NO];
                        [self refreshLightCircleStatForUserHeaderOrSunMoon];


                    }
                    

                    


                    
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
                    NSMutableArray * twoPointArray = [self getSeveralTracePointFromPan:2];
                    [self moveSimpleLightWithRepeatCount:1 StartPoint:location EndPoint:_skySunorMoonImage.center totalTime:1 aniKey:KEY_ANIMATION_PAN_TO_USERHEADER_FAILED_TO_SKY withBazierP1:[[twoPointArray objectAtIndex:0] CGPointValue] bazierP2:[[twoPointArray objectAtIndex:1] CGPointValue]];
                    
                    //isStartSunOrmoonImageMoveToSunMoonAnimation = YES;

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
            //不参remove，其还要用于取关键点
        }

    }
    
    
    
    [gestureRecognizer setTranslation:location inView:self.view];

    
}

/**
 *  从拖动痕迹中取几个关键点
 *
 *  @return 关键点的位置
 */
-(NSMutableArray*)getSeveralTracePointFromPan:(NSInteger) count
{
    if (count == 0) {
        return nil;
    }
    
    NSMutableArray*  pointArray = [NSMutableArray arrayWithCapacity:count];
    
    for (NSInteger i=0; i<count; i++) {

        NSInteger keyTag = TAG_LIGHT_TRACE+panTraceligntTag/(count+1) *(i+1);
        
        UIImageView* tempTrace = (UIImageView*)[self.view viewWithTag:keyTag];
        
        [pointArray addObject:[NSValue valueWithCGPoint:tempTrace.center]];
        
    }
    
    return pointArray;
    
    
}

#pragma mark - 光的动画控制函数
/**
 *  贝塞尔 曲线游动而出
 *
 *  @param count 最大为2，不能为0
 */
-(void) animationLightSwimOutBazierLightType:(LightType) type srcView:(UIImageView*) srcView  startFrame:(CGRect) startF endFrame:(CGRect) endF  number:(NSInteger) number aniKey:(NSString*)aniKey
{
    
    NSMutableArray* posionArry = [self getRadomPosionWithSize:CGSizeMake(15, 15) inFrame:CGRectMake(0, 0+SCREEN_HEIGHT/4, SCREEN_WIDTH, SCREEN_HEIGHT/4*2) exceptFrame:_skySunorMoonImage.frame Count:2];

    
    if (!posionArry) {
        return;
    }
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    //存动画队列,收回，或换天时清空
    [self addAnimationToArray:aniKey lightType:type aniObject:customAnimation];

    
    //计算此精灵的最终位置
    CGPoint startPoint =CGPointMake(CGRectGetMidX(startF), CGRectGetMidY(startF));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(endF), CGRectGetMidY(endF));
    //计算此精灵的最终大小
    CGSize  startSize = startF.size;
    CGSize endSize = endF.size;
    
    if (type == lightTypeWhiteSpirite || type == lightTypeYellowSpirte) {
        CGRect bazier_1 = [[posionArry objectAtIndex:0] CGRectValue];
        CGPoint bazierPoint_1 = CGPointMake(bazier_1.origin.x, bazier_1.origin.y);
        
        [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
        
        CGRect bazier_2 = [[posionArry objectAtIndex:1] CGRectValue];
        CGPoint bazierPoint_2 = CGPointMake(bazier_2.origin.x, bazier_2.origin.y);
        
        [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    }else
    {

        CGPoint bazierPoint_1 = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
        
        [customAnimation setAniBazierCenterPoint1:bazierPoint_1];

        CGPoint bazierPoint_2 = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
        
        [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    }
    

    
    
    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcView, KEY_ANIMATION_VIEW,
                                [NSNumber numberWithInteger:type], KEY_ANIMATION_LIGHT_TYPE,nil];
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniRepeatCount:1];
    
    float duration = POP_OUT_ONE_ANIMATION_TIME * ((float)number+1)/(number+2);
    
    [customAnimation setAniDuration:duration];
    
    [customAnimation setSipiriteAnimationType:type];
    [customAnimation displayLinkAnimationEnable];
    
    [customAnimation startCustomAnimation];

    
}

/**
 *  光游动而出，再返回, 关键帧动画
 *
 *  @param count 随机关键帧点的个数,不包括开始点,与结束点
 */
-(void) animationLightSwimOutKeyFrameCount:(NSInteger) count lightType:(LightType) type srcView:(UIImageView*) srcView aniKey:(NSString*) aniKey
{
    
    NSMutableArray* posionArry = [self getRadomPosionWithSize:CGSizeMake(15, 15) inFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-300) exceptFrame:_skySunorMoonImage.frame Count:count];
    if (!posionArry) {
        return;
    }
    
    CustomAnimation* animation = [[CustomAnimation alloc] initCustomAnimation];
    
    [self addAnimationToArray:aniKey lightType:type aniObject:animation];
    
    CGPoint startPoint = _skySunorMoonImage.center;
    CGPoint endPoint =CGPointMake([CommonObject getRandomNumber:0+15 to:SCREEN_WIDTH-15], [CommonObject getRandomNumber:0+15 to:SCREEN_HEIGHT-_userHeaderImageView.frame.size.height]);
    
    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcView, KEY_ANIMATION_VIEW,
                                [NSNumber numberWithInteger:type], KEY_ANIMATION_LIGHT_TYPE,nil];
    
    [animation setAniType:KEY_FRAME_POSION_TYPE];
    [animation setAniImageViewDic:srcViewDic];
    [animation setBkLayer:self.view.layer];
    [animation setAniStartSize:CGSizeMake(60, 60)];
    [animation setAniStartPoint:startPoint];
    [animation setAniEndpoint:endPoint];
    [animation setAniEndSize:CGSizeMake(60, 60)];
    [animation setCustomAniDelegate:self];
    [animation setAnikey:aniKey];
    [animation setAniRepeatCount:1];
    [animation setAniDuration:POP_OUT_ONE_ANIMATION_TIME];
    
    [animation setAniKeyframePointCount:count];

    for (int i=0; i<count; i++) {
        
        //关键帧点
        CGRect rectSrc =[[posionArry objectAtIndex:i] CGRectValue];
        CGPoint pointKey = CGPointMake(rectSrc.origin.x, rectSrc.origin.y);
        [animation setAniKeyframePoint:pointKey];
        
    }
    
    [animation startCustomAnimation];

}




-(void) animationLightSwimBackKeyFrameWithAni:(CustomAnimation*) srcAni aniKey:(NSString*) aniKey number:(NSInteger) num
{
    
        UIImageView* aniView = (UIImageView*)[srcAni.aniImageViewDic objectForKey:KEY_ANIMATION_VIEW];
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    LightType type = (LightType)[(NSNumber*)[srcAni.aniImageViewDic objectForKey:KEY_ANIMATION_LIGHT_TYPE] integerValue];
    
    CGPoint startPoint = aniView.center;
    CGPoint endPoint = _skySunorMoonImage.center;

    //计算此精灵的最终大小
    CGSize startSize;
    CGSize endSize;
    if (type == lightTypeWhiteSpirite || type == lightTypeYellowSpirte) {
        startSize = CGSizeMake(SPIRITE_W_H, SPIRITE_W_H);
        endSize = CGSizeMake(SPIRITE_W_H, SPIRITE_W_H);
    }else
    {
        startSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
        endSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
    }

    
    CGPoint bazierPoint_1;
    CGPoint bazierPoint_2;
    //取得两点之间的中间点
    CGPoint mid1 = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
    bazierPoint_1 = CGPointMake(mid1.x/3 -[CommonObject getRandomNumber:0 to:10], mid1.y/3 -[CommonObject getRandomNumber:0 to:10]);
    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
    CGPoint mid2 = [CommonObject getMidPointBetween:mid1 andPoint:endPoint];
    bazierPoint_2 = CGPointMake(mid2.x -[CommonObject getRandomNumber:20 to:40], mid2.y -[CommonObject getRandomNumber:20 to:40]);
    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcAni.aniImageViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniRepeatCount:1];
    float duration = POP_BACK_ONE_ANIMATION_TIME * ((float)num+1)/(num+2);
    [customAnimation setAniDuration:duration];
    
    [customAnimation setSipiriteAnimationType:type];
    [customAnimation displayLinkAnimationEnable];
    
    [customAnimation startCustomAnimation];
    

}


-(void) animationSpiriteFlyTraceWithAni:(CustomAnimation*) srcAni aniKey:(NSString*) aniKey number:(NSInteger) num startP:(CGPoint) start endP:(CGPoint)end
{
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    LightType type = (LightType)[(NSNumber*)[srcAni.aniImageViewDic objectForKey:KEY_ANIMATION_LIGHT_TYPE] integerValue];
    
    CGPoint startPoint = start;
    CGPoint endPoint =end;

    //计算此精灵的最终大小
    CGSize  startSize = CGSizeMake(SPIRITE_W_H, SPIRITE_W_H);
    CGSize endSize = CGSizeMake(SPIRITE_W_H, SPIRITE_W_H);
    
    CGPoint bazierPoint_1;
    CGPoint bazierPoint_2;
    //取得两点之间的中间点
    CGPoint mid1 = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
    bazierPoint_1 = CGPointMake(mid1.x/3 -[CommonObject getRandomNumber:0 to:10], mid1.y/3 -[CommonObject getRandomNumber:0 to:10]);
    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
    CGPoint mid2 = [CommonObject getMidPointBetween:mid1 andPoint:endPoint];
    bazierPoint_2 = CGPointMake(mid2.x -[CommonObject getRandomNumber:20 to:40], mid2.y -[CommonObject getRandomNumber:20 to:40]);
    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcAni.aniImageViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniRepeatCount:1];
    float duration;
    if ([aniKey isEqualToString:KEY_ANIMATION_SPIRITE_FLY_TRACE_TOUCH]) {
        duration = SPIRITE_FLY_TIME_TOUCH * ((float)num+1)/(num+2);
    }else if([aniKey isEqualToString:KEY_ANIMATION_SPIRITE_FLY_AUTO])
    {
        duration = SPIRITE_FLY_TIME_AUTO * ((float)num+1)/(num+2);

    }
    
    
    [customAnimation setAniDuration:duration];
    
    [customAnimation setSipiriteAnimationType:type];
    [customAnimation displayLinkAnimationEnable];
    
    [customAnimation startCustomAnimation];

    
    
}


/**
 *  起点位置左右随机变动位置
 *
 *  @param aroundView 运动的view
 */
-(void) animationLightSwimAround:(NSDictionary*) aroundViewDic
{

    
    UIImageView* aroundView = (UIImageView*)[aroundViewDic objectForKey:KEY_ANIMATION_VIEW];
    LightType type =(LightType)[(NSNumber*)[aroundViewDic objectForKey:KEY_ANIMATION_LIGHT_TYPE] integerValue];
    
    //待修改:不在走游动动画
    aroundView.hidden = NO;
    [self.view insertSubview:aroundView belowSubview:_lightPostionFrame];
    return;

    //当前位置为起点
    CGPoint startPoint = CGPointMake(aroundView.frame.origin.x+aroundView.frame.size.width/2, aroundView.frame.origin.y+aroundView.frame.size.height/2);
    //30像素范围内随机变化
   // CGPoint endPoint = CGPointMake(startPoint.x+[CommonObject getRandomNumber:0 to:30], startPoint.y+[CommonObject getRandomNumber:0 to:30]);
    CGPoint endPoint = startPoint;
    
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    //只让最后一个精灵游动
    if (type == lightTypeYellowSpirte || type == lightTypeWhiteSpirite) {
        
       //[customAnimation setAniBazierCenterPoint1:CGPointMake(startPoint.x+[CommonObject getRandomNumber:-SWIM_AROUND_SPIRITE_DISTANCE to:SWIM_AROUND_SPIRITE_DISTANCE], startPoint.y+[CommonObject getRandomNumber:-SWIM_AROUND_SPIRITE_DISTANCE to:SWIM_AROUND_SPIRITE_DISTANCE])];
        if (aroundView == ((UIImageView*)swimOutSpiriteImageViewArray.lastObject))
        {
            [customAnimation setAniBazierCenterPoint1:CGPointMake(startPoint.x+[CommonObject getRandomNumber:-SWIM_AROUND_SPIRITE_DISTANCE to:SWIM_AROUND_SPIRITE_DISTANCE], startPoint.y+[CommonObject getRandomNumber:-SWIM_AROUND_SPIRITE_DISTANCE to:SWIM_AROUND_SPIRITE_DISTANCE])];
        }else
        {
            
            return;
        }
    }else
    {
        [customAnimation setAniBazierCenterPoint1:CGPointMake(startPoint.x+[CommonObject getRandomNumber:-SWIM_AROUND_LIGHT_DISTANCE to:SWIM_AROUND_LIGHT_DISTANCE], startPoint.y+[CommonObject getRandomNumber:-SWIM_AROUND_LIGHT_DISTANCE to:SWIM_AROUND_LIGHT_DISTANCE])];
    }


    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setBkLayerBelow:_lightPostionFrame.layer];
    [customAnimation setAniStartSize:aroundView.frame.size];
    [customAnimation setAniEndSize:aroundView.frame.size];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniImageViewDic:aroundViewDic];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:KEY_ANIMATION_SWIM_AROUND];
    [customAnimation setAniRepeatCount:1];
    [customAnimation setAniDuration:SWIM_AROUND_LIGHT_TIME];
    
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setSipiriteAnimationType:type];
    [customAnimation displayLinkAnimationEnable];

    
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
    int start_x = inFrame.origin.x+ size.width/2;
    int end_x = inFrame.origin.x+inFrame.size.width - size.width/2;

    
    int start_y = inFrame.origin.y+size.height/2;
    int end_y = inFrame.origin.y+inFrame.size.height - size.height/2;
    
    
    //获取随机frame
    NSMutableArray * radomPosionArray = [NSMutableArray arrayWithCapacity:count];
    for (int i =0 ; i<count; i++) {
        //随机x
        int radomX = [CommonObject getRandomNumber:start_x to:end_x];

        //随机y
        int radomY = [CommonObject getRandomNumber:start_y to:end_y];

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

/**
 *  获取排列的位置,每行5个，从下到上依次减小精灵
 *
 *  @param count 需要位置的个数
 *
 *  @return <#return value description#>
 */
-(NSMutableArray*)getLineArrayPosion:(NSInteger)count
{

    //存位置与大小
    NSMutableArray* spiFrameArray = [NSMutableArray arrayWithCapacity:count];

    /*类似如下排列
        |-[_]--[_]--[_]--[_]--[_]-|
       |-[__]--[__]--[__]--[__]--[__]-|
     |-[___]--[___]--[___]--[___]--[___]-|
     */

    //计算位置
    CGRect  containFrame = CGRectMake(0, 0, SCREEN_WIDTH, _intoCameraBtn.frame.origin.y);
    NSInteger interDis = 2;//精灵间隔,每个精灵之间有4，一边各一个
    NSInteger countInLine = 5;//每行个数,固定
    NSInteger decrease = 10;//每行精灵减小的像素
    NSInteger everyWidth ;//每个精灵所占用的宽度，变化
    NSInteger lineCount; //第几行
    NSInteger lineSumcount;//总行数
    NSInteger spiWid;//精灵的宽，长=宽
    CGPoint spiPoint;//精灵中心点的位置
    CGSize  spiSize;//精灵的大小
    CGRect spiFrame ;//精灵的frame;
    
    //第一行
    everyWidth = SCREEN_WIDTH/countInLine;
    spiWid = everyWidth - interDis*2;
    lineCount = 1;
    for (int i = 0; i<countInLine; i++) {
        //x位置是第（i+1）个everyWidth 后移everyWidth的一半，y是spiWid的一半
        spiPoint = CGPointMake(everyWidth*(i+1)-everyWidth/2, containFrame.size.height - spiWid/2);
        
        spiSize = CGSizeMake(spiWid, spiWid);
        
        spiFrame = CGRectMake(spiPoint.x - spiSize.width/2, spiPoint.y - spiSize.height/2, spiSize.width, spiSize.height);
        [spiFrameArray addObject:[NSValue valueWithCGRect:spiFrame]];
    }
    
    //计算能有多少行
    NSInteger sumHeight = spiSize.height;//当前高
    NSInteger currSpiHeight =spiSize.height;
    lineSumcount = 1;
    while (containFrame.size.height>sumHeight ) {

        //每次减像素
        currSpiHeight = currSpiHeight-decrease;
        //最小为10像素
        if (currSpiHeight<10) {
            break;
        }
        //每次的总高
        sumHeight = sumHeight +currSpiHeight;
        //行数加1
        lineSumcount++;
        
    }
    
    //计算其它行,从第2行开始,高度初始为第1行的高
    currSpiHeight = spiSize.height;
    //当前Y的起始点，第2行为减去上一行的高
    NSInteger sY =containFrame.size.height - spiSize.height;
    for (int i = 0; i <lineSumcount-1; i++) {
        
        //每次减像素
        currSpiHeight = currSpiHeight-decrease;
        //当前行的起始x位,第一行减去行个数的decrease 的一半
        NSInteger sX = decrease*(i+1)*countInLine/2;
        //此时加间隔的宽度
        everyWidth = currSpiHeight +interDis*2;
        for (int j = 0; j <countInLine; j++)
        {
            spiPoint = CGPointMake(sX+everyWidth*(j+1)-everyWidth/2, sY-currSpiHeight/2);
            
            spiSize = CGSizeMake(currSpiHeight, currSpiHeight);
            
            spiFrame = CGRectMake(spiPoint.x - spiSize.width/2, spiPoint.y - spiSize.height/2, spiSize.width, spiSize.height);
            [spiFrameArray addObject:[NSValue valueWithCGRect:spiFrame]];
            
        }

        //下一行，再减一个高
        sY = sY - spiSize.height;

    }

    NSLog(@"排列的精灵frame 为spiFrameArray= %@", spiFrameArray);
    
    return spiFrameArray;
    
}
/**
 *  count*count个精灵,在指定区域
 *
 *  @param count 每一行的个数
 *
 *  @return 排列位置
 */
-(NSMutableArray*)getLineToLineArrayPosion:(NSInteger)count inFrame:(CGRect) inFrame
{
    
    /*类似如下排列,每一个“-”表示一个单位间隔
     |-[_]--[_]--[_]--[_]--[_]-|
     |-[_]--[_]--[_]--[_]--[_]-|
     |-[_]--[_]--[_]--[_]--[_]-|
     |-[_]--[_]--[_]--[_]--[_]-|
     |-[_]--[_]--[_]--[_]--[_]-|
     */
    
    //存位置与大小
    NSMutableArray* spiFrameArray = [NSMutableArray arrayWithCapacity:count];

    float interDis = 2.0;//精灵间隔,每个精灵之间有4，一边各一个
    float everyWidth ;//每个精灵所占用的宽度,包括间隔
    float spiWid;//精灵的宽，长=宽
    CGPoint spiPoint;//精灵中心点的位置
    CGSize  spiSize;//精灵的大小
    CGRect spiFrame ;//精灵的frame;
    
    //计算每个精灵的大小
    everyWidth = CGRectGetHeight(inFrame)/count;
    spiWid = everyWidth - interDis*2;
    
    //计算位置
    //当前行的起始x位
    NSInteger sX = inFrame.origin.x;
    NSInteger sY = inFrame.origin.y+inFrame.size.height;
    NSInteger getCount = 0;
    for (int i = 0; i <count; i++) {

        for (int j = 0; j <count; j++)
        {
            spiPoint = CGPointMake(sX+everyWidth*(j+1)-everyWidth/2, sY-everyWidth/2);
            
            spiSize = CGSizeMake(spiWid, spiWid);
            
            spiFrame = CGRectMake(spiPoint.x - spiSize.width/2, spiPoint.y - spiSize.height/2, spiSize.width, spiSize.height);
            [spiFrameArray addObject:[NSValue valueWithCGRect:spiFrame]];
            
            getCount ++;
        }
        
        //下一行起始y的位置
        sY = sY -everyWidth;
        
    }
    
    NSLog(@"排列的精灵frame 为spiFrameArray= %@", spiFrameArray);
    
    return spiFrameArray;
    
}

/**
 *  动画array只用于收回光和精灵回到日月,只在从日月飞出到天空时，调用animationLightSwimOutBazierLightType,和，animationLightSwimOutKeyFrameCount时，才加入其到队列，其它的动画不加入队列
 *
 *  @param aniKey 动画标识
 */
-(void) addAnimationToArray:(NSString*)aniKey lightType:(LightType) type aniObject:(CustomAnimation*)customAnimation
{
    
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_NEWSKY]
        || [aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_FOR_NEWSKY]
        || [aniKey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_REFRESH_ADD]
        || [aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD]
        || [aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_FINAL_ADD])
    {
        if (!swimOutAnimationArray) {
            swimOutAnimationArray=[NSMutableArray arrayWithCapacity:0];
        }
        [swimOutAnimationArray addObject:customAnimation];
        
        if (type == lightTypeYellowLight || type == lightTypeWhiteLight) {
            if (!swimOutAnimationLightArray) {
                swimOutAnimationLightArray=[NSMutableArray arrayWithCapacity:0];
            }
            [swimOutAnimationLightArray addObject:customAnimation];
        }
        
        if (type == lightTypeWhiteSpirite || type == lightTypeYellowSpirte) {
            if (!swimOutAnimationSpiriteArray) {
                swimOutAnimationSpiriteArray=[NSMutableArray arrayWithCapacity:0];
            }
            [swimOutAnimationSpiriteArray addObject:customAnimation];
        }
    }
    
    
}


#pragma mark -  ****** customAnimation  Delegate
- (void) customAnimationFinishedRuturn:(NSString*) aniKey srcViewDic:(NSDictionary*) srcViewDic
{
    //NSLog(@"customAnimationFinishedRuturn ---- %@", aniKey);
    UIImageView* srcView = (UIImageView*)[srcViewDic objectForKey:KEY_ANIMATION_VIEW];
    LightType type = (LightType)[(NSNumber*)[srcViewDic objectForKey:KEY_ANIMATION_LIGHT_TYPE] integerValue];
    
    //光都在日月中了，开始后续飞出动画
    if ([aniKey isEqualToString:KEY_ANIMATION_FLY_SIMPLE_LIGHT_TO_SKY_FOR_NEWSKY]) {
        
        if (lastRepeatCountMoveSimpleLightView && srcView == lastRepeatCountMoveSimpleLightView) {
            NSLog(@"KEY_ANIMATION_FLY_SIMPLE_LIGHT_TO_SKY_FOR_NEWSKY finished!");
            [self EnableUserInteractionAllView:self.view];
            
            //切换闪烁动画，和养育状态
            [self.userInfo updateisBringUpMoon:YES];
            [self refreshLightCircleStatForUserHeaderOrSunMoon];
            //开始弹出光动画
            [self newLightSkyMethod];
            //AudioServicesPlaySystemSound(1331);//振 + 铃

            NSString* time = [NSString stringWithFormat:@"开始养育%@光了", ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
            NSLog(@"%@", time);
            [self showCustomDelayAlertBottom:time];
            
            
        }
        
        [self arraiveToSunMoonIndication:srcView.center upView:srcView];
        
        //删除精灵原图
        [srcView removeFromSuperview];

        //音频
        AudioServicesPlaySystemSound(1113);
        
    }

    
    if ([aniKey isEqualToString:KEY_ANIMATION_FLY_TO_USER_HEADER_FOR_GIVE_LIGHT]) {
        
        //切换闪烁动画，和养育状态
        [self.userInfo updateisBringUpMoon:NO];
        [self refreshLightCircleStatForUserHeaderOrSunMoon];
        
        [self EnableUserInteractionInView:self.view];
        
        //第一个光回到头像后，起动拖动光的引导:giudStep_guidPanToBring
        [self HandleGuidProcess:giudStep_guidPanToBring];
        
        [self arraiveToHeaderIndication];
        
        //删除精灵原图
        [srcView removeFromSuperview];
        
        AudioServicesPlaySystemSound(1114);

    }
    
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_NEWSKY]) {
        
        if (srcView == ((UIImageView*)swimOutSpiriteImageViewArray.lastObject))
        {

            [self EnableUserInteractionInView:self.view];
        
            //最后一个动画完成,开始放光
            [self newLightSkyAfterSpiritToLight];
            
        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        
        [self animationLightSwimAround:srcViewDic];
        
        spiriteFlyIsAuto = YES;
        [self startSpiritAutoFlyschedule];
        

    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_REFRESH_ADD]) {
        
        if (srcView == ((UIImageView*)swimOutSpiriteImageViewArray.lastObject))
        {
            
            [self EnableUserInteractionInView:self.view];
            
            //再查看是否有光要上天空
            [self finalAddLightForRefresh];
            
        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];

        
        [self animationLightSwimAround:srcViewDic];
        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_FOR_NEWSKY]) {
        
        if (srcView == ((UIImageView*)swimOutBaselightImageViewArray.lastObject)) {
            //最后一个动画完成
            [self EnableUserInteractionInView:self.view];

            //判断是否要起动：guidGet_spirite_count
            [self HandleGuidProcess:guidGet_spirite_count];
        }
        
        [self animationLightSwimAround:srcViewDic];
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        

        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD]) {
        
        if (srcView == ((UIImageView*)swimOutBaselightImageViewArray.lastObject)) {
            //最后一个动画完成
            [self EnableUserInteractionInView:self.view];
            
            //查看增加光后的状态
            [self addLightToSkyMethodAfter];
        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        
        [self animationLightSwimAround:srcViewDic];
    
        
        AudioServicesPlaySystemSound(1113);

        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_OUT_FINAL_ADD]) {
        
        if (srcView == ((UIImageView*)swimOutBaselightImageViewArray.lastObject)) {
            //最后一个动画完成
            [self EnableUserInteractionInView:self.view];
            
            NSLog(@"Notify: Finish the Process: givelight->addLight --> backLight-->add spirite--> addleftLight!");

        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];

        [self animationLightSwimAround:srcViewDic];
        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_AROUND])
    {

        //是否要求停止动画
        if (needStopLightAnimationToCallBackForRefresh || needStopLightAnimationToCallBackForFinal) {
            
            if (srcView == (UIImageView*)swimOutBaselightImageViewArray.lastObject)
            {
                //最后一个光的游离动画完成,开始召回动画
                if (needStopLightAnimationToCallBackForRefresh) {
                    //用于自动刷新光数
                    [self isTimeProcessBackSkyLight:KEY_ANIMATION_SWIM_LIGHT_BACK_FORREFRESH];

                }else
                {
                    //用于最终召回所有的光
                    [self isTimeProcessBackSkyLight:KEY_ANIMATION_SWIM_LIGHT_BACK_FORFIANLBACK];

                }
            }
            
            
        }
        
        
        if (needStopSpiriteAnimationToCallBack) {
            
            if (srcView == (UIImageView*)swimOutSpiriteImageViewArray.lastObject) {
                //最后一个动画完成,开始召回动画
                [self isTimeProcessBackSpirite];
            }
            
        }
        
        if (needStopSpiriteAnimationToFlyTraceTouch || needStopSpiriteAnimationToFlyAuto) {
            
            if (srcView == (UIImageView*)swimOutSpiriteImageViewArray.lastObject) {
                //最后一个动画完成,开始飞行
                [self isTimeProcessSpiriteFlyTraceTouch];
            }
            
        }
        
        //光和精灵都会进来，停止的需求时间是不同的，需要区别对待
        if (type == lightTypeYellowLight || type==lightTypeWhiteLight) {
            if (!needStopLightAnimationToCallBackForRefresh && !needStopLightAnimationToCallBackForFinal) {
                
                [self animationLightSwimAround:srcViewDic];
            }
        }else
        {
            if (!needStopSpiriteAnimationToCallBack && !needStopSpiriteAnimationToFlyTraceTouch && !needStopSpiriteAnimationToFlyAuto) {
                
                [self animationLightSwimAround:srcViewDic];
                
                
            }
            


        }

        
        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_BACK_FORREFRESH]) {
        
        if (srcView == ((CustomAnimation*)swimOutAnimationLightArray.lastObject).aniImageView) {
            //所有的动画都回来了，
            [self EnableUserInteractionInView:self.view];
            //清空所有的array,等待下一次释放
            [swimOutAnimationLightArray removeAllObjects];
            [swimOutBaselightImageViewArray removeAllObjects];
            //弹出新的精灵
            [self addSpiriteFromRefresh];
        }
        
        //删除精灵原图
        [srcView removeFromSuperview];
        
    }
    
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_LIGHT_BACK_FORFIANLBACK]) {
        
        if (srcView == ((CustomAnimation*)swimOutAnimationLightArray.lastObject).aniImageView) {
            //所有的动画都回来了，
            [self EnableUserInteractionInView:self.view];
            //清空所有的array,等待下一次释放
            [swimOutAnimationLightArray removeAllObjects];
            [swimOutBaselightImageViewArray removeAllObjects];
            
            //刷新天空时，只是将光和精灵召回太阳，不回到头像
            if (!ToreFreshSky) {
                //等精灵回来
                [self isTimeToCallBackAllLightToUserHeader];
            }else
            {
                [self checkIsTimeToFinishRefreshUI];
            }

        }
        
        //删除精灵原图
        [srcView removeFromSuperview];
        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_BACK]) {
        
        if (srcView == ((CustomAnimation*)swimOutAnimationSpiriteArray.lastObject).aniImageView) {
            //所有的动画都回来了，
            [self EnableUserInteractionInView:self.view];
            //清空所有的array,等待下一次释放
            [swimOutAnimationSpiriteArray removeAllObjects];
            [swimOutSpiriteImageViewArray removeAllObjects];

            //刷新天空时，只是将光和精灵召回太阳，不回到头像
            if (!ToreFreshSky) {
                //等精灵回来
                [self isTimeToCallBackAllLightToUserHeader];
            }else
            {
                [self checkIsTimeToFinishRefreshUI];
            }

        }
        
        //删除精灵原图
        [srcView removeFromSuperview];
        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_FIANL_BACK_LIGHT]) {
        
        //未初始化的情况是启动程序后，光始终都未飞上天空??(忘了为什么写这个了)
        //if (!swimOutAnimationArray||swimOutAnimationArray.count == 0)
        if (lastRepeatCountMoveSimpleLightView && srcView == lastRepeatCountMoveSimpleLightView)
        {
            //所有的动画都回来了，都被释放
            [self EnableUserInteractionAllView:self.view];

            //切换闪烁动画
            [self.userInfo updateisBringUpMoon:NO];
            [self refreshLightCircleStatForUserHeaderOrSunMoon];

            //回来的原因是想进入头像小屋
            if (isGetinToHome) {
                [self performSegueWithIdentifier:@"getintoHome" sender:nil];
            }

            
        }
        
        [self arraiveToHeaderIndication];
        //删除精灵原图
        [srcView removeFromSuperview];

        AudioServicesPlaySystemSound(1114);

        
    }
    
    
    if ([aniKey isEqualToString:KEY_ANIMATION_PAN_TO_SKY_FAILED_TO_USERHEADER]) {

        [self arraiveToHeaderIndication];
        
        [self EnableUserInteractionAllView:self.view];

        //删除精灵原图
        [srcView removeFromSuperview];
        
        AudioServicesPlaySystemSound(1003);

        
    }
    
    if ([aniKey isEqualToString:KEY_ANIMATION_PAN_TO_USERHEADER_FAILED_TO_SKY]) {
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        
        [self EnableUserInteractionAllView:self.view];


        //删除精灵原图
        [srcView removeFromSuperview];

        
        AudioServicesPlaySystemSound(1003);

        
    }

    
    if ([aniKey isEqualToString:KEY_ANIMATION_SPIRITE_FLY_TRACE_TOUCH]) {
        
        if (srcView == ((CustomAnimation*)swimOutAnimationSpiriteArray.lastObject).aniImageView) {
            
            [self EnableUserInteractionInView:self.view];

            //所有的精灵都停止游动了，开始飞行(必须此动画完成后，否则由于游动动画与此动画的时差，导致原来位置的游动动画在未被此动画触发停止之前，又再次被触发，表现为原有游动动画不能消除)
            needStopSpiriteAnimationToFlyTraceTouch = FALSE;
            
            [self endTouchIndication];

        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        //飞行完成后，继续原地游动
        [self animationLightSwimAround:srcViewDic];
        //只留最后一个精灵显示
        if (srcView != ((CustomAnimation*)swimOutAnimationSpiriteArray.lastObject).aniImageView) {
            [srcView removeFromSuperview];
        }
        
    }
    
    
    if ([aniKey isEqualToString:KEY_ANIMATION_SPIRITE_FLY_AUTO]) {
        
        if (srcView == ((CustomAnimation*)swimOutAnimationSpiriteArray.lastObject).aniImageView) {
            
            [self EnableUserInteractionInView:self.view];
            
            needStopSpiriteAnimationToFlyAuto = FALSE;
            
            [self endTouchIndication];
            
            if (spiriteFlyIsAuto) {
                //重新开始计时触发下次自动飞行
                [self startSpiritAutoFlyschedule];
            }
            
        }
        
        [self arraiveToSkyIndication:srcView.center upView:srcView];
        //飞行完成后，继续原地游动
        [self animationLightSwimAround:srcViewDic];
        
        //只留最后一个精灵显示
        if (srcView != ((CustomAnimation*)swimOutAnimationSpiriteArray.lastObject).aniImageView) {
            [srcView removeFromSuperview];
        }
        
        
    }
    
}


#pragma mark - 各种闪烁提示
-(void) StartTouchIndication:(CGPoint) tPoint
{
    
    self.haloTouch = [PulsingHaloLayer layer];
    self.haloTouch.position = tPoint;
    self.haloTouch.radius = 0.2 * kMaxRadius;
    self.haloTouch.animationDuration = 0.5;
    self.haloTouch.eerepeatCount = 1;
    self.haloTouch.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
    [self.view.layer addSublayer:self.haloTouch];
    
}

-(void)endTouchIndication
{
    [self.haloTouch removeFromSuperlayer];
    
}

-(void) arraiveToHeaderIndication
{
    //到达闪烁
    self.haloToHeader = [PulsingHaloLayer layer];
    self.haloToHeader.position = _userHeaderImageView.center;
    self.haloToHeader.radius = 0.7 * kMaxRadius;
    self.haloToHeader.animationDuration = 0.5;
    self.haloToHeader.eerepeatCount = 1;
    self.haloToHeader.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
    [self.view.layer addSublayer:self.haloToHeader];
    
}


-(void) arraiveToSkyIndication:(CGPoint) arrivePoint upView:(UIImageView*) upView
{
    //到达闪烁
    self.haloToSky = [PulsingHaloLayer layer];
    self.haloToSky.position = arrivePoint;
    self.haloToSky.radius = 0.3 * kMaxRadius;
    self.haloToSky.animationDuration = 0.5;
    self.haloToSky.eerepeatCount = 1;
    self.haloToSky.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
    [self.view.layer insertSublayer:self.haloToSky below:upView.layer];
    
}

-(void) arraiveToSunMoonIndication:(CGPoint) arrivePoint upView:(UIImageView*) upView
{

    self.haloToSunMoon = [PulsingHaloLayer layer];
    self.haloToSunMoon.position = arrivePoint;
    self.haloToSunMoon.radius = 0.7 * kMaxRadius;
    self.haloToSunMoon.animationDuration = 0.5;
    self.haloToSunMoon.eerepeatCount = 1;
    self.haloToSunMoon.backgroundColor = [CommonObject getIndicationColorByTime].CGColor;
    [self.view.layer insertSublayer:self.haloToSunMoon below:upView.layer];
}

- (void) pulsingHaloLayerAnimationFinishedRuturn:(NSString*) aniKey  object:(PulsingHaloLayer*) selfObject
{
    CALayer* aniLayer = (CALayer* )selfObject;
    [aniLayer removeFromSuperlayer];
}

#pragma mark - 计算光的类型个数
-(void)caculateLightTypeAndCountByCount:(NSInteger) count
{
    //test
//    count = 25*5+23;
//    self.userInfo.sun_value = @"243";
//    self.userInfo.moon_value = @"243";
    
    //计算精灵个数,25个光生成1个精灵
    NSInteger spiCount = count/25;
    //还剩几个小光
    NSInteger leftCount = count%25;
    //计算蓝点点个数，100个红生成一个蓝

    
    lightTypeCountInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:leftCount], KEY_LIGHT_TYPE_LEFT_BASE_COUNT,[NSNumber numberWithInteger:spiCount], KEY_LIGHT_TYPE_SPIRITE_COUNT,[NSNumber numberWithInteger:count], KEY_LIGHT_TYPE_SUM_COUNT,
                          nil];
    
    NSLog(@"caculateLightTypeAndCount : %@",lightTypeCountInfo);
    
    
}

#pragma mark - ***************召唤并释放精灵 或 召回
/**
 *  判断是要收回，还是要刷新增加
 *
 *  @param type 0 收回,此时光必须是在养育态， 1刷新天空
 */
-(void) refreshLightStateForCallBackOrPopout:(NSInteger) type
{
    if (type==0) {
        [self stopBringUpAndFinalCallBackLight];
    }else if (type == 1)
    {
        [self reFreshCaculateAndPopOutLightSpirite];
        
    }else
    {
        NSLog(@"ERROR: callBackOrPopOutLigt type error (%lu)", type);
    }
    
    //更新精灵个数提示
    [self refreshSpiritCountInHeaderView];
    
}

/**
 *  重新计算，并刷新，看是否要进行弹出光和精灵
 */
-(void) reFreshCaculateAndPopOutLightSpirite
{

    //计算当前光和精灵的个数
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        [self caculateLightTypeAndCountByCount:userInfo.sun_value.integerValue];
        
    }else
    {
        [self caculateLightTypeAndCountByCount:userInfo.moon_value.integerValue];
        
    }
    
    //动画逻辑控制
    //光不在养育状态,在头像中
    if (![userInfo checkIsBringUpinSunOrMoon]) {
        
        //此时是奖励光触发
        if (giveLingtCout!=0) {
            //奖励的光移动到头像
            [self addLightToUserHeaderMethod:giveLingtCout];
            //清空状态
            giveLingtCout = 0;
        }else
        {
            //此时是拖回光触发，先把光都移动到日月，再刷新天空
            NSMutableArray * twoPointArray = [self getSeveralTracePointFromPan:2];
            [self moveSimpleLightWithRepeatCount:[userInfo getMaxuserValueByTime] StartPoint:_userHeaderImageView.center EndPoint:_skySunorMoonImage.center  totalTime:FLY_FROM_USERHEADRE_TO_SUN_MOON_TIME  aniKey:KEY_ANIMATION_FLY_SIMPLE_LIGHT_TO_SKY_FOR_NEWSKY withBazierP1:[[twoPointArray objectAtIndex:0] CGPointValue] bazierP2:[[twoPointArray objectAtIndex:1] CGPointValue]];

        }
  
        
    }else//光在养育状态
    {
        //补全控制逻辑
        if (giveLingtCout!=0) {
            //逻辑1：givelight--> addlight but not enough
            //逻辑2: givelight-->addLight --> backLight-->add spirite--> addleftLight
            [self addLightToSkyMethod:giveLingtCout];
            //清空状态
            giveLingtCout = 0;
        }else
        {
            //逻辑1：outSpirit--> outLight
            [self newLightSkyMethod];
        }
        
    }
    
}

/**
 *  切换，并刷新日月和头像的光环状态
 */
-(void) refreshLightCircleStatForUserHeaderOrSunMoon
{
    
    if ([userInfo checkIsBringUpinSunOrMoon]) {
        //闪烁日月
        NSLog(@"开始 闪烁日月 动画！");
        [self animationLightFrameSkySunOrMoon:7];

        
        NSLog(@"停止 头像闪烁 动画！");
        //最多7个动画光环
        for (int i =0; i<7; i++) {
            UIImageView* lightUserHeaderTag = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
            lightUserHeaderTag.hidden = YES;
            [lightUserHeaderTag stopAnimating];
        }
    }else
    {
        NSLog(@"开始 头像闪烁 动画！");
        if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
        }else
        {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
            
        }
        
        NSLog(@"停止 闪烁日月 动画！");
        [lightSkySunOrMoonView stopAnimating];
    }
    
    
}

-(void) addLightToUserHeaderMethod:(NSInteger) lightCount
{
    if (lightCount ==0) {
        NSLog(@"Notify: addLightToUserHeaderMethod:no giveCount to getOut!");
        return;
    }

    //构造光组
    NSMutableArray * imageViewArray = [NSMutableArray arrayWithCapacity:lightCount];
    LightType type = [CommonObject getBaseLightTypeByTime];
    for (int i = 0; i<lightCount; i++) {
        
        UIImageView* baseView = [[UIImageView alloc]initWithImage:[CommonObject getStaticImageByLightType:type]];
        baseView.frame = CGRectMake(0, 0, 0, 0);
        [imageViewArray addObject:baseView];
        [self.view addSubview:baseView];
        
    }
    
    //开始位置构造,长与宽一样
    float wStart =LIGHT_W_H;
    CGRect startRec = CGRectMake(CGRectGetMidX(_intoCameraBtn.frame) -wStart/2, CGRectGetMidY(_intoCameraBtn.frame) -wStart/2, wStart, wStart);
    
    //构造结束位置
    NSMutableArray* endFrameArray = [NSMutableArray arrayWithCapacity:lightCount];
    CGRect endRect = CGRectMake(CGRectGetMidX(_userHeaderImageView.frame) -wStart/2, CGRectGetMidY(_userHeaderImageView.frame) -wStart/2, wStart, wStart);
    for (NSInteger i = 0; i<lightCount; i++) {
        
        [endFrameArray addObject:[NSValue valueWithCGRect:endRect]];
    }

    [self popOutLightCount:lightCount lightType:type srcViewArray:imageViewArray  aniKey:KEY_ANIMATION_FLY_TO_USER_HEADER_FOR_GIVE_LIGHT startFrame:startRec endFrameArray:endFrameArray];
}

-(void) addLightToSkyMethod:(NSInteger) giveCount
{
    
    NSInteger currentLightCount = swimOutBaselightImageViewArray.count;
    
    if (giveCount < FULL_SKY_LIGHT_COUNT - currentLightCount) {
        //补全光
        [self getOutBaseLight:giveCount outTypeKey:KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD];
    }else
    {
        //选补全剩余的，收回全光，再弹出新精灵，再弹出多余的光
        NSInteger getCount = FULL_SKY_LIGHT_COUNT - currentLightCount;
        [self getOutBaseLight:getCount outTypeKey:KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD];
    }
    
}


-(void) addLightToSkyMethodAfter
{
    
    if (swimOutBaselightImageViewArray.count == FULL_SKY_LIGHT_COUNT) {
        //光被补全了，收回所有天空光
        [self callBackLightToSunMoonForRefresh];
        
    }else
    {
        //光未补全，完成流程
        NSLog(@"Notify: Finish the Process:givelight--> addlight but not enough!");
        
        
        
    }
    
}

-(void)finalAddLightForRefresh
{
    
    NSInteger getCount = [[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_LEFT_BASE_COUNT] integerValue];
    if (getCount == 0) {
        
        NSLog(@"Notify: Finish the Process: givelight-->addLight --> backLight-->add spirite--> addleftLight!");
        return;
    }
    
    [self getOutBaseLight: getCount outTypeKey:KEY_ANIMATION_SWIM_LIGHT_OUT_FINAL_ADD];
    
}


-(void) addSpiriteFromRefresh
{
    
    NSInteger getCount;
    if (!swimOutSpiriteImageViewArray || swimOutSpiriteImageViewArray.count == 0)
    {
        //如果没有精灵，全部增加
        getCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue];
    }else
    {
        //如果有精灵，计算应该增加的
        getCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue] - swimOutSpiriteImageViewArray.count;
    }
    
    [self getOutSpirite:getCount outTypeKey:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_REFRESH_ADD];
    
}

/**
 *  新的天空，释放精灵和光
 */
-(void) newLightSkyMethod
{
    
    if (!lightTypeCountInfo) {
        return;
    }
    
    NSInteger spiritCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue];
    
    //先释放精灵,结束后，释放光
    if (spiritCount != 0) {
        
        [self getOutSpirite:spiritCount outTypeKey:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_NEWSKY];
    }else
    {
        //没有精灵，直接放光
        [self newLightSkyAfterSpiritToLight];
    }
    

}

/**
 *  释放精灵后，释放光
 */
-(void) newLightSkyAfterSpiritToLight
{
    if (!lightTypeCountInfo) {
        return;
    }

    
    NSInteger count = [[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_LEFT_BASE_COUNT] integerValue];
    if (count == 0) {
        NSLog(@"No light to pop out!");
        return;
    }

    NSInteger getCount;
    if (!swimOutBaselightImageViewArray || swimOutBaselightImageViewArray.count == 0)
    {
        //如果没有光，全部增加
        getCount = count;
    }else
    {
        //如果有光，计算应该增加的
        getCount =count - swimOutBaselightImageViewArray.count;
    }
    
    [self getOutBaseLight:getCount outTypeKey:KEY_ANIMATION_SWIM_LIGHT_OUT_FOR_NEWSKY];

}

/**
 *  确认是否有错误的光状态
 */
-(void)checkSkyStatusIsRight
{
    
    
}




/**
 *  此时光都在日月里，才能飞出精灵
 *
 *  @param getCount   <#getCount description#>
 *  @param outTypeKey <#outTypeKey description#>
 */
-(void) getOutSpirite:(NSInteger) getCount  outTypeKey:(NSString*)outTypeKey
{
    if (getCount ==0) {
        NSLog(@"Notify: getOutSpirite: no spirite to getOut!");
        return;
    }
    
    if (![userInfo checkIsBringUpinSunOrMoon]) {
        NSLog(@"Notify: getOutSpirite: no spirite to getOut!");
        return;
    }
    NSAssert([userInfo checkIsBringUpinSunOrMoon], @"The light is not in the sun or moon already, this fun can not be called!");
    
    //开始游离动画
    needStopSpiriteAnimationToCallBack = FALSE;
    needStopSpiriteAnimationToFlyTraceTouch = FALSE;
    needStopSpiriteAnimationToFlyAuto = FALSE;
    
    //构造精灵
    if (!swimOutSpiriteImageViewArray) {
        swimOutSpiriteImageViewArray = [NSMutableArray arrayWithCapacity:getCount];

    }
    //当前已有的精灵个数，可能是0
    NSInteger currentCount = swimOutSpiriteImageViewArray.count;
    
    LightType type = [CommonObject getSpiriteTypeByTime];
    for (int i = 0; i<getCount; i++) {

        UIImageView* spiView = [[UIImageView alloc]initWithImage:[CommonObject getAniStartImageByLightType:type]];
        spiView.frame = CGRectMake(0, 0, 0, 0);
        [swimOutSpiriteImageViewArray addObject:spiView];
        [self.view addSubview:spiView];
        
        //给其加入动画
        NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<3; i++) {
            NSString *name = [CommonObject getImageNameByLightType:[CommonObject getSpiriteTypeByTime]];
            
            UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"%@-%d",name,i]];
            [iArr addObject:image];
        }
        spiView.animationImages=iArr;
        spiView.animationDuration=0.3;
        spiView.animationRepeatCount = HUGE_VAL;
        [spiView startAnimating];
        
    }
  
    //位置固定，每次重新取
    swimOutSpiriteImageViewArrayFrame = [NSMutableArray arrayWithCapacity:getCount+currentCount];
    //取得固定位置, 放在相机的右边
    CGRect SpiRec = CGRectMake(_skySunorMoonImage.frame.origin.x - SPIRITE_W_H, _skySunorMoonImage.center.y - SPIRITE_W_H/2, SPIRITE_W_H, SPIRITE_W_H);
    //精灵飞到同一个位置
    for (int i =0 ; i<getCount+currentCount; i++) {
        [swimOutSpiriteImageViewArrayFrame addObject:[NSValue valueWithCGRect:SpiRec]];
    }
    //存精灵自动位置
    spiriteAutoFlyPointArray = [NSMutableArray arrayWithCapacity:0];
    //初始点
    CGPoint sp1 =CGPointMake(CGRectGetMidX(SpiRec), CGRectGetMidY(SpiRec));
    [spiriteAutoFlyPointArray addObject:[NSValue valueWithCGPoint:sp1]];
    //对面的点
    CGPoint sp2 =CGPointMake((SCREEN_WIDTH - sp1.x),sp1.y);
    [spiriteAutoFlyPointArray addObject:[NSValue valueWithCGPoint:sp2]];

    
    //开始位置构造,长与宽一样
    CGRect startSpi = CGRectMake(_skySunorMoonImage.center.x -SPIRITE_W_H/2, _skySunorMoonImage.center.y - SPIRITE_W_H/2, SPIRITE_W_H, SPIRITE_W_H);
    //结束位置构造，只取位置组的后几位，即此次增加的精灵
    NSMutableArray* endFrameArray = [NSMutableArray arrayWithCapacity:getCount];
    //从当前个数的frame向后取，当前个数可能为0
    for (NSInteger i = currentCount; i<currentCount+getCount; i++) {
        
        NSAssert(swimOutSpiriteImageViewArrayFrame.count>=i , @"swimOutSpiriteImageViewArrayFrame beyond index: count=%lu, i = %lu, currentCount=%lu, getCount=%lu", swimOutSpiriteImageViewArrayFrame.count,i,currentCount,getCount);
        
        [endFrameArray addObject:[swimOutSpiriteImageViewArrayFrame objectAtIndex:i]];
    }
    
    //构造View
    NSMutableArray *srcViewArray =[NSMutableArray arrayWithCapacity:getCount];
    for (NSInteger i = currentCount; i<currentCount+getCount; i++) {
        
        NSAssert(swimOutSpiriteImageViewArray.count>=i , @"swimOutSpiriteImageViewArray beyond index: count=%lu, i = %lu, currentCount=%lu, getCount=%lu", swimOutSpiriteImageViewArrayFrame.count,i,currentCount,getCount);
        
        [srcViewArray addObject:[swimOutSpiriteImageViewArray objectAtIndex:i]];
    }
    
    [self popOutSpiriteCount:getCount  lightType:type srcViewArray:srcViewArray  aniKey:outTypeKey startFrame:startSpi endFrameArray:endFrameArray];
    
}

/**
 *  先放出精灵
 */
/*
-(void) firstGetOutSpirite
{
    NSInteger getCount;
    LightType type = lightTypeYellowSpirte;

    getCount =[[lightTypeCountInfo objectForKey:KEY_LIGHT_TYPE_SPIRITE_COUNT] integerValue];
    if (getCount) {
        //构造精灵
        if (!swimOutSpiriteImageViewArray) {
            swimOutSpiriteImageViewArray = [NSMutableArray arrayWithCapacity:getCount];
        }
        [swimOutSpiriteImageViewArray removeAllObjects];
        for (int i = 0; i<getCount; i++) {
            if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                type = lightTypeYellowSpirte;
            }else
            {
                type = lightTypeWhiteSpirite;
            }
            UIImageView* spiView = [[UIImageView alloc]initWithImage:[CommonObject getLightImageByLightType:type]];
            spiView.frame = CGRectMake(0, 0, 0, 0);
            [swimOutSpiriteImageViewArray addObject:spiView];
            [self.view addSubview:spiView];
            
        }
        //取得固定位置, 放在相机的右边
        CGRect SpiRec = CGRectMake(_intoCameraBtn.frame.origin.x/2 - SPIRITE_W_H/2, _intoCameraBtn.center.y- SPIRITE_W_H/2, SPIRITE_W_H, SPIRITE_W_H);
        //精灵飞到同一个位置
        swimOutSpiriteImageViewArrayFrame = [NSMutableArray arrayWithCapacity:getCount];
        for (int i =0 ; i<getCount; i++) {
            [swimOutSpiriteImageViewArrayFrame addObject:[NSValue valueWithCGRect:SpiRec]];
        }
        
        //开始位置构造,长与宽一样
        CGRect startSpi = CGRectMake(_skySunorMoonImage.center.x -SPIRITE_W_H/2, _skySunorMoonImage.center.y - SPIRITE_W_H/2, SPIRITE_W_H, SPIRITE_W_H);
        
        //先大范围弹出，结束后，再小范围游动，以便在召回时，位置可知
        [self popOutSpiriteCount:getCount  lightType:type srcViewArray:swimOutSpiriteImageViewArray srcViewArrayFrame:swimOutSpiriteImageViewArrayFrame aniKey:KEY_ANIMATION_SWIM_SPIRITE_OUT startFrame:startSpi];
    }

    
}
*/

-(void) getOutBaseLight:(NSInteger) getCount  outTypeKey:(NSString*)outTypeKey
{
    
    if (getCount ==0) {
        NSLog(@"Notify: no light to getOut!");
        return;
    }
    
    NSAssert([userInfo checkIsBringUpinSunOrMoon], @"The light is not in the sun or moon already, this fun can not be called!");
    
    //开始游离动画
    needStopLightAnimationToCallBackForFinal = NO;
    needStopLightAnimationToCallBackForRefresh = NO;
    //构造小光
    if (!swimOutBaselightImageViewArray) {
        //新构造光组
        swimOutBaselightImageViewArray = [NSMutableArray arrayWithCapacity:getCount];
        
        
    }
    
    //获取精灵排列的位置,位置固定，每次重新取
    CGRect inFrame = _lightPostionFrame.frame;
    //取全部的位置，放置需要的小光
    swimOutBaselightImageViewArrayFrame = [self getLineToLineArrayPosion:EVERY_LING_LIGHT_COUNT inFrame:inFrame];

    
    //当前已有几个光，可能是0个
    NSInteger currentCount = swimOutBaselightImageViewArray.count;
    
    NSAssert(getCount+currentCount<=FULL_SKY_LIGHT_COUNT, @" get out base light count shoud not bigger than %d, getcount=%lu, currentcou%lu", FULL_SKY_LIGHT_COUNT, getCount, currentCount);
    
    //将光加入队列
    LightType type = [CommonObject getBaseLightTypeByTime];
    for (int i = 0; i<getCount; i++) {
        
        UIImageView* baseView = [[UIImageView alloc]initWithImage:[CommonObject getAniStartImageByLightType:type]];
        baseView.frame = CGRectMake(0, 0, 0, 0);
        [swimOutBaselightImageViewArray addObject:baseView];
        [self.view addSubview:baseView];
        
    }
    
    //开始位置构造,长与宽一样
    float wStart =CGRectGetWidth([[swimOutBaselightImageViewArrayFrame objectAtIndex:0] CGRectValue]);
    CGRect startSpi = CGRectMake(CGRectGetMidX(_skySunorMoonImage.frame) -wStart/2, CGRectGetMidY(_skySunorMoonImage.frame) -wStart/2, wStart, wStart);
    
    //构造结束位置
    NSMutableArray* endFrameArray = [NSMutableArray arrayWithCapacity:getCount];
    //从当前个数的frame向后取，当前个数可能为0
    for (NSInteger i = currentCount; i<currentCount+getCount; i++) {
        
        [endFrameArray addObject:[swimOutBaselightImageViewArrayFrame objectAtIndex:i]];
    }
    
    //构造View
    NSMutableArray *srcViewArray =[NSMutableArray arrayWithCapacity:getCount];
    for (NSInteger i = currentCount; i<currentCount+getCount; i++) {
        
        [srcViewArray addObject:[swimOutBaselightImageViewArray objectAtIndex:i]];
    }
    
    //先大范围弹出，结束后，再小范围游动，以便在召回时，位置可知
    [self popOutLightCount:getCount  lightType:type srcViewArray:srcViewArray  aniKey:outTypeKey startFrame:startSpi endFrameArray:endFrameArray];
    
}

#pragma mark -
/**
 *  停止养成，并召回所有的光，光和精灵先回日月，再回头像
 */
-(void)stopBringUpAndFinalCallBackLight
{
    
    [self callBackLightToSunMoonForFinal];
    [self callBackSpiriteToSunMoon];
    
}

//召回光回到日月
/**
 *  两种召回，一种是自动计算满格后，自动刷新召回太阳，一种是手动最终全召回，先回到太阳，再回到头像
 */
-(void) callBackLightToSunMoonForRefresh
{
    
    if (!swimOutBaselightImageViewArray || swimOutBaselightImageViewArray.count == 0) {
        NSLog(@"Notify:No light to call back  to sunMoon!");
        return;
    }
    
    
    //等待 游荡动画全结束时，触发召回动画
    needStopLightAnimationToCallBackForRefresh = YES;
    
    //待修改:不在走游动动画
    [self isTimeProcessBackSkyLight:KEY_ANIMATION_SWIM_LIGHT_BACK_FORREFRESH];

    
}

-(void) callBackLightToSunMoonForFinal
{
    
    if (!swimOutAnimationLightArray || swimOutAnimationLightArray.count == 0) {
        NSLog(@"Notify:No light to call back  to sunMoon!");
        return;
    }
    
    
    //等待 游荡动画全结束时，触发召回动画
    needStopLightAnimationToCallBackForFinal = YES;
    
    //待修改:不在走游动动画
    [self isTimeProcessBackSkyLight:KEY_ANIMATION_SWIM_LIGHT_BACK_FORFIANLBACK];
    
}


-(void)callBackSpiriteToSunMoon
{
    if (!swimOutAnimationSpiriteArray || swimOutAnimationSpiriteArray.count == 0) {
        NSLog(@"Notify:No spirit to call back to sunMoon!");
        return;
    }
    
    needStopSpiriteAnimationToCallBack = YES;
    
    //待修改:不在走游动动画
    [self isTimeProcessBackSpirite];
}


/**
 *  判断是否所有的光与精灵回到日月的动画已完成
 */
-(void) isTimeToCallBackAllLightToUserHeader
{
    //两个array会在回到日月后清空一次
    if (swimOutAnimationLightArray.count ==0 && swimOutAnimationSpiriteArray.count == 0) {
        [self callBackHandleAllLightToUserHeader];
    }else
    {
        NSLog(@"Notity: Light or spirite are still in the sky, waitting..");
    }
    
    
}

//手动召回所有光回到头像，这之前要计算奖励，如有奖励，弹出提示，点击OK后，
/**
 *  此时所有的光已回到了日月，把它们召回头像
 */
-(void)callBackHandleAllLightToUserHeader
{
    
    
    NSInteger count;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        count = userInfo.sun_value.integerValue;
    }else
    {
        count = userInfo.moon_value.integerValue;
    }
    
    if (count ==0) {
        NSLog(@"Notify:No light to Call back to user header!");
        return;
    }
    
    CGRect startF = _skySunorMoonImage.frame;
    CGRect endF = _userHeaderImageView.frame;
    
    //计算此精灵的最终位置
    CGPoint startPoint =CGPointMake(CGRectGetMidX(startF), CGRectGetMidY(startF));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(endF), CGRectGetMidY(endF));
    
    //执行召回动画
    NSMutableArray * twoPointArray = [self getSeveralTracePointFromPan:2];
    [self moveSimpleLightWithRepeatCount:count StartPoint:startPoint EndPoint:endPoint totalTime:FLY_BACK_TO_USERHEAER_TOTAL_TIME aniKey:KEY_ANIMATION_FIANL_BACK_LIGHT withBazierP1:[[twoPointArray objectAtIndex:0] CGPointValue] bazierP2:[[twoPointArray objectAtIndex:1] CGPointValue]];
    
//    //执行召回动画
//    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
//    
//
//    //计算此精灵的最终大小
//    CGSize  startSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
//    CGSize endSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
//    
//    
//    CGPoint bazierPoint_1 = CGPointMake((endPoint.x - startPoint.x)/3 -[CommonObject getRandomNumber:0 to:10], (endPoint.y - startPoint.y)/3 -[CommonObject getRandomNumber:0 to:10]);
//    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
//    
//    CGPoint bazierPoint_2 = CGPointMake((endPoint.x - startPoint.x)/3*2 -[CommonObject getRandomNumber:0 to:10], (endPoint.y - startPoint.y)/3*2 -[CommonObject getRandomNumber:0 to:10]);
//    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
//    
//    UIImageView* srcView = [[UIImageView alloc] initWithImage:[CommonObject getBaseLightImageByTime]];
//    srcView.frame = CGRectZero;
//    [self.view addSubview:srcView];
//    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                srcView, KEY_ANIMATION_VIEW,
//                                [NSNumber numberWithInteger:[CommonObject getBaseLightTypeByTime]], KEY_ANIMATION_LIGHT_TYPE,nil];
//    
//    
//    [customAnimation setAniType:BEZIER_ANI_TYPE];
//    [customAnimation setAniImageViewDic:srcViewDic];
//    [customAnimation setBkLayer:self.view.layer];
//    [customAnimation setAniStartPoint:startPoint];
//    [customAnimation setAniEndpoint:endPoint];
//    [customAnimation setAniStartSize:startSize];
//    [customAnimation setAniEndSize:endSize];
//    [customAnimation setCustomAniDelegate:self];
//    [customAnimation setAnikey:KEY_ANIMATION_FIANL_BACK_LIGHT];
//    [customAnimation setAniRepeatCount:count];
//    
//    //计算每个用时
//    float eTime = FLY_BACK_TO_USERHEAER_TIME/count;
//    [customAnimation setAniDuration:eTime];
//    
//    [customAnimation setSipiriteAnimationType:[CommonObject getBaseLightTypeByTime]];
//    [customAnimation displayLinkAnimationEnable];
//    
//    [customAnimation startCustomAnimation];
    
    
    [self clearSkyArrayData];

    
}


-(void) clearSkyArrayData
{
    //清除天空数据array
    [swimOutAnimationArray removeAllObjects];
    
    [swimOutAnimationLightArray removeAllObjects];
    
    [swimOutAnimationSpiriteArray removeAllObjects];
    
    [swimOutBaselightImageViewArray removeAllObjects];
    
    [swimOutSpiriteImageViewArray removeAllObjects];
    
    
    //FrameArray值是固定的，不用清
    //[swimOutBaselightImageViewArrayFrame removeAllObjects];
    //[swimOutSpiriteImageViewArrayFrame removeAllObjects];
    
}





#pragma mark - 放出光

/**
 *  每隔指定时音，放出指定个数的光
 *
 *  @param count 放出光的个数
 *  @param type  光的类型
 *  @param srcView  待操作的原view
 */
- (void) popOutLightCount:(NSInteger) count lightType:(LightType) type srcViewArray:(NSMutableArray*) srcViewArray   aniKey:(NSString*)aniKey  startFrame:(CGRect) startFrame endFrameArray:(NSMutableArray*) endFrameArray
{
    
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];

    
    //控制在2秒内全部释放完成
    float timeInterval = POP_OUT_ALL_LIGHT_TO_SKY_TIME / count;
    
    NSDictionary * timerUserInfo =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type], @"popOutLightType",
                                   [NSNumber numberWithInteger:count], @"popOutLightCount",
                                   srcViewArray,@"popOutLightViewArray",
                                   endFrameArray,@"popOutLightViewArrayFrame",
                                   aniKey,@"popOutLightAniKey",
                                   [NSValue valueWithCGRect:startFrame],@"popOutLightStartFrame",
                                   nil];
    
    repeatCountLight =0;
    NSTimer* reapater = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(popOutLight:) userInfo:timerUserInfo repeats:YES];
    [reapater fire];
    
    
}

- (void) popOutLight:(NSTimer*) timer
{
    
    
    NSDictionary *timerUserInfo = (NSDictionary *)timer.userInfo;
    LightType type = (LightType)[[timerUserInfo objectForKey:@"popOutLightType"] integerValue];
    NSInteger count = [[timerUserInfo objectForKey:@"popOutLightCount"] integerValue];
    NSMutableArray * viewArray =(NSMutableArray*)[timerUserInfo objectForKey:@"popOutLightViewArray"];
    NSMutableArray * viewArrayFrame =(NSMutableArray*)[timerUserInfo objectForKey:@"popOutLightViewArrayFrame"];
    NSString * aniKey =[timerUserInfo objectForKey:@"popOutLightAniKey"];
    CGRect startRect =[[timerUserInfo objectForKey:@"popOutLightStartFrame"] CGRectValue];
    
    if (repeatCountLight != count) {
        //弹出 count 个精灵
        //精灵的最终位置
        NSAssert(repeatCountLight<viewArrayFrame.count, @"popOutLight: repeatCountLight(%lu)>viewArrayFrame.count(%lu)", repeatCountLight, viewArrayFrame.count);
        NSAssert(repeatCountLight<viewArray.count, @"popOutLight: repeatCountLight(%lu)>viewArray.count(%lu)", repeatCountLight, viewArray.count);
        CGRect endRect = [[viewArrayFrame objectAtIndex:repeatCountLight] CGRectValue];
        
        [self animationLightSwimOutBazierLightType:type srcView:[viewArray objectAtIndex:repeatCountLight] startFrame:startRect endFrame:endRect number:repeatCountLight aniKey:aniKey];
        
        repeatCountLight ++;
        
    }else
    {
        [timer invalidate];
        repeatCountLight = 0;
    }
    
}


- (void) popOutSpiriteCount:(NSInteger) count lightType:(LightType) type srcViewArray:(NSMutableArray*) srcViewArray  aniKey:(NSString*)aniKey startFrame:(CGRect) startFrame  endFrameArray:(NSMutableArray*) endFrameArray

{
    
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];

    
    //控制在2秒内全部释放完成
    float timeInterval = POP_OUT_ALL_SPIRITE_TO_SKY_TIME / count;
    
    NSDictionary * timerUserInfo =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type], @"popOutSpiriteType",
                                   [NSNumber numberWithInteger:count], @"popOutSpiriteCount",
                                   srcViewArray,@"popOutSpiriteViewArray",
                                   endFrameArray,@"popOutSpiriteViewArrayFrame",
                                   aniKey,@"popOutSpiriteAniKey",
                                   [NSValue valueWithCGRect:startFrame],@"popOutSpiriteStartFrame",
                                   nil];
    
    repeatCountSpirite =0;
    NSTimer* reapater = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(popOutSpirite:) userInfo:timerUserInfo repeats:YES];
    [reapater fire];
    
    
}

- (void) popOutSpirite:(NSTimer*) timer
{
    
    
    NSDictionary *timerUserInfo = (NSDictionary *)timer.userInfo;
    LightType type = (LightType)[[timerUserInfo objectForKey:@"popOutSpiriteType"] integerValue];
    NSInteger count = [[timerUserInfo objectForKey:@"popOutSpiriteCount"] integerValue];
    NSMutableArray * viewArray =(NSMutableArray*)[timerUserInfo objectForKey:@"popOutSpiriteViewArray"];
    NSMutableArray * viewArrayFrame =(NSMutableArray*)[timerUserInfo objectForKey:@"popOutSpiriteViewArrayFrame"];
    NSString * aniKey =[timerUserInfo objectForKey:@"popOutSpiriteAniKey"];
    CGRect startRect =[[timerUserInfo objectForKey:@"popOutSpiriteStartFrame"] CGRectValue];
    
    if (repeatCountSpirite != count) {
        //弹出 count 个精灵
        //精灵的最终位置
        CGRect endSpi = [[viewArrayFrame objectAtIndex:repeatCountSpirite] CGRectValue];
        
        [self animationLightSwimOutBazierLightType:type srcView:[viewArray objectAtIndex:repeatCountSpirite] startFrame:startRect endFrame:endSpi number:repeatCountSpirite aniKey:aniKey];
        
        repeatCountSpirite ++;
        
    }else
    {
        [timer invalidate];
        repeatCountSpirite = 0;
    }
    
}


///**
// *  收回所有的光
// */
//-(void) callBackAllLight
//{
//    
//}
//
///**
// *  收回精灵
// */
//-(void) callBackAllSpirite
//{
//    
//    if (swimOutAnimationArray.count == 0) {
//        NSLog(@"Notify: no spirite need to be call back");
//        return;
//    }
//    
//    //等待 游荡动画全结束
//    needStopAnimationToCallBack = TRUE;
//    
//}

-(void) isTimeProcessBackSkyLight:(NSString*) anKey
{
    if (!swimOutBaselightImageViewArray || swimOutBaselightImageViewArray.count == 0) {
        NSLog(@"ERROR: no Light to call back to SunMoon, isTimeProcessBackSkyLight shoud not be called!");
        return;
    }
    
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];
    
    //控制在2秒内全部释放完成
    float timeInterval = POP_BACK_SKY_LIGHT_TIME / swimOutBaselightImageViewArray.count;
    
    repeatCountLightBack = 0;
    NSTimer* reapater =  [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(processBackSkyLight:) userInfo:anKey repeats:YES];
    //立刻收回第一个
    [reapater fire];
    
}

-(void) processBackSkyLight:(NSTimer *)timer
{

    
    if (repeatCountLightBack != swimOutAnimationLightArray.count && swimOutAnimationLightArray.count !=0) {

        NSAssert(repeatCountLightBack<swimOutAnimationLightArray.count, @"processBackSkyLight: repeatCountLight(%lu)>swimOutAnimationLightArray(%lu)", repeatCountLightBack, swimOutAnimationLightArray.count);
        
        CustomAnimation* backAni = [swimOutAnimationLightArray objectAtIndex:repeatCountLightBack];
        [self animationLightSwimBackKeyFrameWithAni:backAni aniKey:(NSString*)timer.userInfo number:repeatCountLightBack];
        repeatCountLightBack ++;
        
    }else
    {
        [timer invalidate];
        repeatCountLightBack = 0;
    }
    
    
    
}


-(void) isTimeProcessBackSpirite
{
    
    //动画中，禁止所有操作
    [self DisableUserInteractionInView:self.view exceptViewWithTag:HUGE_VAL];
    
    //控制在2秒内全部释放完成
    float timeInterval = (float)POP_BACK_SPIRITE_TIME / swimOutSpiriteImageViewArray.count;
    
    repeatCountSpiriteBack = 0;
    NSTimer* reapater =  [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(processBackSpirite:) userInfo:nil repeats:YES];
    //立刻收回第一个
    [reapater fire];
    
}

-(void) processBackSpirite:(NSTimer *)timer
{

    
    if (repeatCountSpiriteBack != swimOutAnimationSpiriteArray.count&& swimOutAnimationSpiriteArray.count !=0) {

        NSAssert(repeatCountSpiriteBack<swimOutAnimationSpiriteArray.count, @"processBackSpirite: repeatCountSpirite(%lu)>swimOutAnimationSpiriteArray(%lu)", repeatCountSpiriteBack, swimOutAnimationSpiriteArray.count);
        
        CustomAnimation* backAni = [swimOutAnimationSpiriteArray objectAtIndex:repeatCountSpiriteBack];
        [self animationLightSwimBackKeyFrameWithAni:backAni aniKey:KEY_ANIMATION_SWIM_SPIRITE_BACK number:repeatCountSpiriteBack];
        repeatCountSpiriteBack ++;
        
    }else
    {
        [timer invalidate];
        repeatCountSpiriteBack = 0;
    }
    
    
}

#pragma mark - 屏幕touch 精灵飞动
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
//    UITouch *touch=touches.anyObject;
//    CGPoint location= [touch locationInView:self.view];
    
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=touches.anyObject;
    CGPoint location= [touch locationInView:self.view];
    
    //不能点击头像
    if(CGRectContainsPoint(_userHeaderImageView.frame, location))
    {
        NSLog(@"Touch point can not be in userHeader Rect");
        return;
    }
    
    if(CGRectContainsPoint(_skySunorMoonImage.frame, location))
    {
        NSLog(@"Touch point can not be in sunOrMoon Rect");
        return;
    }
    
    if(CGRectContainsPoint(menuBtn.frame, location))
    {
        NSLog(@"Touch point can not be in menuBtn Rect");
        return;
    }
    
    if(CGRectContainsPoint(_screenShareBtn.frame, location))
    {
        NSLog(@"Touch point can not be in screenShareBtn Rect");
        return;
    }
    
    //点击闪烁提示
    [self StartTouchIndication:location];
    
    //启动精灵飞行
    [self spiriteFlyTraceTouch:location fromUserTouch:YES];

    
}



- (void)spiriteFlyTraceTouch:(CGPoint) touchPoint  fromUserTouch:(BOOL) isTouch
{
    if (!swimOutAnimationSpiriteArray || swimOutAnimationSpiriteArray.count == 0) {
        NSLog(@"Notify:No spirit to fly trace by touch!");
        
        //跳动静态精灵提示
        [self animationSpiriteCountInHeaderChanged];
        
        return;
    }
    
    if (isTouch) {
        spiriteFlyIsAuto = FALSE;
         spiritFlyTouchPoint = touchPoint;
        needStopSpiriteAnimationToFlyTraceTouch = YES;
        [self DisableUserInteractionInView:self.view exceptViewWithTag:TAG_SHARE_SKY_BTN];
        
        //待修改:不在走游动动画
        [self isTimeProcessSpiriteFlyTraceTouch];

    }else
    {
        //自动飞行时，目的点取spiriteAutoFlyPointArray
        needStopSpiriteAnimationToFlyAuto = YES;
        [self isTimeProcessSpiriteFlyTraceTouch];

    }
    
    //每次飞行动画时开始时禁止自动飞行，避免在飞行过程中，再次触发自动飞行,飞行结束后，再次开始计时
    [spiriteFlyAutoReapaterTimer invalidate];

    
    
}


-(void) isTimeProcessSpiriteFlyTraceTouch
{
    CustomAnimation* backAni = (CustomAnimation*)swimOutAnimationSpiriteArray.lastObject;
    UIImageView* aniView = (UIImageView*)[backAni.aniImageViewDic objectForKey:KEY_ANIMATION_VIEW];
    CGPoint startPoint = aniView.center;
    CGPoint endPoint ;
    NSString* aniKey;
    if (spiriteFlyIsAuto) {
        //自动飞行时，顺次取位置
        spiriteAutoFlyPointCurrentIndex=(spiriteAutoFlyPointCurrentIndex+1)%spiriteAutoFlyPointArray.count;
        endPoint = [[spiriteAutoFlyPointArray objectAtIndex:spiriteAutoFlyPointCurrentIndex] CGPointValue];
        aniKey =KEY_ANIMATION_SPIRITE_FLY_AUTO;
    }else
    {
        //非自动时，用户点击位置
        endPoint = spiritFlyTouchPoint;
        aniKey =KEY_ANIMATION_SPIRITE_FLY_TRACE_TOUCH;

    }
    
    NSDictionary * timerUserInfo =[NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSValue valueWithCGPoint:startPoint], @"SpiritFlyStartPoint",
                                   [NSValue valueWithCGPoint:endPoint], @"SpiritFlyEndPoint",
                                   aniKey,@"SpiritFlyAniKey",
                                   nil];
    
    //控制在2秒内全部释放完成
    float timeInterval = SPIRITE_FLY_FLY_INTER_TIME/swimOutAnimationSpiriteArray.count;
    
    repeatCountSpiriteFlyTrace = 0;
    NSTimer* reapater =  [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(processSpiriteFlyTraceTouch:) userInfo:timerUserInfo repeats:YES];
    //立刻收回第一个
    [reapater fire];
    
}

-(void) processSpiriteFlyTraceTouch:(NSTimer *)timer
{
    NSDictionary *timerUserInfo = (NSDictionary *)timer.userInfo;

    CGPoint startP =[[timerUserInfo objectForKey:@"SpiritFlyStartPoint"] CGPointValue];
    CGPoint endP =[[timerUserInfo objectForKey:@"SpiritFlyEndPoint"] CGPointValue];
    NSString* aniKey =[timerUserInfo objectForKey:@"SpiritFlyAniKey"];

    
    if (repeatCountSpiriteFlyTrace != swimOutAnimationSpiriteArray.count&& swimOutAnimationSpiriteArray.count !=0) {
        
        NSAssert(repeatCountSpiriteFlyTrace<swimOutAnimationSpiriteArray.count, @"processSpiriteFlyTraceTouch: repeatCountSpiriteFlyTrace(%lu)>swimOutAnimationSpiriteArray(%lu)", repeatCountSpiriteFlyTrace, swimOutAnimationSpiriteArray.count);
        
        CustomAnimation* backAni = [swimOutAnimationSpiriteArray objectAtIndex:repeatCountSpiriteFlyTrace];
        
        [self animationSpiriteFlyTraceWithAni:backAni aniKey:aniKey  number:repeatCountSpiriteFlyTrace startP:startP endP:endP];
        repeatCountSpiriteFlyTrace ++;
        
    }else
    {
        [timer invalidate];
        repeatCountSpiriteFlyTrace = 0;
    }
    
    
}

-(void)startSpiritAutoFlyschedule
{
    CGFloat timeInterval = SPIRITE_FLY_AUTO_INTERVAL;
    
    spiriteFlyAutoReapaterTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(isTimeToSpiritAutoFly:) userInfo:nil repeats:NO];
    
    
}

-(void)isTimeToSpiritAutoFly:(NSTimer*) timer
{

    if (spiriteFlyIsAuto) {
        [self spiriteFlyTraceTouch:CGPointZero fromUserTouch:NO];
    }else
    {
        [timer invalidate];

    }
    
    
}


#pragma mark - 计算光的奖励
//return 奖励的个数
-(NSInteger) caculateAndGiveSunOrMoon:(NSString*) cacuKey
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
    if (totalHours <0) {
        NSString* timeAlert = [NSString stringWithFormat:(@"混乱，检测到时光倒流\n请调整时间！")];
        [self showCustomYesAlertSuperView:timeAlert AlertKey:KEY_REMINDER_GIVE_LIGHT_BUT_TIME_ERROR];
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        return HUGE_VAL;
    }
    
    
    //每3小时奖励一个光
    int giveCount = totalHours / BRING_UP_LIGHT_HOUR;
    [self.userInfo addSunOrMoonValue:giveCount];
    
    
    NSString* timeshow = [NSString stringWithFormat:(@"从%@ 开始养育 (%d) 光，养育了%d 小时，奖励 %d 个光"), startDate, [CommonObject checkSunOrMoonTime], totalHours, giveCount];
    NSLog(@"%@", timeshow);
    
    
    if (totalHours>0 && totalHours<BRING_UP_LIGHT_HOUR) {
        //NSString* timeAlert = [NSString stringWithFormat:(@"%@光托管了%d小时\n每3个小时奖励1个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        //[self showCustomYesAlertSuperView:timeAlert AlertKey:KEY_REMINDER_SUCC_GET_LIGHT];
        
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        
        return 0;

    }
    
    if (totalHours>=BRING_UP_LIGHT_HOUR) {
        NSString* timeAlert = [NSString stringWithFormat:(@"%@光养育了%d小时\n养成%d个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours, giveCount,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        [self showCustomYesAlertSuperView:timeAlert AlertKey:cacuKey];

        
        //清空光育成时间
        [self.userInfo updateSunorMoonBringupTime:0];
        
        return giveCount;
    }
    
    
    
    //清空光育成时间
    [self.userInfo updateSunorMoonBringupTime:0];
    
    return 0;

    
}

#pragma mark - Animation
-(void) moveSimpleLightWithRepeatCount:(NSInteger)count  StartPoint:(CGPoint) start  EndPoint:(CGPoint) end  totalTime:(float)totalTime aniKey:(NSString*) aniKey  withBazierP1:(CGPoint) bazierP1  bazierP2:(CGPoint) bazierP2
{
    
    [self DisableUserInteractionAllView:self.view];
    
    //计算此精灵的最终位置
    CGPoint startPoint =start;
    CGPoint endPoint = end;
    
    CGPoint bazierPoint_1;
    CGPoint bazierPoint_2;
    
    if (!CGPointEqualToPoint(bazierP1, CGPointZero)) {
        bazierPoint_1 = bazierP1;
    }else
    {
        //取得两点之间的中间点
        CGPoint mid = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
        bazierPoint_1 = CGPointMake(mid.x/3 -[CommonObject getRandomNumber:0 to:10], mid.y/3 -[CommonObject getRandomNumber:0 to:10]);
    }
    
    if (!CGPointEqualToPoint(bazierP2, CGPointZero)) {
        bazierPoint_2 = bazierP2;
    }else
    {
        //取得两点之间的中间点
        CGPoint mid = [CommonObject getMidPointBetween:startPoint andPoint:endPoint];
        bazierPoint_2 = CGPointMake(mid.x -[CommonObject getRandomNumber:20 to:40], mid.y -[CommonObject getRandomNumber:20 to:40]);
    }
    
    
    //限制飞行的光数
    if (count > FLY_BETWEEN_SKY_USERHEADER_MAX_COUNT) {
        count = FLY_BETWEEN_SKY_USERHEADER_MAX_COUNT;
    }
    
    NSDictionary * timerUserInfo =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:count],@"moveSimpleCount",
                                   [NSValue valueWithCGPoint:start], @"moveSimpleStartPoint",
                                   [NSValue valueWithCGPoint:end], @"moveSimpleEndPoint",
                                   aniKey,@"moveSimpleAniKey",
                                   [NSValue valueWithCGPoint:bazierPoint_1],@"moveSimpleBaziar1",
                                   [NSValue valueWithCGPoint:bazierPoint_2],@"moveSimpleBaziar2",
                                   nil];
    
    CGFloat delayTime = totalTime/count;
    
    repeatCountMoveSimpleLight =0;
    NSTimer* reapater = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(startMoveSimpleLightRepeat:) userInfo:timerUserInfo repeats:YES];
    [reapater fire];
    
  

 
}



-(void)startMoveSimpleLightRepeat:(NSTimer*) timer
{
    
    NSDictionary *timerUserInfo = (NSDictionary *)timer.userInfo;
    NSInteger count =[[timerUserInfo objectForKey:@"moveSimpleCount"] integerValue];
    CGPoint start = [[timerUserInfo objectForKey:@"moveSimpleStartPoint"] CGPointValue];
    CGPoint end = [[timerUserInfo objectForKey:@"moveSimpleEndPoint"] CGPointValue];
    CGPoint bazierP1 = [[timerUserInfo objectForKey:@"moveSimpleBaziar1"] CGPointValue];
    CGPoint bazierP2 = [[timerUserInfo objectForKey:@"moveSimpleBaziar2"] CGPointValue];
    NSString * aniKey =[timerUserInfo objectForKey:@"moveSimpleAniKey"];

    
    if (repeatCountMoveSimpleLight != count) {
        
        BOOL isLastOne;
        if (repeatCountMoveSimpleLight +1 == count) {
            isLastOne = YES;
        }else
        {
            isLastOne = NO;

        }
        
        [self moveSimpleLightWithStartPoint:start EndPoint:end aniKey:aniKey withBazierP1:bazierP1 bazierP2:bazierP2 isLastOne:isLastOne];
        repeatCountMoveSimpleLight ++;
        
    }else
    {
        [timer invalidate];
        repeatCountMoveSimpleLight = 0;

    }
    
    
}


-(void) moveSimpleLightWithStartPoint:(CGPoint) start  EndPoint:(CGPoint) end aniKey:(NSString*) aniKey  withBazierP1:(CGPoint) bazierP1  bazierP2:(CGPoint) bazierP2 isLastOne:(BOOL)isLastOne
{
    
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    //计算此精灵的最终位置
    CGPoint startPoint =start;
    CGPoint endPoint = end;
    //计算此精灵的最终大小
    CGSize  startSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
    CGSize endSize = CGSizeMake(LIGHT_W_H, LIGHT_W_H);
    [customAnimation setAniBazierCenterPoint1:bazierP1];
    [customAnimation setAniBazierCenterPoint2:bazierP2];
    
    //构造光view
    UIImageView* srcView = [[UIImageView alloc] initWithImage:[CommonObject getBaseLightImageByTime]];
    srcView.frame = CGRectZero;
    [self.view addSubview:srcView];
    NSDictionary* srcViewDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                srcView, KEY_ANIMATION_VIEW,
                                [NSNumber numberWithInteger:[CommonObject getBaseLightTypeByTime]], KEY_ANIMATION_LIGHT_TYPE,nil];
    
    if (isLastOne) {
        lastRepeatCountMoveSimpleLightView = srcView;
    }else
    {
        lastRepeatCountMoveSimpleLightView = Nil;
    }
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:srcViewDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setBkLayerBelow:_lightPostionFrame.layer];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setAniStartSize:startSize];
    [customAnimation setAniEndSize:endSize];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:aniKey];
    [customAnimation setAniDuration:SIMPLE_FLY_EVERY_LIGHT_TIME];
    [customAnimation setAniRepeatCount:1];
    
    [customAnimation setSipiriteAnimationType:[CommonObject getBaseLightTypeByTime]];
    [customAnimation displayLinkAnimationEnable];
    
    [customAnimation startCustomAnimation];
    
    
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

    //定为光环不变化
    realRange = 7;
    
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
            lightBowSkyUserHeaderViewWidth = _userHeaderImageView.frame.size.width+65;
            lightBowSkyUserHeaderViewHeigth = _userHeaderImageView.frame.size.height+65;
        }else
        {
            lightBowSkyUserHeaderViewWidth = lightBowSkyUserHeaderViewWidth+IntervalWidth*2;
            lightBowSkyUserHeaderViewHeigth = lightBowSkyUserHeaderViewHeigth+IntervalWidth*2;
        }

        [lightUserHeaderTag setFrame:CGRectMake(_userHeaderImageView.center.x-lightBowSkyUserHeaderViewWidth/2, _userHeaderImageView.center.y-lightBowSkyUserHeaderViewHeigth/2, lightBowSkyUserHeaderViewWidth, lightBowSkyUserHeaderViewHeigth)];
        lightUserHeaderTag.animationDuration=1.0;
        [self.view insertSubview:lightUserHeaderTag belowSubview:userHeaderSpiritBk];
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

#pragma mark - Customer alert
-(void) showCustomYesAlertSuperView:(NSString*) msg  AlertKey:(NSString*) alertKey
{
    
    
    customAlertAutoDisYes = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:[CommonObject getAlertBkByTime]  yesBtnImageName:@"OK.png" posionShowMode:userSet  AlertKey:alertKey];
    [customAlertAutoDisYes setStartCenterPoint:self.view.center];
    [customAlertAutoDisYes setEndCenterPoint:self.view.center];
    [customAlertAutoDisYes setStartAlpha:0.1];
    [customAlertAutoDisYes setEndAlpha:1.0];
    [customAlertAutoDisYes setStartHeight:0];
    [customAlertAutoDisYes setStartWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndHeight:customAlertAutoDisYes.endWidth];
    [customAlertAutoDisYes setDelayDisappearTime:4.0];
    [customAlertAutoDisYes setMsgFrontSize:35];
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
    customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:[CommonObject getDelayBkByTime]  yesBtnImageName:nil posionShowMode:userSet AlertKey:nil];
    [customAlertAutoDis setStartHeight:0];
    [customAlertAutoDis setStartWidth:SCREEN_WIDTH/5*4];
    [customAlertAutoDis setEndWidth:SCREEN_WIDTH/5*4];
    [customAlertAutoDis setEndHeight:customAlertAutoDis.endWidth*216/547];
    [customAlertAutoDis setStartCenterPoint:self.view.center];
    [customAlertAutoDis setEndCenterPoint:self.view.center];
    [customAlertAutoDis setStartAlpha:0.1];
    [customAlertAutoDis setEndAlpha:0.8];
    [customAlertAutoDis setDelayDisappearTime:4.0];
    [customAlertAutoDis setMsgFrontSize:35];
    [customAlertAutoDis setAlertMsg:msg];
    [customAlertAutoDis RunCumstomAlert];
    
}

#pragma mark - CustomAlertDelegate
- (void) CustomAlertOkAnimationFinish:(NSString*) alertKey
{
    NSLog(@"custom aler ok return");
    if ([alertKey isEqualToString:KEY_IS_GIVE_FIRST_LIGHT]) {
        
        [self EnableUserInteractionInView:self.view];
        
        //第一个光回到头像
        [self refreshLightStateForCallBackOrPopout:1];
        


    }
    
    
    if ([alertKey isEqualToString:KEY_REMINDER_PAN_FOR_LIGHT]) {
        
        [self EnableUserInteractionInView:self.view];
        
        //起动：giudStep_guidPanToBring_waitForPan
        [self HandleGuidProcess:giudStep_guidPanToBring_waitForPan];

        
    }
    
    if ([alertKey isEqualToString:KEY_REMINDER_GETINTO_CAMERA]) {
        
        [self EnableUserInteractionInView:self.view];

        //起动：guidStep_guidIntoCamera_waitForTouch
        [self HandleGuidProcess:guidStep_guidIntoCamera_waitForTouch];
        
        
    }
    
    if ([alertKey isEqualToString:KEY_REMINDER_HOW_TO_GET_SPIRITE]) {
        
        [self EnableUserInteractionInView:self.view];
        
        //判断是否要起动：guidStep_guidIntoCamera
        //[guidInfo RemoveTouchIndication];
        [self.haloToReminber removeFromSuperlayer];

        [self HandleGuidProcess:guidStep_guidIntoCamera];
        
        
    }
    
    
    //从相机奖励，或， 连续登录奖励，刷新光状态
    if ([alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT_FROM_CAMERA] ||
        [alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT_FROM_CONTINUE_LOGIN]) {
        
        [self refreshLightStateForCallBackOrPopout:1];
        
        
    }
    
    //点击头像，
    //或，拖回头像
    if ([alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT_FROM_INTOHOME] || [alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT_FROM_PAN_TO_USERHEADER]) {
        
        //直接全收回，不显示新奖励的光,收回动画完成后，进入小屋
        [self refreshLightStateForCallBackOrPopout:0];
        //更新为光无养育
        [self.userInfo updateisBringUpSunOrMoon:NO];
        [self refreshLightCircleStatForUserHeaderOrSunMoon];


    }
    
    if ([alertKey isEqualToString:KEY_REMINDER_GIVE_LIGHT_BUT_TIME_ERROR]) {
        
        //什么也不做，返回
        
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

- (IBAction)backSegueFromViewController:(UIStoryboardSegue *)segue
{
    UIViewController *sourceViewController = segue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[HomeInsideViewController class]]) {
        
        isFromLowView = TRUE;
    }
    
    
}



#pragma mark - 引导滑屏
- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    EAIntroPage *page2 = [EAIntroPage page];
    EAIntroPage *page3 = [EAIntroPage page];
    EAIntroPage *page4 = [EAIntroPage page];



    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    
    if (SCREEN_HEIGHT>480) {
        page1.titleImage = [UIImage imageNamed:@"引导1.png"];
        page2.titleImage = [UIImage imageNamed:@"引导2.png"];
        page3.titleImage = [UIImage imageNamed:@"引导3.png"];
        page4.titleImage = [UIImage imageNamed:@"引导4.png"];


    }else
    {
        page1.titleImage = [UIImage imageNamed:@"引导1-4.png"];
        page2.titleImage = [UIImage imageNamed:@"引导2-4.png"];
        page3.titleImage = [UIImage imageNamed:@"引导3-4.png"];
        page4.titleImage = [UIImage imageNamed:@"引导4-4.png"];


    }
 
    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    
    
    
    intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
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
    
    [self animationBowLightFrameHeaderView:1];
    
    if (self.userInfo.userType == USER_TYPE_NEW || (self.userInfo.userType == USER_TYPE_NEED_CARE && [self.userHeaderImageView isEqual:[UIImage imageNamed:@"默认头像.png"]])) {
        [self.userInfo updateUserType:USER_TYPE_TYE];
        [self editUserHeader];
    }else
    {
        //进入小屋,先收回的育成才能进入
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            
            //计算育成的时间，奖励光
            if ([self caculateAndGiveSunOrMoon:KEY_REMINDER_GIVE_LIGHT_FROM_INTOHOME]>0) {
                //等用户点击OK时进入小屋
            }else
            {
                //待完成收回动画后，再进入小屋
                [self refreshLightStateForCallBackOrPopout:0];
                //更新为光无养育
                [self.userInfo updateisBringUpSunOrMoon:NO];
                [self refreshLightCircleStatForUserHeaderOrSunMoon];

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
                if ([self caculateAndGiveSunOrMoon:KEY_REMINDER_GIVE_LIGHT_FROM_INTOHOME]>0) {
                    //等用户点击OK时进入小屋
                }else
                {
                    //[self callBackLight];
                    //待完成收回动画后，再进入小屋
                    [self refreshLightStateForCallBackOrPopout:0];
                    
                }
                
                
                //光被召回了，更新养育状态
                [self.userInfo updateisBringUpSunOrMoon:NO];
                [self refreshLightCircleStatForUserHeaderOrSunMoon];
                
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

#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
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
- (IBAction)testButton1:(id)sender
{
    
//    giveLingtCout = 1;
//    [userInfo addSunOrMoonValue:1];
//    [self reFreshCaculateAndPopOutLightSpirite];
    
    
    
    
}
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
