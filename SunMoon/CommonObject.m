//
//  CommonObject.m
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "CommonObject.h"
#import "CustomAlertView.h"


@implementation CommonObject


#pragma mark 时间函数
//格式化当前时间 199001101201
+ (NSString *)getCurrentTime
{
    NSDate *_date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTime = [[format stringFromDate:_date] substringToIndex:12];
    return dateTime;
}

//+ (NSString *)getCurrentDate
//{
//    NSDate *_date = [NSDate date];
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *dateTime = [[format stringFromDate:_date] substringToIndex:8];
//    return dateTime;
//}

+ (NSString *)getCurrentDate
{
    NSDate *_date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM"];
    NSString *month = [[format stringFromDate:_date] substringToIndex:2];
    month = [month stringByReplacingOccurrencesOfString:@"0" withString:@"" options:0 range:NSMakeRange(0, 1)];
    [format setDateFormat:@"dd"];
    NSString *day = [[format stringFromDate:_date] substringToIndex:2];
    day = [day stringByReplacingOccurrencesOfString:@"0" withString:@"" options:0 range:NSMakeRange(0, 1)];

    NSString* dateTime = [NSString stringWithFormat:@"%@.%@", month, day];

    return dateTime;
}

//+ (NSString *)getYesterdayDate
//{
//    NSDate *_date = [NSDate date];
//    
//    NSDateComponents* comps;
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:_date];
//
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *dateTime = [[format stringFromDate:_date] substringToIndex:8];
//    return dateTime;
//}

+(NSDate*) returnChooseTimeUnit:(NSDate*) dateTime Year:(BOOL) needYear Month:(BOOL) needMonth Day:(BOOL) needDay Hour:(BOOL) needHour Minute:(BOOL) needMinute Second:(BOOL) needSecond
{
    
    NSDateComponents* comps;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    comps =[calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour)fromDate:dateTime];
    
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];

    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    if (needYear) {
        [components setYear:year];
    }
    
    if (needMonth) {
        [components setMonth:month];
    }
    
    if (needDay) {
        [components setDay:day];
    }
    
    if (needHour) {
        [components setHour:hour];
    }
    
    if (needMinute) {
        [components setMinute:minute];
    }
    
    if (needSecond) {
        [components setSecond:second];
    }
    
    NSDate *fireDate = [calendar dateFromComponents:components];
    
    return  fireDate;
}


//判断是阳光还是月光,1:太阳，2：月亮
+ (NSInteger) checkSunOrMoonTime
{
    NSDate *_date = [NSDate date];
    
    NSDateComponents* comps;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:_date];
    NSInteger hour = [comps hour];
    
    if (hour<SUN_TIME_MAX && hour>=SUN_TIME_MIN) {
        return IS_SUN_TIME;
    }else
    {
        return IS_MOON_TIME;

    }
    
    
//    else if (hour<MOON_TIME_MAX || hour>=MOON_TIME_MIN)
//    {
//        return IS_MOON_TIME;
//    }

    
    
    return  0;
}


+(void)showAlert:(NSString *)msg titleMsg:(NSString *)title DelegateObject:(id) delegateObject{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:msg
                          delegate:delegateObject
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}

+(void)showActionSheetOptiontitleMsg:(NSString *)title ShowInView:(UIView*)view  CancelMsg:(NSString*) cancelMsg  DelegateObject:(id) delegateObject Option:(NSString*)option,...{

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:title
                                  delegate:delegateObject
                                  cancelButtonTitle:cancelMsg
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:option,nil];
    actionSheet.actionSheetStyle =UIActionSheetStyleBlackOpaque;
    
    [actionSheet showInView:view];
}


+ (NetConnectType) CheckConnectedToNetwork
{
    NSString *kindStr;
    int kind;
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags)
    {
        kindStr = @"获取信息失败";
        kind = -1;
    }
    else{
        //根据获得的连接标志进行判断
        BOOL isReachable = flags & kSCNetworkFlagsReachable;
        BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
        
        if((isReachable && !needsConnection)==YES)
        {
            ///能够连接网络
            if((flags& kSCNetworkReachabilityFlagsIsWWAN)==kSCNetworkReachabilityFlagsIsWWAN)
            {
                kindStr = @"手机网络";
                kind = netPhone;
                //[CommonObject showAlert:kindStr titleMsg:nil DelegateObject:nil];
            }
            else
            {
                kindStr =@"wifi连接网络";
                kind = netWifi;
                //[CommonObject showAlert:kindStr titleMsg:nil DelegateObject:nil];
            }
        }
        else{
            kindStr =@"不能连接网络";
            kind = netNon;
            //[CommonObject showAlert:kindStr titleMsg:nil DelegateObject:nil];
        }
    }
    return kind;
}

+ (DeviceTypeVersion) CheckDeviceTypeVersion
{
    //6: 375*667
    //6+:414*736
    
    if (SCREEN_HEIGHT == 480) {
        
        return iphone4_4s;
        
    }else if (SCREEN_HEIGHT == 568)
    {
        return iphone5_5s;
        
    }else if(SCREEN_HEIGHT == 667)
    {
        return iphone6;
        
    }else if(SCREEN_HEIGHT == 736)
    {
        return iphone6Pluse;
    }else
    {
        return iphoneOther;
    }
    
}

//BIGGEST_NUMBER:禁止所有的
//gustureRecogernaize不能禁止
+ (void)DisableUserInteractionInView:(UIView *)superView exceptViewWithTag:(NSInteger)enableViewTag
{
    
    for (NSUInteger i = 0; i < [superView.subviews count]; i++) {
        UIView *subView = [superView.subviews objectAtIndex:i];
        if (enableViewTag == BIGGEST_NUMBER) {
            [subView setUserInteractionEnabled:NO];

        }else
        {
            if (subView.tag != enableViewTag) {
                [subView setUserInteractionEnabled:NO];
                //NSLog(@"Disable userinteraction with view tag: %d of view:%@", subView.tag, [[subView class] description]);
            }else
            {
                [subView setUserInteractionEnabled:YES];
                //NSLog(@"Enable userinteraction with view tag: %d of view:%@", subView.tag, [[subView class] description]);
                
            }
        }
        

    }

    
}

+ (void)EnableUserInteractionInView:(UIView *)superView
{
    
    for (NSUInteger i = 0; i < [superView.subviews count]; i++) {
        UIView *subView = [superView.subviews objectAtIndex:i];
        [subView setUserInteractionEnabled:YES];
    }

}

@end
