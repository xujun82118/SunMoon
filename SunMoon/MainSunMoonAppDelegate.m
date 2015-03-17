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
#import "MainSunMoonViewController.h"
#import "UserSetViewController.h"
#import "WeiboSDK.h"

#import "iLink.h"

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

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    //[iLink sharedInstance].applicationBundleID = @"com.clickgamer.AngryBirds";
    //[iLink sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //[iLink sharedInstance].applicationVersion = @"1.0";
    
    //[iLink sharedInstance].globalPromptForUpdate = NO;
    // enable preview mode //  if YES would show prompt always //
    //[iLink sharedInstance].previewMode = YES;
}

- (void)iLinkDidFindiTunesInfo{
    NSLog(@"App local URL: %@", [iLink sharedInstance].iLinkGetAppURLforLocal );
    NSLog(@"App sharing URL: %@", [iLink sharedInstance].iLinkGetAppURLforSharing );
    NSLog(@"App rating URL: %@", [iLink sharedInstance].iLinkGetRatingURL );
    NSLog(@"App Developer URL: %@", [iLink sharedInstance].iLinkGetDeveloperURLforSharing);
    
    //[[iLink sharedInstance] iLinkOpenDeveloperPage]; // Would open developer page on the App Store
    //[[iLink sharedInstance] iLinkOpenAppPageInAppStoreWithAppleID:553834731]; // Would open a different app then the current, For example the paid version. Just put the Apple ID of that app.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    
    //ShareSDK 设置
    [ShareSDK registerApp:@"3e623a1fc526"];
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"1023688665" appSecret:@"9ba79b87a472d800fc92db7f9511a624" redirectUri:@"https://itunes.apple.com/cn/app/ri-yue-mei-pai/id929494640"];
    
    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
    [ShareSDK connectTencentWeiboWithAppKey:@"801546710"
                                  appSecret:@"8f2308b6c3ff569b3d368a847dd6e081"
                                redirectUri:@"https://itunes.apple.com/cn/app/ri-yue-mei-pai/id929494640"
                                   wbApiCls:[WeiboApi class]];
    
    //添加微信应用
    [ShareSDK connectWeChatWithAppId:@"wx453af9a98e9bde70" wechatCls:[WXApi class]];
    
    //添加QQ应用
    [ShareSDK connectQQWithQZoneAppKey:@"801546710"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];

     
     //添加QQ空间应用
     [ShareSDK connectQZoneWithAppKey:@"801546710"
     appSecret:@"8f2308b6c3ff569b3d368a847dd6e081"];
     

    
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
    alertNotification.timeZone=[NSTimeZone defaultTimeZone];
    alertNotification.soundName = UILocalNotificationDefaultSoundName;
    

    NSString* temp;
    if ([_userInfo checkIsBringUpinSunOrMoon] && (totalHoursIs>REMINDER_INTERVEL_TIME || totalHoursIs<0 || lastNotifyIs == nil)) {
        
        //告知在养育光了
        temp = [NSString stringWithFormat:@"正在养育%@光，等你回来啊",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];
        
        alertNotification.alertBody = temp;

        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
        
        //更新本次时间
        [userBaseData setObject:[NSDate date] forKey:KEY_NOTIFY_IS_BRINGING_LAST_TIME];
        [userBaseData synchronize];
        
    }else if(![_userInfo checkIsBringUpinSunOrMoon] && (totalHoursNeed>REMINDER_INTERVEL_TIME || totalHoursNeed<0 || lastNotifyNeed == nil))
    {
        //有光时，才提示
        BOOL alert;
        if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME && [_userInfo.sun_value integerValue]>0) {
            alert = YES;
        }else if([CommonObject checkSunOrMoonTime]==IS_MOON_TIME && [_userInfo.moon_value integerValue]>0)
        {
            alert = YES;

        }else
        {
            alert = FALSE;
        }
        
        if (alert) {
            temp = [NSString stringWithFormat:@"快回来呦，没有把%@光托付给%@",([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"太阳":@"月亮"];
            
            alertNotification.alertBody = temp;
            
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
            //更新本次时间
            [userBaseData setObject:[NSDate date] forKey:KEY_NOTIFY_NEED_BRINGING_LAST_TIME];
            [userBaseData synchronize];
        }

    }
    
    
    //记录后台时的时间
    [userBaseData setObject:[CommonObject getCurrentDate] forKey:KEY_BACK_GROUND_TIME];
    [userBaseData setInteger:[CommonObject checkSunOrMoonTime] forKey:KEY_BACK_GROUND_TIME_SUNMOON];
    [userBaseData synchronize];

    
}


- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo
{
    
    NSLog(@"Syn UserInfo Succ!");
    
    [CommonObject showAlert:@"同步数据成功！" titleMsg:Nil DelegateObject:self];
    
    alertNotification=[[UILocalNotification alloc] init];

    alertNotification.fireDate = Nil;
    alertNotification.timeZone=[NSTimeZone defaultTimeZone];
    alertNotification.soundName = UILocalNotificationDefaultSoundName;
    
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
    
    
    //初始化判断并更新时间,用于从后台进入前台时变换时间
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

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
