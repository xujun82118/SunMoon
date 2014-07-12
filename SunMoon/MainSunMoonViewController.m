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
#import "ImageFilterViewController.h"
#import "WeatherLoc.h"
#import "AminationCustom.h"
#import "AddWaterMask.h"

@interface MainSunMoonViewController ()
{
    BOOL  isFromHeaderBegin;
    BOOL  isFromSunMoonBegin;
    UIImageView* bringupImageView;    //光育成中要用的动画View
    UIImageView*  lightSkySunOrMoonView; //太阳或月亮闪烁动画View
    UIImageView*  lightSkyUserHeaderView; //头像闪烁动画View


    
    CALayer *panSunOrMoonlayer;  //拖动的动画图层
    
    //BOOL isStartMoveBringupImageAnimation; //是否开始执行了移动光的动画，暂不知道如何指定各个动画的委托
    
    BOOL isStartSunOrmoonImageMoveToHeaderAnimation;//起动了向头像移动光的动画
    BOOL isStartSunOrmoonImageMoveToSunMoonAnimation;//起动了向日月移动光的动画
    
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
    BOOL isHaveOpen = [userBaseData boolForKey:@"isFirstlyOpen"];
    
    
    //获取用户账号    
    self.userInfo= [UserInfo  sharedSingleUserInfo];
    
    //第一次起动，使用默认用户
    if (isHaveOpen == 0)
    {
        NSLog(@"New User, Opened firstly!");
        [userBaseData setBool:YES forKey:@"isFirstlyOpen"];
        [userBaseData synchronize];
        
        //起动引导界面
        //优化：不要占用第一个界面
        //[self showIntroWithCrossDissolve];

        //初始化用户为新用户
        self.userInfo = [self.userInfo initDefaultInfoAtFirstOpenwithTime:[CommonObject getCurrentTime]];

        
    }else
    {
        NSLog(@"Opened normally!");
        self.userInfo = [self.userInfo getUserInfoAtNormalOpen];
    }

    //获取同一个数据库，注：userDB不能放到userInfo中，会发生错误，原因不明
    userDB = [[UserDB alloc] init];
    

    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    //加载头像
    self.userHeaderImageView.image = self.userInfo.userHeaderImage;
    
    
    //创建拖动轨迹识别
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    panSunOrMoonlayer=[[CALayer alloc]init];
    
    lightSkyUserHeaderView=[[UIImageView alloc] init];

    
    //增加点击识别，进入拍照，或回归光到头像, 拖动也可让光回到头像
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSkySumOrMoonhandle:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 1;
    _skySunorMoonImage.userInteractionEnabled = YES;
    [_skySunorMoonImage addGestureRecognizer:recognizer];

    
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

    //self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBarHidden = YES;
    //self.navigationController.navigationBar.backgroundColor = [UIColor yellowColor];
//    self.navigationController.navigationBar.alpha = 0.1;
//    self.navigationController.navigationBar.opaque = YES;
//    self.navigationController.toolbarHidden = YES;
    //[self.navigationItem setNewTitle:@"测试"];
    
    //头像闪烁动画view
    for (int i=0 ; i<7; i++) {
        UIImageView* lightUserHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lightCircle.png"]];
        lightUserHeader.tag = TAG_LIGHT_USER_HEADER+i;
        lightUserHeader.userInteractionEnabled=YES;
        lightUserHeader.contentMode=UIViewContentModeScaleToFill;
        lightUserHeader.hidden = YES;
        [self.view addSubview:lightUserHeader];
        //NSLog(@"create-----tag=%d", lightUserHeader.tag);
        
    }

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"---->viewDidAppear");

    
    WeatherLoc* testWeather = [[WeatherLoc alloc] init];
   //[testWeather startGetWeather];
    //[testWeather startGetWeatherSimple];
    
    //test
    //self.userInfo.userType =USER_TYPE_NEW;
    
    if (self.userInfo.userType == USER_TYPE_NEW) {

        [self whenFirstlyOpenViewHandle];
        
    }else
    {
        [self whenCommonOpenViewHandle];
        
    }
    


}


-(void)whenFirstlyOpenViewHandle
{
    
    //第一次打开，奖励一个光值
    //优化：动画提示
    [self.userInfo  addSunOrMoonValue:1];
    
    NSLog(@"第一次起动，移动一个光到头像");
    [self moveLightWithRepeatCount:1 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];
    
    isStartSunOrmoonImageMoveToHeaderAnimation = YES;

    
}

-(void)whenCommonOpenViewHandle
{
    
    //test
    //[self animationLightFrameHeaderViewSetRange:10 isUseSetRange:YES];
    
    
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
            [CommonObject showAlert:@"当天阳光或月光时间连续登录，光值+1" titleMsg:@"提示" DelegateObject:self];
            
            [self moveLightWithRepeatCount:1 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:YES];
            
            isStartSunOrmoonImageMoveToHeaderAnimation = YES;
            
            
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
            [self animationLightFrameSkySunOrMoon:10];
            NSLog(@"有光在育成， 闪烁。。");


        }else
        {
            //头像闪烁
            if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
                NSLog(@"开启头像闪烁动画！");
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
                
            }else
            {
                NSLog(@"开启头像闪烁动画！");
                [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
                
            }
            
            
        }
    }
    
}


//点击日月
-(IBAction)TapSkySumOrMoonhandle:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
       
        if ([self.userInfo checkIsBringUpinSunOrMoon]) {
            
            NSLog(@"有光在育成，移动到头像");
            
            [self moveLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
            
            isStartSunOrmoonImageMoveToHeaderAnimation =  YES;
            
            [self.userInfo updateisBringUpSunOrMoon:NO];
        }else
        {
            NSLog(@"没有光在育成，进入拍照");
            [self doCamera:nil];
            
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
    }else
    {
        if (self.userInfo.moon_value == 0) {
            NSLog(@"moon_value==0 handlePan return");
            return;
        }
        
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    
    //**************从头像拖动到日月*************
    BOOL isLightInHeader = NO;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        if (self.userInfo.isBringUpSun == NO  ) {
            isLightInHeader = YES;
        }
    }else
    {
        if (self.userInfo.isBringUpMoon == NO  ) {
            isLightInHeader = YES;
        }
        
    }
    
    if (isLightInHeader) {
        //有光在头像中，可以开始从头像的拖动识别！
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
            
            CGRect tapRect = CGRectMake(location.x-20, location.y-20, _userHeaderImageView.frame.size.width, _userHeaderImageView.frame.size.height);
            
            CGRect intersect = CGRectIntersection(_userHeaderImageView.frame, tapRect);
            //同一区域
            if (intersect.size.width > 10 || intersect.size.height > 10)
            {
                NSLog(@" 开始拖动手势： 起点：头像之内！");
                isFromHeaderBegin = YES;
                //_panSunorMoonImageView.image =[UIImage imageNamed:@"sun.png"];
                _panSunorMoonImageView.center = _userHeaderImageView.center;
                //_panSunorMoonImageView.frame = _userHeaderImageView.frame;
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
            
            _panSunorMoonImageView.center = location;
            _panSunorMoonImageView.alpha = 1.0;
            
        }
        
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            //是否在太阳，月亮区
            CGRect tapRect = CGRectMake(location.x-20, location.y-20, _skySunorMoonImage.frame.size.width, _skySunorMoonImage.frame.size.height);
            
            CGRect intersect = CGRectIntersection(_skySunorMoonImage.frame, tapRect);
            //同一区域
            if (intersect.size.width > 10 || intersect.size.height > 10)
            {
                
                NSLog(@" 结束拖动手势： 终点：日月之内！");
                //            _panSunorMoonImageView.center = location;
                //            _panSunorMoonImageView.alpha = 1.0;
                if (isFromHeaderBegin) {
                    NSLog(@"光被拖回日月育成！");
                    [self moveLightWithRepeatCount:0 StartPoint:_userHeaderImageView.center EndPoint:_skySunorMoonImage.center IsUseRepeatCount:NO];
                    isStartSunOrmoonImageMoveToSunMoonAnimation = YES;
                    
                    //更新为有光在育成
                    [self.userInfo updateisBringUpSunOrMoon:YES];
                }else
                {
                    NSLog(@"不是从 头像 开始！");

                }
                
                isFromHeaderBegin = NO;

                //开启日月闪烁
                //[self animationLightFrameSkySunOrMoon:10];
                
                //NSLog(@"结束头像闪烁");
                //[lightSkyUserHeaderView stopAnimating];
                
                
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
            isLightBringup = YES;
        }
    }else
    {
        if (self.userInfo.isBringUpMoon == YES  ) {
            isLightBringup = YES;
        }
        
    }
    
    if (isLightBringup) {
        //有光在日月中育成，可以开始从日月的拖动识别"
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
            
            CGRect tapRect = CGRectMake(location.x-20, location.y-20, _skySunorMoonImage.frame.size.width,
                                        _skySunorMoonImage.frame.size.height);
            
            CGRect intersect = CGRectIntersection(_skySunorMoonImage.frame, tapRect);
            //同一区域
            if (intersect.size.width > 10 || intersect.size.height > 10)
            {
                NSLog(@" 开始拖动手势： 起点：日月之内！");
                isFromSunMoonBegin = YES;
                _panSunorMoonImageView.image =[UIImage imageNamed:@"sun.png"];
                _panSunorMoonImageView.center = _skySunorMoonImage.center;
                //_panSunorMoonImageView.frame = _skySunorMoonImage.frame;
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
            
            _panSunorMoonImageView.center = location;
            _panSunorMoonImageView.alpha = 1.0;
            
        }
        
        
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            //是否在头像区
            CGRect tapRect = CGRectMake(location.x-20, location.y-20, _userHeaderImageView.frame.size.width, _userHeaderImageView.frame.size.height);
            
            CGRect intersect = CGRectIntersection(_userHeaderImageView.frame, tapRect);
            //同一区域
            if (intersect.size.width > 10 || intersect.size.height > 10)
            {
                
                NSLog(@" 结束拖动手势： 终点：头像之内！");

                if (isFromSunMoonBegin) {
                    NSLog(@"光被拖回头像！");
                    [self moveLightWithRepeatCount:0 StartPoint:_skySunorMoonImage.center EndPoint:_userHeaderImageView.center IsUseRepeatCount:NO];
                    isStartSunOrmoonImageMoveToHeaderAnimation = YES;
                    
                    //更新为无光在育成
                    [self.userInfo updateisBringUpSunOrMoon:NO];
                    if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
                        NSLog(@"开启头像闪烁动画！");
                        [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
                        
                    }else
                    {
                        NSLog(@"开启头像闪烁动画！");
                        [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
                        
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
                    
                    [self moveLightWithRepeatCount:1 StartPoint:location EndPoint:_skySunorMoonImage.center IsUseRepeatCount:YES];
                    
                    isStartSunOrmoonImageMoveToSunMoonAnimation = YES;
                    /*_panSunorMoonImageView.hidden = YES;
                     panSunOrMoonlayer.contents=_panSunorMoonImageView.layer.contents;
                     panSunOrMoonlayer.frame=_panSunorMoonImageView.frame;
                     panSunOrMoonlayer.opacity=1;
                     [self.view.layer addSublayer:panSunOrMoonlayer];
                     //动画 终点 都以sel.view为参考系
                     CGPoint endpoint=[self.view convertPoint:_skySunorMoonImage.center fromView:nil];
                     UIBezierPath *path=[UIBezierPath bezierPath];
                     //动画起点
                     CGPoint startPoint=[self.view convertPoint:location fromView:nil];
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
                     animation.fillMode = kCAFillModeRemoved;
                     animation.duration=0.8;
                     animation.delegate=self;
                     animation.autoreverses= NO;
                     animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                     [panSunOrMoonlayer addAnimation:animation forKey:@"backToSunMoon"];
                     */
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

    [gestureRecognizer setTranslation:location inView:self.view];
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
    
    
//    isStartSunOrmoonImageMoveToHeaderAnimation = YES;
//    _panSunorMoonImageView.hidden = YES;
    
    
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
    animation.removedOnCompletion = YES;
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

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSString* value=[(CAKeyframeAnimation*)anim valueForKey:@"position"];
    NSLog(@"animationDidStop----%@",value);
    
    if (isStartSunOrmoonImageMoveToHeaderAnimation) {
        
        //删除拖动动画图层
        [panSunOrMoonlayer removeFromSuperlayer];
        
        _panSunorMoonImageView.hidden = YES;

        isStartSunOrmoonImageMoveToHeaderAnimation = NO;
        
        //开启头像动画
        if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.sun_value intValue] isUseSetRange:YES];
        }else
        {
            [self animationLightFrameHeaderViewSetRange:[self.userInfo.moon_value intValue] isUseSetRange:YES];
            
        }
        
        NSLog(@"停止 日月 动画！");
        [lightSkySunOrMoonView stopAnimating];
        
    }
    
    if (isStartSunOrmoonImageMoveToSunMoonAnimation) {
        //删除拖动动画图层
        [panSunOrMoonlayer removeFromSuperlayer];
        
        _panSunorMoonImageView.hidden = YES;
        
        
        isStartSunOrmoonImageMoveToSunMoonAnimation = NO;
        
        //开启日月动画
        if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
            [self animationLightFrameSkySunOrMoon:[self.userInfo.sun_value intValue]];
        }else
        {
            [self animationLightFrameSkySunOrMoon:[self.userInfo.moon_value intValue]];
            
        }
        
        NSLog(@"停止 头像 动画！");
        //最多7个动画光环
        for (int i =0; i<7; i++) {
            UIImageView* lightUserHeader = (UIImageView*)[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
            //NSLog(@"stop-----tag=%d", lightUserHeader.tag);
            lightUserHeader.hidden = YES;
            [lightUserHeader stopAnimating];
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

    
    for (int i=0; i<10; i++) {
        
        NSString *name=[NSString stringWithFormat:@"abFrame_%d",i%10+1];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];
        
    }
    
    lightSkyUserHeaderView.image=[UIImage imageNamed:@"abFrame_9"];
    lightSkyUserHeaderView.userInteractionEnabled=YES;
    lightSkyUserHeaderView.contentMode=UIViewContentModeScaleToFill;
    lightSkyUserHeaderView.animationImages=iArr;
    [lightSkyUserHeaderView setFrame:CGRectMake(_userHeaderImageView.frame.origin.x-20, _userHeaderImageView.frame.origin.y-20, _userHeaderImageView.frame.size.width+40, _userHeaderImageView.frame.size.height+40)];
    lightSkyUserHeaderView.animationDuration=1;
    lightSkyUserHeaderView.animationRepeatCount = repeatCout;
    [self.view addSubview:lightSkyUserHeaderView];
    [self.view bringSubviewToFront:_userHeaderImageView];
    [lightSkyUserHeaderView startAnimating];
    
}

//头像闪烁
/*
-(void) animationLightFrameHeaderView:(NSInteger) range
{
    NSLog(@"开启头像闪烁动画, range=%d！", range);
    NSMutableArray *iArr= NULL;

    NSInteger bigRang = range/15+1;
    NSInteger smallRang = range%15;
    
    if (range > 100) {
        NSLog(@"增加彩虹！");
        [self animationRainbow:bigRang];
    }

    
    //一圈圈画光环
    for (int i = 0; i<bigRang; i++) {
        iArr = [self makeSmallRangAnimationLightFrameHeaderView:smallRang BigRang:i];
    }
    

    //初始动画底图
    lightSkyUserHeaderView.image=[UIImage imageNamed:@"abFrame_2"];
    lightSkyUserHeaderView.userInteractionEnabled=YES;
    lightSkyUserHeaderView.contentMode=UIViewContentModeScaleToFill;
    lightSkyUserHeaderView.animationImages=iArr;
    [lightSkyUserHeaderView setFrame:CGRectMake(_userHeaderImageView.frame.origin.x-20, _userHeaderImageView.frame.origin.y-20, _userHeaderImageView.frame.size.width+40, _userHeaderImageView.frame.size.height+40)];
    lightSkyUserHeaderView.animationDuration=1;
    [self.view addSubview:lightSkyUserHeaderView];
    [self.view bringSubviewToFront:_userHeaderImageView];
    [lightSkyUserHeaderView startAnimating];
 
}
*/

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


    NSInteger everyBigRangWidth = 10;
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
        

        
        UIImageView* lightUserHeader = (UIImageView* )[self.view viewWithTag:(TAG_LIGHT_USER_HEADER+i)];
        //NSLog(@"start-----tag=%d", lightUserHeader.tag);
        lightUserHeader.hidden = NO;
        lightUserHeader.animationImages=iArr;
        [lightUserHeader setFrame:CGRectMake(_userHeaderImageView.frame.origin.x-everyBigRangWidth*i-20, _userHeaderImageView.frame.origin.y-everyBigRangWidth*i-20, _userHeaderImageView.frame.size.width+everyBigRangWidth*2*i+40, _userHeaderImageView.frame.size.height+everyBigRangWidth*2*i+40)];
        lightUserHeader.animationDuration=1;
        [self.view bringSubviewToFront:_userHeaderImageView];
        [lightUserHeader startAnimating];
        
    }
    
}


-(NSMutableArray*) makeSmallRangAnimationSevenLightForHeaderView:(NSInteger) smallRang
{
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    
    //NSInteger everyBigRangWidth = 20;//每一级光环的宽

        
    for (int j=0; j<smallRang; j++) {
        NSString *name=[NSString stringWithFormat:@"abFrame_%d",j%10+1];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];

    }
    
    return iArr;
}

-(NSMutableArray*) makeSmallRangAnimationLightFrameHeaderView:(NSInteger) smallRang  BigRang:(NSInteger) bigRang
{
    
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    
    NSInteger lightCircleWidth = 5;//细光环宽
    NSInteger everyBigRangWidth = 6*lightCircleWidth;//每一级光环的宽

    //
//    if (bigRang>0) {
//        for (int i = 0; i<bigRang; i++) {
//            <#statements#>
//        }
//    }
    
    //test
    //smallRang = 15;
    
    //前6级加层细光图
    if (smallRang<=6 && smallRang>0) {
        NSLog(@"细光图---动画！");
        UIImage* lightCircle = [UIImage imageNamed:@"lightCircle.png"];
        UIImage* backCircle = NULL;
        for (int i=0; i<smallRang; i++) {
            
            //加大i光圈
            NSInteger w = lightCircle.size.width+i*15;
            NSInteger h = lightCircle.size.height+i*15;
            w = w+bigRang*everyBigRangWidth;
            h = h+bigRang*everyBigRangWidth;
            NSInteger x = 0;
            NSInteger y = 0;

            //画圈圈,每一个图多一圈
            CGSize drawSize = CGSizeMake(w,h);
            UIGraphicsBeginImageContext(drawSize);
            [lightCircle drawInRect:CGRectMake(x,y,w,h)];
            NSLog(@"细光图,Draw one new outside circle : %d, %d, %d, %d", x,y,w,h);
            if (backCircle) {
                NSInteger inCreaseW = w-backCircle.size.width;
                NSInteger inCreaseH = h-backCircle.size.height;
                [backCircle drawInRect:CGRectMake(inCreaseW/2,inCreaseH/2,backCircle.size.width,backCircle.size.height)];
                NSLog(@"细光图,Draw one inside circle : %d, %d, %f, %f", inCreaseW/2,inCreaseH/2,backCircle.size.width, backCircle.size.height);
                
            }
            backCircle = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            
            [iArr addObject:backCircle];
            
            
            
        }
    }
    //7到9为加层模糊光环
    if (smallRang>=7 && smallRang<=9) {
        NSLog(@"模糊光环---动画！");
        UIImage* lightCircle = [UIImage imageNamed:@"lightCircleBlured.png"];
        UIImage* backCircle = NULL;
        for (int i=0; i<smallRang-6; i++) {

            NSInteger x = 0;
            NSInteger y = 0;
            NSInteger w = lightCircle.size.width+i*15;
            NSInteger h = lightCircle.size.height+i*15;
            w = w+bigRang*everyBigRangWidth;
            h = h+bigRang*everyBigRangWidth;
            
            //画圈圈,每一个图多一圈
            CGSize drawSize = CGSizeMake(w,h);
            UIGraphicsBeginImageContext(drawSize);
            [lightCircle drawInRect:CGRectMake(x,y,w,h)];
            NSLog(@"模糊光环,Draw one new outside circle : %d, %d, %d, %d", x,y,w,h);
            if (backCircle) {
                NSInteger inCreaseW = w-backCircle.size.width;
                NSInteger inCreaseH = h-backCircle.size.height;
                [backCircle drawInRect:CGRectMake(inCreaseW/2,inCreaseH/2,backCircle.size.width,backCircle.size.height)];
                NSLog(@"模糊光环,Draw one inside circle : %d, %d, %f, %f", inCreaseW/2,inCreaseH/2,backCircle.size.width, backCircle.size.height);
                
            }
            backCircle = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            [iArr addObject:backCircle];
            
        }
    }
    
    //10到15闪烁光环
    if (smallRang>=10 && smallRang<=15) {
        NSLog(@"闪烁光环---动画！");
        for (int i=0; i<smallRang-10; i++) {
            
            NSString *name=[NSString stringWithFormat:@"abFrame_%d",i%10+1];
            UIImage *image=[UIImage imageNamed:name];
            
            //每一大环，扩大一圈
//            NSInteger x = 0;
//            NSInteger y = 0;
//            NSInteger w = _userHeaderImageView.frame.size.width;
//            NSInteger h = _userHeaderImageView.frame.size.height;
//            w = w+bigRang*everyBigRangWidth;
//            h = h+bigRang*everyBigRangWidth;
//            
//            UIGraphicsBeginImageContext(image.size);
//            [image drawInRect:CGRectMake(x, y, w, h)];
//            UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
            
            [iArr addObject:image];
            
        }
    }

    
    
    return iArr;
}


//太阳，月亮闪烁，提示有光在育成
-(void) animationLightFrameSkySunOrMoon:(NSInteger) range
{
    NSLog(@"开启日月闪烁！");

    
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<range; i++) {
        NSString *name=[NSString stringWithFormat:@"abFrame_%d",i%10+1];
        UIImage *image=[UIImage imageNamed:name];
        [iArr addObject:image];
    }
    
    lightSkySunOrMoonView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abFrame_2"]];
    lightSkySunOrMoonView.userInteractionEnabled=YES;
    lightSkySunOrMoonView.contentMode=UIViewContentModeScaleToFill;
    lightSkySunOrMoonView.animationImages=iArr;
    NSInteger lightSkySunOrMoonViewWidth = 80;
    NSInteger lightSkySunOrMoonViewHeigth = 80;

    [lightSkySunOrMoonView setFrame:CGRectMake(_skySunorMoonImage.center.x-lightSkySunOrMoonViewWidth/2, _skySunorMoonImage.center.y-lightSkySunOrMoonViewHeigth/2, lightSkySunOrMoonViewWidth, lightSkySunOrMoonViewHeigth)];
    lightSkySunOrMoonView.animationDuration=2;
    [self.view addSubview:lightSkySunOrMoonView];
    [self.view bringSubviewToFront:_skySunorMoonImage];
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

}



- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    page1.titleImage = [UIImage imageNamed:@"Guid-start"];
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}



#pragma mark  ------测试-------
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

#pragma mark 测试存用户数据
-(void) saveUserImage:(UIImage*)image  withTime: (NSString*) dateTime
{
    
    userInfo.date_time = dateTime;
    userInfo.sun_value = @"11";
    userInfo.sun_image_name = @"imagename";
    userInfo.sun_image_sentence = @"xxxx"; //xuj:待定
    userInfo.sun_image =UIImagePNGRepresentation(image);
    
    userInfo.moon_value = @"11";
    userInfo.moon_image_name = @"imagename";
    userInfo.moon_image_sentence = @"xxxx";//xuj:待定
    userInfo.moon_image =UIImagePNGRepresentation(image);
    
    [userDB saveUser:userInfo];
    
    
}

-(void) saveUserDataFromCamera:(NSDictionary*)imageData
{
    
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
    
    NSLog(@"userinfo --%@", userInfo.user_id);
    
    
}


- (IBAction)doCamera:(id)sender {
    
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
    [self presentViewController:controller
                       animated:NO
                     completion:^(void){
                         //NSLog(@"Picker View Controller is presented");
                     }];
    
    
    
}

#pragma mark - customimagePicker delegate
- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn
{
    
    ImageFilterProcessViewController*  fitler = [[ImageFilterProcessViewController alloc] init];

    [fitler setDelegate:self];
    [fitler setISunORMoon:[CommonObject checkSunOrMoonTime]];
    fitler.imagePickerData = imagePickerDataReturn;
    [self presentViewController:fitler animated:YES completion:NULL];
    

    
}

- (void)cancelCamera
{
    
    
}

#pragma mark - imagefilter delegate
#pragma mark 照完象， 存用户据
- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData
{
    //存图片到数据库
    
    //获取时间
    NSString* imageTime = [CommonObject getCurrentDate];
    NSLog(@"--image time =%@",  imageTime);
    

    [self saveUserDataFromCamera:imageFilterData];
    
    NSLog(@"---path=%@", [userDB getDBPath]);
    
    UserInfo* userer=[userDB getUserDataByDateTime:imageTime];
    
}



#pragma mark - userHeaderImageView getter
- (UIImageView *)userHeaderImageView {

        [_userHeaderImageView setFrame:CGRectMake(_userHeaderImageView.frame.origin.x, _userHeaderImageView.frame.origin.y, _userHeaderImageView.frame.size.width, _userHeaderImageView.frame.size.height)];
        [_userHeaderImageView.layer setCornerRadius:(_userHeaderImageView.frame.size.height/2)];
        _userHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_userHeaderImageView.layer setMasksToBounds:YES];
        [_userHeaderImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_userHeaderImageView setClipsToBounds:YES];
        _userHeaderImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _userHeaderImageView.layer.shadowOffset = CGSizeMake(4, 4);
        _userHeaderImageView.layer.shadowOpacity = 0.5;
        _userHeaderImageView.layer.shadowRadius = 2.0;
        _userHeaderImageView.layer.borderColor = [[UIColor redColor] CGColor];
        _userHeaderImageView.layer.borderWidth = 2.0f;
        _userHeaderImageView.layer.cornerRadius =30.0;
        _userHeaderImageView.userInteractionEnabled = YES;
        _userHeaderImageView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapUserHeader)];
        [_userHeaderImageView addGestureRecognizer:portraitTap];

    
    return _userHeaderImageView;
}

#pragma mark - 用户头像函数
-(void)handleTapUserHeader
{
    if (self.userInfo.userType == USER_TYPE_NEW || self.userInfo.userType == USER_TYPE_NEED_CARE) {
        [self.userInfo updateUserType:USER_TYPE_TYE];
        [self editUserHeader];
    }else
    {
        //进入小屋
        [self performSegueWithIdentifier:@"getintoHome" sender:self];
   
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
    
    if ([actionSheet.title isEqualToString:@"是否替换当前相片" ]) {
        //替换
        if (buttonIndex == 0) {
            
            
        } else if (buttonIndex == 1)//不替换
        {

        }
    }
    
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

@end
