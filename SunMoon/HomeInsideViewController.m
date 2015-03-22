//
//  HomeInsideViewController.m
//  SunMoon
//
//  Created by songwei on 14-4-6.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "HomeInsideViewController.h"
#import "Navbar.h"
#import "AddWaterMask.h"
#import "SunMoonAlertTime.h"
#import "ShareByShareSDR.h"



@interface HomeInsideViewController ()
{
    
    
    CustomAlertView* customAlertAutoDis;
    CustomAlertView* customAlertAutoDisYes;
    
    BOOL isFromLowView; //从下一层view来，不更新视图
    
    MONActivityIndicatorView *indicatorView;
    NSString* userDir;


}
/**
 *	@brief	用户信息更新
 *
 *	@param 	notif 	通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif;


@end

@implementation HomeInsideViewController
{
    
    NSDate* tmpStartData;
    
    NSInteger sunMoonRepeatCount;
    NSTimer* reapaterSunMoon;

}

@synthesize user,userData,userDB,sunMoonWordShow,currentSelectData;
@synthesize bkGroundImageView,sunMoonScrollImageView,sunTimeBtn,moonTimeBtn,sunMoonTimeCtlBtn,sunMoonValueStatic,sunMoonTimeText,lightSentence;
@synthesize cloudCtlBtn = _cloudCtlBtn,shareCtlBtn = _shareCtlBtn, voiceReplayBtn = _voiceReplayBtn;
@synthesize userCloud=_userCloud;
@synthesize editeSunWordBtn=_editeSunWordBtn,editeMoonWordBtn=_editeMoonWordBtn,deleteImageBtn=_deleteImageBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tmpStartData = [NSDate date];    
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.opaque = YES;
    //加返回按钮
//    NSInteger backBtnWidth = 50;
//    NSInteger backBtnHeight = 22;
//    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setImage:[UIImage imageNamed:@"返回-黄.png"] forState:UIControlStateNormal];
//    [backBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y-backBtnHeight/2+10, backBtnWidth, backBtnHeight)];
//    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
    
    //初始化时间
    _DayType = [CommonObject checkSunOrMoonTime];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    userDir= [paths objectAtIndex:0];

    
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
    
    //获取单例用户数据
    //self.user= [UserInfo  sharedSingleUserInfo];
    //重取一次数据
    //[self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;
    
    userDB = [[UserDB alloc] init];
    
    //云同步
    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    
    [_cloudCtlBtn setImage:[UIImage imageNamed:@"小云-touch.png"] forState:UIControlStateHighlighted];
//    [_shareCtlBtn setImage:[UIImage imageNamed:@"分享-touch.png"] forState:UIControlStateHighlighted];
//    [_shareMoonCtlBtn setImage:[UIImage imageNamed:@"分享-touch.png"] forState:UIControlStateHighlighted];

    
    //语音回放控制
    pressedVoiceForPlay = [[VoicePressedHold alloc] init];
    pressedVoiceForPlay.getPitchDelegate = self;
    //回放音按钮
    [_voiceReplayBtn setImage:[UIImage imageNamed:@"停止放音-白.png"] forState:UIControlStateSelected];

    
    //更新太阳月亮
    _sunMoonCenter.imageView.image = [CommonObject getBaseLightImageByTime];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ShareSDK removeAllNotificationWithTarget:self];
    isFromLowView = FALSE;

}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    //显示定时时间
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    if (_DayType==IS_SUN_TIME) {
        comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.sunAlertTime];
    }else
    {
        comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.moonAlertTime];
    }
    
    NSInteger hour = [comps hour];
    NSInteger miniute = [comps minute];
    NSString *timeString = [[NSString alloc] initWithFormat:
                            @"%d:%d", hour, miniute];
    if (_DayType==IS_SUN_TIME) {
        
        [sunTimeBtn setTitle:timeString forState:UIControlStateNormal];
        [sunTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else
    {
        [moonTimeBtn setTitle:timeString forState:UIControlStateNormal];
        [moonTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (!isFromLowView) {
        [self refreshUIForDayTypeViewWillAppear];
        
    }
    

    double deltaTime = [[NSDate date] timeIntervalSinceDate:tmpStartData];
    //NSLog(@">>>>>>>>>>cost time = %f ms", deltaTime*1000);

   
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!isFromLowView) {
        [self refreshUIForDayTypeViewDidAppear];

    }

    
}

-(void) refreshUIForDayTypeViewWillAppear
{
    
    //初始化指示器
    if (indicatorView) {
        [indicatorView stopAnimating];
    }
    indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 4;
    indicatorView.radius = SCREEN_WIDTH/50;
    indicatorView.internalSpacing = 4;
    indicatorView.center = CGPointMake(self.view.center.x, self.view.center.y - CUSTOM_ALERT_HEIGHT/2 - indicatorView.radius/2 - 10);
    [indicatorView startAnimating];
    [self.view addSubview:indicatorView];
    
    //云状态更新
    if (self.user.cloudSynAutoCtl) {
        [_cloudCtlBtn setImage:[UIImage imageNamed:@"云OK.png"] forState:UIControlStateNormal ];
    }else
    {
        [_cloudCtlBtn setImage:[UIImage imageNamed:@"小云.png"] forState:UIControlStateNormal ];
    }
    
    
    
    //更新太阳月亮
    if (_DayType == IS_SUN_TIME) {
        //_sunMoonCenter.imageView.image = [UIImage imageNamed:@"light-yellow-0.png"];
        [_sunMoonCenter setImage:[UIImage imageNamed:@"light-yellow-0.png"] forState:UIControlStateNormal];
        
        
    }else
    {
        //_sunMoonCenter.imageView.image = [UIImage imageNamed:@"light-white-0.png"];
        [_sunMoonCenter setImage:[UIImage imageNamed:@"light-white-0.png"] forState:UIControlStateNormal];

        
    }
    
    
    //更新闹钟控制
    if (_DayType==IS_SUN_TIME) {
        if(self.user.sunAlertTimeCtl)
        {
            [sunTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            sunTimeBtn.hidden = NO;
            [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        }else
        {
            
            sunTimeBtn.hidden = YES;
            [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
            
        }
        
        moonTimeBtn.hidden = YES;
    }else
    {
        if(self.user.moonAlertTimeCtl)
        {
            [moonTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            moonTimeBtn.hidden = NO;
            [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        }else
        {
            
            moonTimeBtn.hidden = YES;
            [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
            
        }
        sunTimeBtn.hidden = YES;
        
    }
    
    
    //更新语录控制
    if (_DayType==IS_SUN_TIME) {
        
        _editeSunWordBtn.hidden = NO;
        _editeMoonWordBtn.hidden = YES;
        
    }else
    {
        _editeSunWordBtn.hidden = YES;
        _editeMoonWordBtn.hidden = NO;
    }
    
    

}

-(void) refreshUIForDayTypeViewDidAppear
{
    

    
    
    //动态显示阳光，月光值
    
    //初始化数字
    sunMoonValueStatic.text = [NSString stringWithFormat:@"%d", 0];
    [reapaterSunMoon invalidate];
    [self animationIncreaseSunMoonValue];

    [self addScrollUserImageSunReFresh:YES];

    
}



-(void) addScrollUserImageSunReFresh:(BOOL) isFresh
{
    
    NSMutableArray *setSun = [[NSMutableArray alloc] init];
    
    //前nullCount为空，第nullCount+1为中间的位置，此处插入第一张相片,全屏显示fullCount张
    NSInteger nullCount;
    NSInteger fullCount;
    DeviceTypeVersion tempType = [CommonObject CheckDeviceTypeVersion];
    switch (tempType) {
        case iphone4_4s:
            nullCount = 1;
            fullCount = 3;
            break;
        case iphone5_5s:
            nullCount = 1;
            fullCount = 3;
            break;
        case iphone6:
            nullCount = 1;
            fullCount = 3;
            break;
        case iphone6Pluse:
            nullCount = 1;
            fullCount = 3;
            break;
            
        default:
            nullCount = 1;
            fullCount = 3;
            break;
    }
    
    //前4个为空，第5个为最新日期的照片
    NSString* nullImage;
    if (_DayType == IS_SUN_TIME) {
        nullImage = @"null-相片-黄.png";
    }else
    {
        nullImage = @"null-相片-白.png";
        
    }
    for (int i = 0; i<nullCount; i++) {

        [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [UIImage imageNamed:nullImage],@"image_data",
                           @"",@"image_name_time",
                           @"",@"image_sentence",
                           nil]];
    }
    
    //从第5张开始插入相片
    NSInteger count = [userData count];
    if (count>0) {
        
        //太阳数据
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            //构造带时间的照片
            //UIImage* addImageBk = [self addTimeToImage:[UIImage imageNamed:@"相框.png"] withTime:userInfo.sun_image_name];
            //UIImage* addImage = [self addToImage:[UIImage imageWithData:userInfo.sun_image] withBkImage:addImageBk];
            //传入dictionary，以携带更多信息
            NSInteger count;
            UIImage* addImage;
            NSString* imageName, *imageSentence;
            if (_DayType == IS_SUN_TIME) {
                addImage = [UIImage imageWithData:userInfo.sun_image];
                imageName =userInfo.sun_image_name;
                imageSentence =userInfo.sun_image_sentence;
                
            }else
            {
                addImage = [UIImage imageWithData:userInfo.moon_image];
                imageName =userInfo.moon_image_name;
                imageSentence =userInfo.moon_image_sentence;
                
            }
            if (addImage != Nil) {
                
                [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   addImage,@"image_data",
                                   imageName,@"image_name_time",//name 即为时间
                                   imageSentence,@"image_sentence",
                                   nil]];
            }
            
            
        }
        
    }
    
    //第一次起动初始化时照片为空，前端4张固定为空
    NSInteger realCount = count + nullCount;
    
    
    //全屏相示8张相片，小于8张的用默认图片填充
    if (realCount<fullCount) {
        for (int i = realCount; i<fullCount; i++) {
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIImage imageNamed:nullImage],@"image_data",
                               @"",@"image_name_time",
                               @"",@"image_sentence",
                               nil]];
            
        }
        
    }
    
    
    //取第一张默认相片的尺寸
    CGSize size = [[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    
    
    //取得时间轴的相对位置
    UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
    //如果时间轴高度小于相片的高度，则缩小相片,使时间轴包进相片,此时的frame还未autolayout
    //    if (scrollPosition.frame.size.height<=size.height) {
    //        float rat = size.width/size.height;
    //        size.height = scrollPosition.frame.size.height -5;
    //        size.width = size.height*rat;
    //
    //    }
    
    
    
    
    if (isFresh) {
        [imageScrollSun removeFromSuperview];
        //清空日期等
        sunMoonTimeText.text = @"";
        sunMoonWordShow.text = @"";
        
    }
    
    imageScrollSun = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-10, SCREEN_WIDTH, scrollPosition.frame.size.height+20)];
    [imageScrollSun setItemSize:size];
    [imageScrollSun setHeightOffset:20];//30
    [imageScrollSun setPositionRatio:2];
    [imageScrollSun setAlphaOfobjs:0.5];
    [imageScrollSun setMode:(int)_DayType];
    [imageScrollSun setScrollDelegate:self];
    [imageScrollSun setImageAry:setSun];
    //[self.view addSubview:imageScrollSun];
    [self.view insertSubview:imageScrollSun belowSubview:_sunMoonCenter];
    
    
}




-(void)refreshScrollUserImageSun
{
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;
    
    
    [self addScrollUserImageSunReFresh:YES];
    
    
}




- (void)viewDidLayoutSubviews
{
    
    [super viewDidLayoutSubviews];

}


/**
 * @brief 给相片增加日期时间
 *
 * @param image 要增加图片
 * @param time 要增加的时间字串
 */
- (UIImage*) addTimeToImage: (UIImage*) image  withTime:(NSString*) time
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addText:image text:time];
    
    return  imageAdd;
}


/**
 * @brief 给相片叠加时间底图
 *
 * @param timeImage 时间底图
 * @param image 加到底图上的原图
 */
- (UIImage*) addToImage: (UIImage*) image  withBkImage:(UIImage*) timeImage
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addImage:timeImage addMsakImage:image];
    
    return  imageAdd;
}




-(IBAction) back
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) animationIncreaseSunMoonValue
{
    
    //显示阳光，月光值, 从1增加到最大
    NSInteger count;
    if (_DayType == IS_SUN_TIME) {
        count = [[self.user getMaxUserSunValue] integerValue];

    }else
    {
        count = [[self.user getMaxUserMoonValue] integerValue];

    }
    
    if (count==0) {
        return;
    }

    [self startIncreaseSunMoonLightValue];
    
}


-(void) startIncreaseSunMoonLightValue
{
    
    NSInteger count;
    if (_DayType == IS_SUN_TIME) {
        count = [[self.user getMaxUserSunValue] integerValue];
        
    }else
    {
        count = [[self.user getMaxUserMoonValue] integerValue];
        
    }    //从最后30位开始
    float delayTime;
    NSInteger startCount = 15;
    if (count>startCount) {
        sunMoonValueStatic.text = [NSString stringWithFormat:@"%lu", count-startCount];
        sunMoonRepeatCount = sunMoonValueStatic.text.integerValue;
        delayTime = 0.1;
    }else
    {
        delayTime = 3/count;
        sunMoonRepeatCount = 0;
    }
    
    reapaterSunMoon =  [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(processIncreaseSunMoonLightValue:) userInfo:nil repeats:YES];
    //立刻收回第一个
    [reapaterSunMoon fire];
    
}


-(void) processIncreaseSunMoonLightValue:(NSTimer *)timer
{
    
    NSInteger count;
    if (_DayType == IS_SUN_TIME) {
        count = [[self.user getMaxUserSunValue] integerValue];
        
    }else
    {
        count = [[self.user getMaxUserMoonValue] integerValue];
        
    }
    if (sunMoonRepeatCount != count) {
        sunMoonValueStatic.text = [NSString stringWithFormat:@"%ld", [sunMoonValueStatic.text integerValue]+1];
        
        self.haloAdd = [PulsingHaloLayer layer];
        self.haloAdd.position = sunMoonValueStatic.center;
        self.haloAdd.radius = 0.5 * kMaxRadius;
        self.haloAdd.animationDuration = 0.5;
        self.haloAdd.eerepeatCount = 1;
        if (_DayType == IS_SUN_TIME) {
            self.haloAdd.backgroundColor = [UIColor yellowColor].CGColor;
            
        }else
        {
            self.haloAdd.backgroundColor = [UIColor whiteColor].CGColor;
            
        }
        [self.view.layer insertSublayer:self.haloAdd below:sunMoonValueStatic.layer];
        
        sunMoonRepeatCount ++;
        
    }else
    {
        [timer invalidate];
        sunMoonRepeatCount = 0;
    }
    
    
    
}



//暂时无用
- (IBAction)infoTextChanged:(id)sender
{
    
    if ([sunMoonTimeText.text isEqualToString:@""]) {
        
        sunMoonTimeText.hidden = YES;
        lightSentence.hidden = YES;
        sunMoonWordShow.hidden = YES;
        
    }else
    {
        sunMoonTimeText.hidden = NO;
        lightSentence.hidden = NO;
        sunMoonWordShow.hidden = NO;
     
    }

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

#pragma mark - 用户分享

/**
 * @brief 分享早上选中的相片
 *
 */

/**
 * @brief 分享早上选中的相片
 *
 */- (IBAction)shareSunMoon:(id)sender {
     
     //查看网络
     NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
     if (typeNet == netNon) {
         [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
         return;
     }
     
     
     UIImageView* imageData = [currentSelectData objectForKey:@"image_data"];
     NSString* imageSentence = [currentSelectData objectForKey:@"image_sentence"];
     
     if ([imageSentence isEqual:@""]) {
         return;
     }


     ShareByShareSDR* share = [ShareByShareSDR alloc];
     share.shareTitle = NSLocalizedString(@"appName", @"");
     share.shareImage =imageData.image;
     share.shareMsg = imageSentence;
     
     NSString* addShow = [NSString stringWithFormat:NSLocalizedString(@"CutScreenShareMsg", @""), [CommonObject getLightCharactorByTime]];
     share.shareMsgSignature = [addShow stringByAppendingString: NSLocalizedString(@"FromUri", @"")];

     NSString* tempShare;
     tempShare = [NSString stringWithFormat:@"我的天空养成了%@个%@光,", sunMoonValueStatic.text,(_DayType==IS_SUN_TIME)?@"阳":@"月"];
     if (_DayType == IS_SUN_TIME) {
        share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixSun", @"")];
        share.waterImage = [UIImage imageNamed:@"water-sun.png"];

     }else
     {
         share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixMoon", @"")];
         share.waterImage = [UIImage imageNamed:@"water-moon.png"];
     }

     share.timeString = sunMoonTimeText.text;
     share.lightCount = sunMoonValueStatic.text;
     share.senttence = sunMoonWordShow.text;
     share.customDelegate = self;
     
    [self ShareImageWitheWater:share.shareImage WaterImage:share.waterImage shareObject:share];

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



//增加水印
-(void) ShareImageWitheWater:(UIImage*) shareImage  WaterImage:(UIImage*)waterImage  shareObject:(ShareByShareSDR*) share
{
    
    //计算水印位置
    CGFloat w = shareImage.size.width;
    CGFloat h = shareImage.size.width*(waterImage.size.height/waterImage.size.width);
    CGFloat x = 0;
    CGFloat y = shareImage.size.height-h;
    share.waterRect = CGRectMake(x,y,w,h);
    [share addWater];
    
    //计算水印日期位置
    CGFloat w1 = 70;
    CGFloat h1 = 70*45/172;
    CGFloat x1 = shareImage.size.width/2-w1/2;
    CGFloat y1 = shareImage.size.height-15-h1/2;
    share.textRect = CGRectMake(x1,y1,w1,h1);
    [share addTimeText:@"timeImage-长.png"];
    
    //计算水印光个数的位置
    CGFloat w2 = 30;
    CGFloat h2 = 30;
    CGFloat x2 = shareImage.size.width/2-w2/2;
    CGFloat y2 = y+30;
    share.textRect = CGRectMake(x2,y2,w2,h2);
    [share addLightCounText];
    
    //计算水印语录的位置
    CGFloat w3 = (share.shareImage.size.width)/3*2;
    CGFloat h3 = 30;
    CGFloat x3 = (share.shareImage.size.width)/2-w3/2;
    CGFloat y3 = share.shareImage.size.height -40 -h3/2;
    share.textRect = CGRectMake(x3,y3,w3,h3);
    [share addSentenceText];
    
    
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
    [self.user updateSns_ID:[userInfo uid] PlateType:[userInfo type]];
    [self.user updateuserName:[userInfo nickname]];
    
    NSURL *portraitUrl = [NSURL URLWithString:[userInfo profileImage]];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [self.user updateUserHeaderImage:protraitImg];

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
    customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:[CommonObject getDelayBkByTimeType:_DayType]  yesBtnImageName:nil posionShowMode:userSet AlertKey:nil];
    [customAlertAutoDis setStartHeight:0];
    [customAlertAutoDis setStartWidth:CUSTOM_ALERT_WIDTH];
    [customAlertAutoDis setEndWidth:CUSTOM_ALERT_WIDTH];
    [customAlertAutoDis setEndHeight:CUSTOM_ALERT_HEIGHT];
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
    //if ([alertKey isEqualToString:KEY_IS_GIVE_FIRST_LIGHT]) {

        
        
    //}
    
 
    
}


#pragma mark -  云同步
-(IBAction)synClouderUserInfo:(id)sender
{
    
    //查看网络
    NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
    if (typeNet == netNon) {
        [self showCustomDelayAlertBottom:@"请检查网络"];

        return;
    }
    
    //查看是否注册
    if (!user.isRegisterUser) {
        [self showCustomYesAlertSuperView:@"请到设置中绑定注册" AlertKey:@"needRegister"];
        return;
    }
    
    if (self.user.cloudSynAutoCtl) {
        [self showCustomYesAlertSuperView:@"已开启自动云同步\n登录时自动同步" AlertKey:@"needRegister"];
    }else
    {
        //先获得现有用户云数据，对比后同步
        [_userCloud GetCloudUserInfo:self.user];
        
    }
    
    
    
}


- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo
{

    NSString* cloudSun = [userInfo objectForKey:@"sun_value"];
    NSString* cloudMoon = [userInfo objectForKey:@"moon_value"];
    if (![cloudSun  isEqualToString:self.user.sun_value] || ![cloudMoon isEqualToString: self.user.moon_value]) {
        NSLog(@"cloudSun or moon != local value!  --->checkAddCurrValueWithCloudSunVaule, 待优化！");
        [self.user checkAddCurrValueWithCloudSunVaule:cloudSun.integerValue MoonValue:cloudMoon.integerValue];
        
        //同步新数据
        [_userCloud upateUserInfo:self.user];

    }else
    {
        NSLog(@"cloudSun or moon == local value!");
        //[CommonObject showAlert:@"阳光或月光无增值, 无需同步" titleMsg:Nil DelegateObject:self];
        [self showCustomDelayAlertBottom:@"阳光和月光无增值, 无需同步" ];

    }
    


    
}


- (void) getUserInfoFinishFailed
{

    NSLog(@"getUserInfoFinishFailed---check reason!");
    
    //用户不存在， 同步新数据
    [_userCloud upateUserInfo:self.user];
    

}

- (void) getUserInfoFinishFailedByNetWork
{
    
    [self showCustomDelayAlertBottom:@"同步数据失败 请检查网络！"];


}


- (void) updateUserInfoSuccReturn
{
    
    NSString* logValue = [NSString stringWithFormat:@"同步成功\n阳光%@个 月光%@个", self.user.sun_value, self.user.moon_value];
    [self showCustomYesAlertSuperView:logValue AlertKey:@"synUserData"];
    
    sunMoonValueStatic.text =self.user.sun_value;
    NSLog(@"sun change to %@",sunMoonValueStatic.text);

}


- (void) updateUserInfoFailedReturn
{
    NSLog(@"updateUserInfoFailedReturn---check reason!");

}

- (void) updateUserInfoFailedReturnByNetWork
{

    [self showCustomDelayAlertBottom:@"同步数据失败 请检查网络！"];


}


#pragma mark -

- (IBAction)DeleteSunMoonImage:(id)sender
{
    
    NSString*  timeSun = [currentSelectData objectForKey:@"image_name_time"];
    if ([timeSun isEqualToString:@""]) {
        return;
    }
    
    [CommonObject showActionSheetOptiontitleMsg:@"确定删除相片?" ShowInView:self.view CancelMsg:@"不删除" DelegateObject:self Option:@"删除"];
    
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
         
    if ([actionSheet.title isEqualToString:@"确定删除相片?"]) {
        
        if (buttonIndex == 0) {
            //删除
            NSString* imageName = [currentSelectData objectForKey:@"image_name_time"];
            //查出包含此条的数据
            UserInfo* selectUserInfo = [userDB getUserDataByDateTime:imageName];
            
            if (selectUserInfo) {
                NSLog(@"删除相片：%@， type=%ld", selectUserInfo.date_time,_DayType);
                //置空删除的相片
                if (_DayType == IS_SUN_TIME) {
                    selectUserInfo.sun_image = Nil;
                    selectUserInfo.sun_image_name = @"";
                    selectUserInfo.sun_image_sentence = @"";
                }else
                {
                    selectUserInfo.moon_image = Nil;
                    selectUserInfo.moon_image_name = @"";
                    selectUserInfo.moon_image_sentence = @"";
                }
                //[userDB mergeWithUserByDateTime:selectUserInfo];
                [userDB deleteUserWithDataTime:selectUserInfo.date_time];
                [userDB saveUser:selectUserInfo];
            }else
            {
                NSLog(@"DeleteImage，错误，此条不存在!");
            }
            
            //删除语音
            NSString*  timeSunMoon = [currentSelectData objectForKey:@"image_name_time"];
            NSString* nameSunMoon = [NSString stringWithFormat:@"%@_%d", timeSunMoon, _DayType];
            [pressedVoiceForPlay setVoiceName:nameSunMoon];
            [pressedVoiceForPlay deleteVoiceFile];
            
            NSLog(@"刷新 阳光 数据");
            [self refreshScrollUserImageSun];
            
        }else if (buttonIndex == 1) {
            
            //不删除


            
        }

    }

    
}



#pragma mark - 回放语音
- (IBAction)replaySunMoonVoice:(id)sender
{

    NSString*  timeSun = [currentSelectData objectForKey:@"image_name_time"];
    if ([timeSun isEqualToString:@""]) {
        return;
    }
    
    NSString* nameSun = [NSString stringWithFormat:@"%@_%d", timeSun, _DayType];
    [pressedVoiceForPlay setVoiceName:nameSun];
 
    if (![pressedVoiceForPlay checkVoiceFile]) {
        return;
    }
    
    
    if (_voiceReplayBtn.selected == NO) {
        [pressedVoiceForPlay playRecording];
    }else
    {
        [pressedVoiceForPlay stopPlaying];

    }
    
    [_voiceReplayBtn setSelected:!_voiceReplayBtn.selected];

    
    
}

#pragma mark - picthDelegate
- (void)pitchAudioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    [_voiceReplayBtn setSelected:NO];

}


#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SetSunTime"]) {

        SunMoonAlertTime *destinationVC = (SunMoonAlertTime *)segue.destinationViewController;
        destinationVC.iSunORMoon = IS_SUN_TIME;
 
    }
    
    if ([[segue identifier] isEqualToString:@"SetMoonTime"]) {
        
        SunMoonAlertTime *destinationVC = (SunMoonAlertTime *)segue.destinationViewController;
        destinationVC.iSunORMoon = IS_MOON_TIME;
        
    }

}

- (IBAction)backSegueFromViewController:(UIStoryboardSegue *)segue
{
    UIViewController *sourceViewController = segue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[SunSentenceManagerViewController class]]) {
        
        isFromLowView = TRUE;
    }
    
    if ([sourceViewController isKindOfClass:[MoonSentenceManagerViewContrller class]]) {
        
        isFromLowView = TRUE;

    }
    
    if ([sourceViewController isKindOfClass:[SunMoonAlertTime class]]) {
        
        isFromLowView = TRUE;
        
    }
    
}


#pragma mark - 切换白天黑夜
- (IBAction)changeDayTime:(id)sender
{
    
    if (_DayType == IS_SUN_TIME) {
        _DayType = IS_MOON_TIME;
    }else
    {
        _DayType = IS_SUN_TIME;
    }
    
    NSString* day;
    if (_DayType == IS_SUN_TIME) {
        day = @"阳";
    }else
    {
        day = @"月";
    }
    [self showCustomDelayAlertBottom:[NSString stringWithFormat:NSLocalizedString(@"changeDay", @""), day] ];

    
    //显示定时时间
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    if (_DayType==IS_SUN_TIME) {
        comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.sunAlertTime];
    }else
    {
        comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.moonAlertTime];
    }
    
    NSInteger hour = [comps hour];
    NSInteger miniute = [comps minute];
    NSString *timeString = [[NSString alloc] initWithFormat:
                            @"%d:%d", hour, miniute];
    if (_DayType==IS_SUN_TIME) {
        
        [sunTimeBtn setTitle:timeString forState:UIControlStateNormal];
        [sunTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }else
    {
        [moonTimeBtn setTitle:timeString forState:UIControlStateNormal];
        [moonTimeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

    
    [self refreshUIForDayTypeViewWillAppear];
    [self refreshUIForDayTypeViewDidAppear];

    
    
}

#pragma mark - 闹钟控制
- (IBAction)sunMoonAlertCtl:(id)sender {

    BOOL isOpen;
    if (_DayType == IS_SUN_TIME) {
        [self.user updateSunAlertTimeCtl:!self.user.sunAlertTimeCtl];
        isOpen =self.user.sunAlertTimeCtl;

    }else
    {
        [self.user updateMoonAlertTimeCtl:!self.user.moonAlertTimeCtl];
        isOpen =self.user.moonAlertTimeCtl;

    }
   
    
    
    if(isOpen)
    {
        if (_DayType == IS_SUN_TIME) {
            sunTimeBtn.hidden = NO;

        }else
        {
            moonTimeBtn.hidden = NO;

        }
        [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        
        UILocalNotification *alertNotification = [[UILocalNotification alloc] init];
        
        if (alertNotification!=nil)
        {
            
            NSDate *alertTime = [UserInfo  sharedSingleUserInfo].sunAlertTime;
            
            alertNotification.fireDate = alertTime;
            alertNotification.repeatInterval = kCFCalendarUnitDay;
            alertNotification.timeZone=[NSTimeZone defaultTimeZone];
            alertNotification.soundName = UILocalNotificationDefaultSoundName;
            
            NSDictionary* info ;
            if (_DayType == IS_SUN_TIME) {
                info = [NSDictionary dictionaryWithObject:ALERT_IS_SUN_TIME forKey:ALERT_SUN_MOON_TIME];
                alertNotification.userInfo = info;
                
                alertNotification.alertBody = NSLocalizedString(@"Sun time is on", @"");
            }else
            {
                info = [NSDictionary dictionaryWithObject:ALERT_IS_MOON_TIME forKey:ALERT_SUN_MOON_TIME];
                alertNotification.userInfo = info;
                
                alertNotification.alertBody = NSLocalizedString(@"Moon time is on", @"");
            }

            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
        }
        
    }else
    {
        if (_DayType == IS_SUN_TIME) {
            sunTimeBtn.hidden = YES;
            
        }else
        {
            moonTimeBtn.hidden = YES;
            
        }
        [sunMoonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
        
        //清空原来所有的
        NSArray *myArray=[[UIApplication sharedApplication] scheduledLocalNotifications];
        for (int i=0; i<[myArray count]; i++)
        {
            UILocalNotification *myUILocalNotification=[myArray objectAtIndex:i];
            
            if (_DayType == IS_SUN_TIME) {
                if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_SUN_TIME])
                {
                    [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
                }
            }else
            {
                if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_MOON_TIME])
                {
                    [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
                }
            }
            

            
        }
        
    }
    
}

#pragma mark - InfiniteScrollPickerDelegate   
#pragma mark -  选择了其中一张照片
- (void)infiniteScrollPicker:(InfiniteScrollPicker *)infiniteScrollPicker didSelectAtImage:(UIImageView *)imageView
{
    //NSLog(@"selected index =%d", infiniteScrollPicker.selectedIndex);
    currentSelectData =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
    
    //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
    
    NSString* imageSentence    = [currentSelectData objectForKey:@"image_sentence"];
    
    sunMoonWordShow.text       = imageSentence;
    
    NSString* tempTime =[currentSelectData objectForKey:@"image_name_time"];
    if (![tempTime isEqualToString:@""]) {
        tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
        tempTime = [tempTime stringByAppendingString:@"日"];
    }
    sunMoonTimeText.text =tempTime;
    
    [self.view bringSubviewToFront:sunMoonTimeText];
    
    /*
    //太阳
    if (infiniteScrollPicker.mode == IS_SUN_TIME) {
        currentSelectData =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
        
        //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
        
        NSString* imageSentence    = [currentSelectData objectForKey:@"image_sentence"];

        sunMoonWordShow.text       = imageSentence;
        
        NSString* tempTime =[currentSelectData objectForKey:@"image_name_time"];
        if (![tempTime isEqualToString:@""]) {
            tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
            tempTime = [tempTime stringByAppendingString:@"日"];
        }
        sunMoonTimeText.text =tempTime;

        [self.view bringSubviewToFront:sunMoonTimeText];
    
        
        //将字摆到相片的中间对齐
//        UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
//        [sunMoonTimeText setContentMode:UIViewContentModeRedraw];
//        [sunMoonTimeText setNeedsDisplay];
//        [sunMoonTimeText setFrame:CGRectMake(scrollPosition.frame.origin.x+imageView.frame.origin.x+imageView.frame.size.width/2, sunMoonTimeText.frame.origin.y, sunMoonTimeText.frame.size.width, sunMoonTimeText.frame.size.height)];

  
//        NSLog(@"---sunMoonTimeText (%f,%f,%f,%f)", sunMoonTimeText.frame.origin.x,sunMoonTimeText.frame.origin.y, sunMoonTimeText.frame.size.width,sunMoonTimeText.frame.size.height);
        
        
        
    }else if (infiniteScrollPicker.mode == IS_MOON_TIME)//月亮
    {
        
    }
     */
    
}



- (void) InfiniteScrollViewWillBeginDragging:(InfiniteScrollPicker*)picker
{
    
    [UIView beginAnimations:@"TimeShowAnimationWhenDragging" context:(__bridge void *)(sunMoonTimeText)];
    [UIView setAnimationDuration:0.3f];
    
    sunMoonTimeText.alpha = 0.1;
    sunMoonWordShow.alpha = 0.1;
    
    _shareCtlBtn.alpha = 0.1;
    lightSentence.alpha = 0.1;
    
    _voiceReplayBtn.alpha = 0.1;
    
    _deleteImageBtn.alpha = 0.1;
   
    
    if (picker.mode == IS_SUN_TIME)
    {


        
        
    }else if (picker.mode == IS_MOON_TIME)
    {
        
    }
    
    [UIView commitAnimations];

}

- (void) InfiniteScrollViewDidEndScrollingAnimation:(InfiniteScrollPicker*)picker
{
    
    [indicatorView stopAnimating];
    
    [UIView beginAnimations:@"TimeShowAnimationEndDragging" context:(__bridge void *)(sunMoonTimeText)];
    [UIView setAnimationDuration:0.3f];
    sunMoonTimeText.alpha = 1;
    sunMoonWordShow.alpha = 1;
    
    _shareCtlBtn.alpha = 1;
    lightSentence.alpha = 1;
    
    _voiceReplayBtn.alpha = 1;
    
    _deleteImageBtn.alpha = 1;
    
    NSString*  timeSun = [currentSelectData objectForKey:@"image_name_time"];
    if ([timeSun isEqualToString:@""]) {
        //return;
    }
    
    NSString* nameSun = [NSString stringWithFormat:@"%@_%d", timeSun, _DayType];
    [pressedVoiceForPlay setVoiceName:nameSun];
    
    if (![pressedVoiceForPlay checkVoiceFile]) {
        [_voiceReplayBtn setImage:[UIImage imageNamed:@"放音-白.png"] forState:UIControlStateNormal];
    }else
    {
        [_voiceReplayBtn setImage:[UIImage imageNamed:@"放音-白-点.png"] forState:UIControlStateNormal];
    }
    
    
    if (picker.mode == IS_SUN_TIME)
    {

        
    }else if (picker.mode == IS_MOON_TIME)
    {
        
    }
    
    
    [UIView commitAnimations];
    
}


@end
