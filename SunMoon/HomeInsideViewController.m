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
/**
 *	@brief	用户信息更新
 *
 *	@param 	notif 	通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif;


@end

@implementation HomeInsideViewController

@synthesize user,userData,userDB,sunWordShow,moonWordShow,currentSelectDataSun,currentSelectDataMoon,sunScroll=_sunScroll,moonScroll = _moonScroll;
@synthesize bkGroundImageView,sunScrollImageView,moonScrollImageView,sunTimeBtn,moonTimeBtn,moonTimeCtlBtn,sunTimeCtlBtn,sunValueStatic,moonValueStatic,sunTimeText,moonTimeText,lightSunSentence,lightMoonSentence;
@synthesize cloudCtlBtn = _cloudCtlBtn,shareSunCtlBtn = _shareSunCtlBtn, shareMoonCtlBtn=_shareMoonCtlBtn, voiceReplaySunBtn = _voiceReplaySunBtn, voiceReplayMoonBtn = _voiceReplayMoonBtn;
@synthesize userCloud=_userCloud;


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
 
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.opaque = YES;
    //加返回按钮
    NSInteger backBtnWidth = 18;
    NSInteger backBtnHeight = 22;
    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回-黄.png"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y-backBtnHeight/2+10, backBtnWidth, backBtnHeight)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

      //  sunScrollImageView.frame = CGRectMake(sunScrollImageView.frame.origin.x, sunScrollImageView.frame.origin.y, sunScrollImageView.frame.size.width, 20);
    
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
        id<ISSPlatformApp> app = [ShareSDK getClientWithType:type];

        if (type == ShareTypeSinaWeibo || type == ShareTypeTencentWeibo)
        {
            [_shareTypeArray addObject:[NSMutableDictionary dictionaryWithObject:[shareTypes objectAtIndex:i]
                                                                          forKey:@"type"]];
        }
    }
    
    NSArray *authList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()] atomically:YES];
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
//    [_shareSunCtlBtn setImage:[UIImage imageNamed:@"分享-touch.png"] forState:UIControlStateHighlighted];
//    [_shareMoonCtlBtn setImage:[UIImage imageNamed:@"分享-touch.png"] forState:UIControlStateHighlighted];
    
    if(self.user.sunAlertTimeCtl)
    {
        [sunTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        sunTimeBtn.hidden = NO;
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
    }else
    {

        sunTimeBtn.hidden = YES;
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
        
    }
    
    if(self.user.moonAlertTimeCtl)
    {
        [moonTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        moonTimeBtn.hidden = NO;
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        
    }else
    {

        moonTimeBtn.hidden = YES;
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
        
    }
    
    
    //语音回放控制
    pressedVoiceForPlay = [[VoicePressedHold alloc] init];
    //回放音按钮
    [_voiceReplaySunBtn setImage:[UIImage imageNamed:@"停止放音-白.png"] forState:UIControlStateSelected];
    [_voiceReplayMoonBtn setImage:[UIImage imageNamed:@"停止放音-白.png"] forState:UIControlStateSelected];

    
    
    //增加scroll图片,不能放在viewDidload中，会产生autolayout错误
    //临时解决方法，在viewDidAppear中重新布局MOON的位置
    //[self addScrollUserImageSunReFresh:NO];
    //[self addScrollUserImageMoonReFresh:NO];


}

-(void) loadView
{
    [super loadView];

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
            nullCount = 4;
            fullCount = 8;
            break;
        case iphone5_5s:
            nullCount = 2;
            fullCount = 5;
            break;
        case iphone6:
            nullCount = 2;
            fullCount = 5;
            break;
        case iphone6Pluse:
            nullCount = 3;
            fullCount = 6;
            break;
            
        default:
            nullCount = 4;
            fullCount = 9;
            break;
    }
    
    //前4个为空，第5个为最新日期的照片
    for (int i = 0; i<nullCount; i++) {
        [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [UIImage imageNamed:@"null-相片.png"],@"image_data",
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
            UIImage* addImage = [UIImage imageWithData:userInfo.sun_image];
            if (addImage != Nil) {
                
                [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   addImage,@"image_data",
                                   userInfo.sun_image_name,@"image_name_time",//name 即为时间
                                   userInfo.sun_image_sentence,@"image_sentence",
                                   nil]];
            }

            
        }
        
    }
   
    //第一次起动初始化时照片为空，前端4张固定为空
    NSInteger realCount = [setSun count] + nullCount;

    
    //全屏相示8张相片，小于8张的用默认图片填充
    if (realCount<fullCount) {
        for (int i = realCount; i<fullCount; i++) {
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIImage imageNamed:@"null-相片.png"],@"image_data",
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
        sunTimeText.text = @"";
        sunWordShow.text = @"";

    }

    imageScrollSun = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-10, SCREEN_WIDTH, scrollPosition.frame.size.height+20)];
    [imageScrollSun setItemSize:size];
    [imageScrollSun setHeightOffset:15];//30
    [imageScrollSun setPositionRatio:2];
    [imageScrollSun setAlphaOfobjs:0.5];
    [imageScrollSun setMode:IS_SUN_TIME];
    [imageScrollSun setScrollDelegate:self];
    [imageScrollSun setImageAry:setSun];
    [self.view addSubview:imageScrollSun];
    

}


-(void) addScrollUserImageMoonReFresh:(BOOL) isFresh
{
    NSMutableArray *setMoon = [[NSMutableArray alloc] init];
    //前4个为空，第5个为最新日期的照片
    //前nullCount为空，第nullCount+1为中间的位置，此处插入第一张相片,全屏显示fullCount张
    NSInteger nullCount;
    NSInteger fullCount;
    /*
    iphone6, 6+: 第3张在中间， 共5张
    iphone6+: 第3张在中间， 共5张
    iphone5s,5: 第4张在中间， 共6张
    iphone4,4s: 第5张在中间， 共9张
     */
    DeviceTypeVersion tempType = [CommonObject CheckDeviceTypeVersion];
    switch (tempType) {
        case iphone4_4s:
            nullCount = 3;
            fullCount = 8;
            break;
        case iphone5_5s:
            nullCount = 2;
            fullCount = 5;
            break;
        case iphone6:
            nullCount = 2;
            fullCount = 5;
            break;
        case iphone6Pluse:
            nullCount = 3;
            fullCount = 6;
            break;
            
        default:
            nullCount = 4;
            fullCount = 9;
            break;
    }
    
    
    for (int i = 0; i<nullCount; i++) {
        [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                           [UIImage imageNamed:@"null-相片.png"],@"image_data",
                           @"",@"image_name_time",
                           @"",@"image_sentence",
                           nil]];
        
    }
    
    //从第5张开始插入相片
    NSInteger count = [userData count];
    if (count>0) {
        
        //月亮数据
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            UIImage* addImage = [UIImage imageWithData:userInfo.moon_image];
            //传入dictionary，以携带更多信息
            if (addImage != Nil) {
                
                [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   addImage,@"image_data",
                                   userInfo.moon_image_name,@"image_name_time",//name 即为时间
                                   userInfo.moon_image_sentence,@"image_sentence",
                                   nil]];
            }
            
        }
        
    }
    
    NSInteger realCount = [setMoon count]+ nullCount;

    
    //全屏相示fullCount张相片，小于fullCount张的用默认图片填充
    if (realCount<fullCount) {
        for (int i = realCount; i<fullCount; i++) {
            [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageNamed:@"null-相片.png"],@"image_data",
                                @"",@"image_name_time",
                                @"",@"image_sentence",
                                nil]];
            
        }
        
    }
    
    
    //取第一张默认相片的尺寸
    CGSize size = [[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    
    
    if (isFresh) {
        
        [imageScrollMoon removeFromSuperview];
        //清空日期等
        moonTimeText.text = @"";
        moonWordShow.text = @"";
        
    }
    
    UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_MOON];
    
    
    imageScrollMoon = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-10, SCREEN_WIDTH, scrollPosition.frame.size.height+20)];
    [imageScrollMoon setImageAry:setMoon];
    [imageScrollMoon setItemSize:size];
    [imageScrollMoon setHeightOffset:15];
    [imageScrollMoon setPositionRatio:2];
    [imageScrollMoon setAlphaOfobjs:0.5];
    [imageScrollMoon setMode:IS_MOON_TIME];
    [imageScrollMoon setScrollDelegate:self];
    //[imageScrollMoon setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:imageScrollMoon];

    //imageScrollMoon.hidden = YES;
    
    
    
}



-(void)refreshScrollUserImageSun
{
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;


    [self addScrollUserImageSunReFresh:YES];

    
}

-(void)refreshScrollUserImageMoon
{
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;

    
    [self addScrollUserImageMoonReFresh:YES];
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ShareSDK removeAllNotificationWithTarget:self];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];


    
    /*
    UIImage *backButtonBackgroundImage = [UIImage imageNamed:@"返回.png"];
    // The background should be pinned to the left and not stretch.
    backButtonBackgroundImage = [backButtonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonBackgroundImage.size.width - 1, 0, 0)];
    
    id appearance = [UIBarButtonItem appearanceWhenContainedIn:[HomeInsideViewController class], nil];
    [appearance setBackButtonBackgroundImage:backButtonBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:NULL];
    self.navigationItem.backBarButtonItem = backBarButton;
    */
    
    //显示定时时间
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.sunAlertTime];
    NSInteger hour = [comps hour];
    NSInteger miniute = [comps minute];
    NSString *timeString = [[NSString alloc] initWithFormat:
                            @"%d:%d", hour, miniute];
    [sunTimeBtn setTitle:timeString forState:UIControlStateNormal];
    [sunTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.moonAlertTime];
    NSInteger hour1 = [comps hour];
    NSInteger miniute1 = [comps minute];
    NSString *timeString1 = [[NSString alloc] initWithFormat:
                             @"%d:%d", hour1, miniute1];
    [moonTimeBtn setTitle:timeString1 forState:UIControlStateNormal];
    [moonTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    //动态显示阳光，月光值
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(animateIncreaseValue:)
                                   userInfo:nil
                                    repeats:NO];
   
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //test,暂时成功，可能会有别的问题，时，需开启以下注释
    [self addScrollUserImageSunReFresh:YES];
    [self addScrollUserImageMoonReFresh:YES];

    
    if ([CommonObject CheckDeviceTypeVersion] == iphone6 ||[CommonObject CheckDeviceTypeVersion]== iphone6Pluse) {
        sunWordShow.font = [UIFont fontWithName:@"Arial" size:20];

    }else
    {
        sunWordShow.font = [UIFont fontWithName:@"Arial" size:12];

    }
    sunWordShow.textColor = [UIColor blackColor];
    sunWordShow.backgroundColor = [UIColor clearColor];
    sunWordShow.textAlignment = NSTextAlignmentCenter;
    sunWordShow.adjustsFontSizeToFitWidth = YES;
    sunWordShow.numberOfLines = 3;

    //重新布局MOON的位置
//    UIImageView* scrollPosition1 = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_MOON];
//    imageScrollMoon.frame = CGRectMake(0, scrollPosition1.frame.origin.y-10, SCREEN_WIDTH, scrollPosition1.frame.size.height+20);
//    imageScrollMoon.hidden = NO;

    
}


- (void)viewDidLayoutSubviews
{
    
    [super viewDidLayoutSubviews];

}

-(void) animateIncreaseValue:(NSTimer *)timer
{
    //显示阳光，月光值, 从1增加到最大
    int count = [[self.user getMaxUserSunValue] integerValue];
    for (int i = 0; i<=count; i++) {
        sunValueStatic.text = [NSString stringWithFormat:@"%d", i];
        sleep(0.5);
    }
    
    count = [[self.user getMaxUserMoonValue] integerValue];
    for (int i = 0; i<=count; i++) {
        moonValueStatic.text = [NSString stringWithFormat:@"%d", i];
        sleep(0.5);
    }
    
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




-(void) back
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


//暂时无用
- (IBAction)infoTextChanged:(id)sender
{
    
    if ([sunTimeText.text isEqualToString:@""]) {
        
        sunTimeText.hidden = YES;
        lightSunSentence.hidden = YES;
        sunWordShow.hidden = YES;
        
    }else
    {
        sunTimeText.hidden = NO;
        lightSunSentence.hidden = NO;
        sunWordShow.hidden = NO;
     
    }
    
    if ([moonTimeText.text isEqualToString:@""]) {
        
        moonTimeText.hidden = YES;
        lightMoonSentence.hidden = YES;
        moonWordShow.hidden = YES;
        
    }else
    {
        moonTimeText.hidden = NO;
        lightMoonSentence.hidden = NO;
        moonWordShow.hidden = NO;


        
    }
    
    
}

#pragma mark - 用户分享

/**
 * @brief 分享早上选中的相片
 *
 */
- (IBAction)shareNight:(id)sender {
    
    UIImageView* imageData = [currentSelectDataMoon objectForKey:@"image_data"];
    NSString* imageSentence = [currentSelectDataMoon objectForKey:@"image_sentence"];
    
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareTitle = NSLocalizedString(@"appName", @"");
    share.shareImage =imageData.image;
    share.shareMsg = imageSentence;
    share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
    NSString* tempShare;
    tempShare = [NSString stringWithFormat:@"养成了%@个月光,", moonValueStatic.text];
    share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixMoon", @"")];
    
    share.waterImage = [UIImage imageNamed:@"water-moon.png"];
    share.timeString = moonTimeText.text;
    share.lightCount = moonValueStatic.text;
    share.senttence = moonWordShow.text;
    
    [self ShareImageWitheWater:share.shareImage WaterImage:share.waterImage shareObject:share];
    
    [share shareImageNews];
    
    
}


/**
 * @brief 分享早上选中的相片
 *
 */- (IBAction)shareMorning:(id)sender {
     
     //test
//     ShareByShareSDR* share = [ShareByShareSDR alloc];
//     [share WeiBoMe];
     
     
     UIImageView* imageData = [currentSelectDataSun objectForKey:@"image_data"];
     NSString* imageSentence = [currentSelectDataSun objectForKey:@"image_sentence"];
     
     if ([imageSentence isEqual:@""]) {
         return;
     }


     ShareByShareSDR* share = [ShareByShareSDR alloc];
     share.shareTitle = NSLocalizedString(@"appName", @"");
     share.shareImage =imageData.image;
     share.shareMsg = imageSentence;
     share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
     NSString* tempShare;
     tempShare = [NSString stringWithFormat:@"养成了%@个阳光,", sunValueStatic.text];
     share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixSun", @"")];
     share.waterImage = [UIImage imageNamed:@"water-sun.png"];
     share.timeString = sunTimeText.text;
     share.lightCount = sunValueStatic.text;
     share.senttence = sunWordShow.text;
     
    [self ShareImageWitheWater:share.shareImage WaterImage:share.waterImage shareObject:share];
     
     [share shareImageNews];
     
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
    CGFloat w1 = 30;
    CGFloat h1 = 30;
    CGFloat x1 = 40;
    CGFloat y1 = share.shareImage.size.height -20 -h1/2;
    share.textRect = CGRectMake(x1,y1,w1,h1);
    [share addTimeText];
    
    //计算水印光个数的位置
    CGFloat w2 = 30;
    CGFloat h2 = 30;
    CGFloat x2 = 25;
    CGFloat y2 = y+30;
    share.textRect = CGRectMake(x2,y2,w2,h2);
    [share addLightCounText];
    
    //计算水印语录的位置
    CGFloat w3 = (share.shareImage.size.width);
    CGFloat h3 = 30;
    CGFloat x3 = (share.shareImage.size.width)/2-w3/2;
    CGFloat y3 = share.shareImage.size.height -25 -h3/2;
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
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()]];
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
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()] atomically:YES];
    
    
    //更新本地用户信息
    [self.user updateSns_ID:[userInfo uid] PlateType:[userInfo type]];
    [self.user updateuserName:[userInfo nickname]];
    
    NSURL *portraitUrl = [NSURL URLWithString:[userInfo profileImage]];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [self.user updateUserHeaderImage:protraitImg];

}


#pragma mark -  云同步
-(IBAction)synClouderUserInfo:(id)sender
{
    
    //查看网络
    NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
    if (typeNet == netNon) {
        [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
        return;
    }
    
    if (self.user.cloudSynAutoCtl) {
        [CommonObject showAlert:@"已开启自动云同步，退出时自动同步" titleMsg:Nil DelegateObject:self];
    }else
    {
        [_userCloud upateUserInfo:self.user];
        
    }
    
    
    
}

- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo
{

    NSLog(@"Syn UserInfo Succ!");
    
    [CommonObject showAlert:@"同步数据成功！" titleMsg:Nil DelegateObject:self];
    
    
}


- (void) getUserInfoFinishFailed
{
    [CommonObject showAlert:@"同步数据失败, 请检查网络！" titleMsg:Nil DelegateObject:self];
    
}

#pragma mark -
- (IBAction)DeleteMoonImage:(id)sender
{
    //空相片返回
    NSString*  timeMoon = [currentSelectDataMoon objectForKey:@"image_name_time"];
    if ([timeMoon isEqualToString:@""]) {
        return;
    }
    
    [CommonObject showActionSheetOptiontitleMsg:@"确定删除月光相片?" ShowInView:self.view CancelMsg:@"不删除" DelegateObject:self Option:@"删除"];
    

}
- (IBAction)DeleteSunImage:(id)sender
{
    
    NSString*  timeSun = [currentSelectDataSun objectForKey:@"image_name_time"];
    if ([timeSun isEqualToString:@""]) {
        return;
    }
    
    [CommonObject showActionSheetOptiontitleMsg:@"确定删除阳光相片?" ShowInView:self.view CancelMsg:@"不删除" DelegateObject:self Option:@"删除"];
    
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"确定删除月光相片?"]) {
        
        if (buttonIndex == 0) {
            //删除
            NSString* imageName = [currentSelectDataMoon objectForKey:@"image_name_time"];
            //查出包含此条的数据
            UserInfo* selectUserInfo = [userDB getUserDataByDateTime:imageName];
            
            if ([userDB getUserDataByDateTime:selectUserInfo.date_time]) {
                NSLog(@"DeleteNightImage, Datetime=%@， 此条存在，先删后插入新的一条!", selectUserInfo.date_time);
                [userDB deleteUserWithDataTime:selectUserInfo.date_time];
                //置空删除的相片
                selectUserInfo.moon_image = Nil;
                //重存此条数据
                [userDB saveUser:selectUserInfo];
            }else
            {
                NSLog(@"DeleteNightImage，错误，此条不存在!");
                [userDB saveUser:selectUserInfo];
            }
            
            //删除语音
            NSString*  timeMoon = [currentSelectDataMoon objectForKey:@"image_name_time"];
            NSString* nameMoon = [NSString stringWithFormat:@"%@_%d", timeMoon, IS_MOON_TIME];
            [pressedVoiceForPlay setVoiceName:nameMoon];
            [pressedVoiceForPlay deleteVoiceFile];
            
            NSLog(@"刷新 月光 数据");
            [self refreshScrollUserImageMoon];
            
        }else if (buttonIndex == 1) {
            
            //不删除
            
        }
    }
         
         
    if ([actionSheet.title isEqualToString:@"确定删除阳光相片?"]) {
        
        if (buttonIndex == 0) {
            //删除
            NSString* imageName = [currentSelectDataSun objectForKey:@"image_name_time"];
            //查出包含此条的数据
            UserInfo* selectUserInfo = [userDB getUserDataByDateTime:imageName];
            
            if (selectUserInfo) {
                NSLog(@"DeleteMorningImage, Datetime=%@， 此条存在，先删后插入新的一条!", selectUserInfo.date_time);
                [userDB deleteUserWithDataTime:selectUserInfo.date_time];
                //置空删除的相片
                selectUserInfo.sun_image = Nil;
                //重存此条数据
                [userDB saveUser:selectUserInfo];
            }else
            {
                NSLog(@"DeleteMorningImage，错误，此条不存在!");
                [userDB saveUser:selectUserInfo];
            }
            
            //删除语音
            NSString*  timeSun = [currentSelectDataSun objectForKey:@"image_name_time"];
            NSString* nameSun = [NSString stringWithFormat:@"%@_%d", timeSun, IS_SUN_TIME];
            [pressedVoiceForPlay setVoiceName:nameSun];
            [pressedVoiceForPlay deleteVoiceFile];
            
            NSLog(@"刷新 阳光 数据");
            [self refreshScrollUserImageSun];
            
        }else if (buttonIndex == 1) {
            
            //不删除


            
        }

    }

    
}



#pragma mark - 回放语音
- (IBAction)replaySunVoice:(id)sender
{

    NSString*  timeSun = [currentSelectDataSun objectForKey:@"image_name_time"];
    if ([timeSun isEqualToString:@""]) {
        return;
    }
    
    NSString* nameSun = [NSString stringWithFormat:@"%@_%d", timeSun, IS_SUN_TIME];
    [pressedVoiceForPlay setVoiceName:nameSun];
 
    if (![pressedVoiceForPlay checkVoiceFile]) {
        return;
    }
    
    
    if (_voiceReplaySunBtn.selected == NO) {
        [pressedVoiceForPlay playRecording];
    }else
    {
        [pressedVoiceForPlay stopPlaying];

    }
    
    [_voiceReplaySunBtn setSelected:!_voiceReplaySunBtn.selected];

    
    
}
- (IBAction)replayMoonVoice:(id)sender
{

    
    NSString*  timeMoon = [currentSelectDataMoon objectForKey:@"image_name_time"];
    if ([timeMoon isEqualToString:@""]) {
        return;
    }
    NSString* nameMoon = [NSString stringWithFormat:@"%@_%d", timeMoon, IS_MOON_TIME];
    [pressedVoiceForPlay setVoiceName:nameMoon];
    
    if (![pressedVoiceForPlay checkVoiceFile]) {
        return;
    }
    
    if (_voiceReplayMoonBtn.selected == NO) {
        [pressedVoiceForPlay playRecording];
    }else
    {
        [pressedVoiceForPlay stopPlaying];
        
    }

    [_voiceReplayMoonBtn setSelected:!_voiceReplayMoonBtn.selected];

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

#pragma mark - 闹钟控制

- (IBAction)moonAlertCtl:(id)sender {
    
    [self.user updateMoonAlertTimeCtl:!self.user.moonAlertTimeCtl];

    if(self.user.moonAlertTimeCtl)
    {
        moonTimeBtn.hidden = NO;
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        
        
        UILocalNotification *alertNotification = [[UILocalNotification alloc] init];

        if (alertNotification!=nil)
        {

            NSDate *alertTime = [UserInfo  sharedSingleUserInfo].moonAlertTime;

            alertNotification.fireDate = alertTime;
            alertNotification.repeatInterval = kCFCalendarUnitDay;
            alertNotification.timeZone=[NSTimeZone defaultTimeZone];
            alertNotification.soundName = @"cute.mp3";
            
            NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_MOON_TIME forKey:ALERT_SUN_MOON_TIME];
            alertNotification.userInfo = info;
            
            alertNotification.alertBody = NSLocalizedString(@"Moon time is on", @"");
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
        }

    }else
    {
        moonTimeBtn.hidden = YES;
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
        
        
        //清空原来所有的
        NSArray *myArray=[[UIApplication sharedApplication] scheduledLocalNotifications];
        for (int i=0; i<[myArray count]; i++)
        {
            UILocalNotification *myUILocalNotification=[myArray objectAtIndex:i];
            
            if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_MOON_TIME])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            }
            
        }
        
       
    }
    
}

- (IBAction)sunAlertCtl:(id)sender {
    
    [self.user updateSunAlertTimeCtl:!self.user.sunAlertTimeCtl];
   
    if(self.user.sunAlertTimeCtl)
    {
        sunTimeBtn.hidden = NO;
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-打开.png"] forState:UIControlStateNormal ];
        
        UILocalNotification *alertNotification = [[UILocalNotification alloc] init];
        
        if (alertNotification!=nil)
        {
            
            NSDate *alertTime = [UserInfo  sharedSingleUserInfo].sunAlertTime;
            
            alertNotification.fireDate = alertTime;
            alertNotification.repeatInterval = kCFCalendarUnitDay;
            alertNotification.timeZone=[NSTimeZone defaultTimeZone];
            alertNotification.soundName = @"cute.mp3";
            
            NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_SUN_TIME forKey:ALERT_SUN_MOON_TIME];
            alertNotification.userInfo = info;
            
            alertNotification.alertBody = NSLocalizedString(@"Sun time is on", @"");
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
        }
        
    }else
    {
        sunTimeBtn.hidden = YES;
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟-关闭.png"] forState:UIControlStateNormal ];
        
        //清空原来所有的
        NSArray *myArray=[[UIApplication sharedApplication] scheduledLocalNotifications];
        for (int i=0; i<[myArray count]; i++)
        {
            UILocalNotification *myUILocalNotification=[myArray objectAtIndex:i];
            
            if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_SUN_TIME])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            }
            
        }
        
    }
    
}

#pragma mark - InfiniteScrollPickerDelegate   
#pragma mark -  选择了其中一张照片
- (void)infiniteScrollPicker:(InfiniteScrollPicker *)infiniteScrollPicker didSelectAtImage:(UIImageView *)imageView
{
    //NSLog(@"selected index =%d", infiniteScrollPicker.selectedIndex);
    
    //太阳
    if (infiniteScrollPicker.mode == IS_SUN_TIME) {
        currentSelectDataSun =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
        
        //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
        
        NSString* imageSentence    = [currentSelectDataSun objectForKey:@"image_sentence"];

        sunWordShow.text       = imageSentence;
        
        NSString* tempTime =[currentSelectDataSun objectForKey:@"image_name_time"];
        if (![tempTime isEqualToString:@""]) {
            tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
            tempTime = [tempTime stringByAppendingString:@"日"];
        }
        sunTimeText.text =tempTime;

        [self.view bringSubviewToFront:sunTimeText];
    
        
        //将字摆到相片的中间对齐
//        UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
//        [sunTimeText setContentMode:UIViewContentModeRedraw];
//        [sunTimeText setNeedsDisplay];
//        [sunTimeText setFrame:CGRectMake(scrollPosition.frame.origin.x+imageView.frame.origin.x+imageView.frame.size.width/2, sunTimeText.frame.origin.y, sunTimeText.frame.size.width, sunTimeText.frame.size.height)];

  
//        NSLog(@"---sunTimeText (%f,%f,%f,%f)", sunTimeText.frame.origin.x,sunTimeText.frame.origin.y, sunTimeText.frame.size.width,sunTimeText.frame.size.height);
        
        
        
    }else if (infiniteScrollPicker.mode == IS_MOON_TIME)//月亮
    {
        currentSelectDataMoon =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
        //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
        NSString* imageSentence    = [currentSelectDataMoon objectForKey:@"image_sentence"];
        moonWordShow.text      = imageSentence;
       
        NSString* tempTime =[currentSelectDataMoon objectForKey:@"image_name_time"];
        if (![tempTime isEqualToString:@""]) {
            tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
            tempTime = [tempTime stringByAppendingString:@"日"];
        }
        moonTimeText.text =tempTime;

        [self.view bringSubviewToFront:moonTimeText];
        
    }
    
    
}



- (void) InfiniteScrollViewWillBeginDragging:(InfiniteScrollPicker*)picker
{
    
    [UIView beginAnimations:@"TimeShowAnimationWhenDragging" context:(__bridge void *)(sunTimeText)];
    [UIView setAnimationDuration:0.3f];
    
    if (picker.mode == IS_SUN_TIME)
    {
        sunTimeText.alpha = 0.1;
        sunWordShow.alpha = 0.1;
        
        _shareSunCtlBtn.alpha = 0.1;
        lightSunSentence.alpha = 0.1;
        
        _voiceReplaySunBtn.alpha = 0.1;

        
        
    }else if (picker.mode == IS_MOON_TIME)
    {
        
        moonTimeText.alpha = 0.1;
        moonWordShow.alpha = 0.1;
        
        _shareMoonCtlBtn.alpha = 0.1;
        lightMoonSentence.alpha = 0.1;

        _voiceReplayMoonBtn.alpha = 0.1;

    }
    
    [UIView commitAnimations];

}

- (void) InfiniteScrollViewDidEndScrollingAnimation:(InfiniteScrollPicker*)picker
{
    [UIView beginAnimations:@"TimeShowAnimationEndDragging" context:(__bridge void *)(sunTimeText)];
    [UIView setAnimationDuration:0.3f];

    
    if (picker.mode == IS_SUN_TIME)
    {
        sunTimeText.alpha = 1;
        sunWordShow.alpha = 1;
        
        _shareSunCtlBtn.alpha = 1;
        lightSunSentence.alpha = 1;

        _voiceReplaySunBtn.alpha = 1;
        
    }else if (picker.mode == IS_MOON_TIME)
    {
        
        moonTimeText.alpha = 1;
        moonWordShow.alpha = 1;
        
        _shareMoonCtlBtn.alpha = 1;
        lightMoonSentence.alpha = 1;

        _voiceReplayMoonBtn.alpha = 1;
        
    }
    
    //[self.view bringSubviewToFront:sunTimeText];
    [UIView commitAnimations];
    
}
@end
