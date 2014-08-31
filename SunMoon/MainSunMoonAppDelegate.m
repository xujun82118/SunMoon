//
//  MainSunMoonAppDelegate.m
//  SunMoon
//
//  Created by songwei on 14-3-30.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "MainSunMoonAppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboApi.h"


@interface MainSunMoonAppDelegate ()

@property (nonatomic, strong) UIWindow * statusWindow;
@property (nonatomic, strong) UILabel * statusLabel;

@property (nonatomic, strong) UserInfo * userInfo;

@property (nonatomic, strong) UserInfoCloud* userCloud;

- (void) dismissStatus;

@end


@implementation MainSunMoonAppDelegate

@synthesize userInfo =_userInfo,userCloud=_userCloud;
//@synthesize viewDelegate = _viewDelegate;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //test 解决相机起动黑屏问题
    self.window.backgroundColor = [UIColor whiteColor];
    
    //ShareSDK 设置
    [ShareSDK registerApp:@"fe35485ae4a"];
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"3318551146" appSecret:@"88fd372af9e86ae0c8fa25df1fd6b61d" redirectUri:@"http://com.weibo"];
    
    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
    [ShareSDK connectTencentWeiboWithAppKey:@"801517498"
                                  appSecret:@"521685f57c6f8e365028e089c642d7fa"
                                redirectUri:@"https://itunes.apple.com/cn/app/tian-tian-geng-mei-li/id782426992?mt=8"
                                   wbApiCls:[WeiboApi class]];
    
    //添加微信应用
    [ShareSDK connectWeChatWithAppId:@"wx4e89a3a1551f87e9" wechatCls:[WXApi class]];
    
    //添加QQ应用
    [ShareSDK connectQQWithQZoneAppKey:@"100586310"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
     //添加腾讯微博应用
     [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
     appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
     redirectUri:@"http://www.sharesdk.cn"];
    
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
     
     //添加QQ空间应用
     [ShareSDK connectQZoneWithAppKey:@"100371282"
     appSecret:@"aed9b0303e3ed1e27bae87c33761161d"];
     

    
    return YES;
}


- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
    
    NSLog(@"Recieved Notification %@",notif);
    NSDictionary* infoDic = notif.userInfo;
    NSLog(@"userInfo description=%@",[infoDic description]);
    NSString* codeStr = [infoDic objectForKey:ALERT_SUN_MOON_TIME];
    NSLog(@"codeStr is  %@", codeStr);
    
    NSString* Mesg = nil;
    if ([codeStr isEqualToString:ALERT_IS_SUN_TIME]) {

        
    
    }else if ([codeStr isEqualToString:ALERT_IS_MOON_TIME])
    {

        
        
    }
    
    if (Mesg != nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:Mesg
                              delegate:nil
                              cancelButtonTitle:@"Yes"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}


/**
 * @brief 在状态栏显示 一些Log
 *
 * @param string 需要显示的内容
 * @param duration  需要显示多长时间
 */
+ (void) showStatusWithText:(NSString *) string duration:(NSTimeInterval) duration {
    
    MainSunMoonAppDelegate * delegate = (MainSunMoonAppDelegate *) [UIApplication sharedApplication].delegate;
    
    delegate.statusLabel.text = string;
    [delegate.statusLabel sizeToFit];
    CGRect rect = [UIApplication sharedApplication].statusBarFrame;
    CGFloat width = delegate.statusLabel.frame.size.width;
    CGFloat height = rect.size.height;
    rect.origin.x = rect.size.width - width - 5;
    rect.size.width = width;
    delegate.statusWindow.frame = rect;
    delegate.statusLabel.frame = CGRectMake(0, 0, width, height);
    
    if (duration < 1.0) {
        duration = 1.0;
    }
    if (duration > 4.0) {
        duration = 4.0;
    }
    [delegate performSelector:@selector(dismissStatus) withObject:nil afterDelay:duration];
}

/**
 * @brief 干掉状态栏文字
 */
- (void) dismissStatus {
    CGRect rect = self.statusWindow.frame;
    rect.origin.y -= rect.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.statusWindow.frame = rect;
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    

    _userInfo= [UserInfo  sharedSingleUserInfo];
    //云同步
    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    //[self.userCloud upateUserInfo:self.userInfo];
    

    //3小时内不重复通知
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    NSDate* lastNotifyNeed = [userBaseData objectForKey:KEY_NOTIFY_NEED_BRINGING_LAST_TIME];
    NSDate* lastNotifyIs = [userBaseData objectForKey:KEY_NOTIFY_IS_BRINGING_LAST_TIME];
    NSTimeInterval timeNeed =[[NSDate date] timeIntervalSinceDate:lastNotifyNeed];
    NSTimeInterval timeIs =[[NSDate date] timeIntervalSinceDate:lastNotifyIs];

    int daysNeed=((int)timeNeed)/(3600*24);
    int hoursNeed=((int)timeNeed)%(3600*24)/3600;
    int totalHoursNeed = daysNeed*24+hoursNeed;
    
    int daysIs=((int)timeIs)/(3600*24);
    int hoursIs=((int)timeIs)%(3600*24)/3600;
    int totalHoursIs = daysIs*24+hoursIs;
   
    //构造通知
    alertNotification=[[UILocalNotification alloc] init];
    alertNotification.fireDate = Nil;
    alertNotification.repeatInterval = kCFCalendarUnitDay;
    alertNotification.timeZone=[NSTimeZone defaultTimeZone];
    alertNotification.soundName = @"cute.mp3";
    
    NSString* temp;
    if ([_userInfo checkIsBringUpinSunOrMoon] && (totalHoursIs>REMINDER_INTERVEL_TIME || totalHoursIs<0 || lastNotifyIs == nil)) {
        
        //告知会用在养育光了
        temp = [NSString stringWithFormat:@"我在养育%@光了，等你回来哦!",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        
        alertNotification.alertBody = temp;

        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
        
        //更新本次时间
        [userBaseData setObject:[NSDate date] forKey:KEY_NOTIFY_IS_BRINGING_LAST_TIME];
        [userBaseData synchronize];
        
    }else if(totalHoursNeed>REMINDER_INTERVEL_TIME || totalHoursNeed<0 || lastNotifyNeed == nil)
    {
        temp = [NSString stringWithFormat:@"哎呦，没有把%@光托付给我唉!",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        
        alertNotification.alertBody = temp;
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
        
        //更新本次时间
        [userBaseData setObject:[NSDate date] forKey:KEY_NOTIFY_NEED_BRINGING_LAST_TIME];
        [userBaseData synchronize];
    }

    
}


- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo
{
    
    NSLog(@"Syn UserInfo Succ!");
    
    [CommonObject showAlert:@"同步数据成功！" titleMsg:Nil DelegateObject:self];
    
    alertNotification=[[UILocalNotification alloc] init];

    alertNotification.fireDate = Nil;
    alertNotification.repeatInterval = kCFCalendarUnitDay;
    alertNotification.timeZone=[NSTimeZone defaultTimeZone];
    alertNotification.soundName = @"cute.mp3";
    
    //NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_SUN_TIME forKey:ALERT_SUN_MOON_TIME];
    //alertNotification.userInfo = info;
    
    alertNotification.alertBody = @"同步成功！";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
}


- (void) getUserInfoFinishFailed
{
    [CommonObject showAlert:@"同步数据失败, 请检查网络！" titleMsg:Nil DelegateObject:self];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
