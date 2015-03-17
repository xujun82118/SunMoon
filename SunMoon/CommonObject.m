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



+(UIImage*) getUsedCameraImageNameByTime:(BOOL)isIndi
{
    
    if ([self checkSunOrMoonTime] == IS_SUN_TIME) {
        
        if (isIndi) {
            return [UIImage imageNamed:@"camera-white-indi.png"];

        }else
        {
            return [UIImage imageNamed:@"camera-white.png"];

        }
        
    }else
    {
        if (isIndi) {
            return [UIImage imageNamed:@"camera-yellow-indi.png"];
            
        }else
        {
            return [UIImage imageNamed:@"camera-yellow.png"];
            
        }
    }

}


+(NSString*) getUsedSunMoonImageNameByTime
{
    if ([self checkSunOrMoonTime] == IS_SUN_TIME) {
        return @"sun.png";
    }else
    {
        return @"moon.png";
    }
}


+(LightType) getSpiriteTypeByTime
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return lightTypeYellowSpirte;
        
    }else
    {
        return lightTypeWhiteSpirite;
        
    }
    
}

+(LightType) getBaseLightTypeByTime
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return lightTypeYellowLight;

    }else
    {
        return lightTypeWhiteLight;

    }
    

}

+(UIImage*) getBaseLightImageByTime
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIImage imageNamed:@"light-yellow-0.png"];
        
    }else
    {
        return [UIImage imageNamed:@"light-white-0.png"];
        
    }
}

+(UIImage*) getSunOrMooonImageByTime
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIImage imageNamed:@"sun.png"];
        
    }else
    {
        return [UIImage imageNamed:@"moon.png"];
        
    }
    
}

+(UIImage*) getStaticImageByLightType:(LightType) lightType
{
    switch (lightType) {
        case lightTypeWhiteLight:
            return [UIImage imageNamed:@"light-white-static.png"];
            break;
            
        case lightTypeYellowLight:
            return [UIImage imageNamed:@"light-yellow-static.png"];
            break;
            
        case lightTypeWhiteSpirite:
            return [UIImage imageNamed:@"spirit-white-static.png"];
            break;
            
        case lightTypeYellowSpirte:
            return [UIImage imageNamed:@"spirit-yellow-static.png"];
            break;
            
        default:
            break;
    }
    
    
    return [UIImage imageNamed:@"spirit-yellow-static.png"];
    
}
+(UIImage*) getAniStartImageByLightType:(LightType) lightType
{
    
    switch (lightType) {
        case lightTypeWhiteLight:
            return [UIImage imageNamed:@"light-white-0.png"];
            break;
            
        case lightTypeYellowLight:
            return [UIImage imageNamed:@"light-yellow-0.png"];
            break;
            
        case lightTypeWhiteSpirite:
            return [UIImage imageNamed:@"spirit-white-0.png"];
            break;
            
        case lightTypeYellowSpirte:
            return [UIImage imageNamed:@"spirit-yellow-0.png"];
            break;
            
        default:
            break;
    }
    
    
    return [UIImage imageNamed:@"spirit-yellow-0.png"];
    
}


+(NSString*) getImageNameByLightType:(LightType) lightType
{
    
    switch (lightType) {
        case lightTypeWhiteLight:
            return @"light-white";
            break;
            
        case lightTypeYellowLight:
            return @"light-yellow";
            break;
            
        case lightTypeWhiteSpirite:
            return @"spirit-white";
            break;
            
        case lightTypeYellowSpirte:
            return @"spirit-yellow";
            break;
            
        default:
            break;
    }
    
    
    return @"spirit-white";

}


+(UIImage*)getSkyBkImageByTime
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIImage imageNamed:MAIN_BK_IMAGE_SUN];
        
    }else
    {
        return [UIImage imageNamed:MAIN_BK_IMAGE_MOON];
        
    }
}
+(UIImage*)getSkyWindowImageByTime
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIImage imageNamed:MAIN_WINDOW_IMAGE_SUN];
        
    }else
    {
        return [UIImage imageNamed:MAIN_WINDOW_IMAGE_MOON];
        
    }
}

+(UIImage*)getSunMoonImageByTime
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIImage imageNamed:SKY_IMAGE_SUN];
        
    }else
    {
        return [UIImage imageNamed:SKY_IMAGE_MOON];
        
    }
    
}

+(UIColor*)getIndicationColorByTime
{
    
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return [UIColor yellowColor];
        
    }else
    {
        return [UIColor whiteColor];
        
    }
}


+(NSString*)getLightCharactorByTime
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return @"阳";
        
    }else
    {
        return @"月";
        
    }

}

+(NSString*)getAlertBkByTime
{
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        return @"提示框V2-黄.png";
        
    }else
    {
        return  @"提示框V2-白.png";
        
    }
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
    struct sockaddr_in_my zeroAddress;
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

//获取一个随机整数，范围在[from,to），包括from，不包括to
+ (int)getRandomNumber:(int)from to:(int)to
{
    int x = to-from + 1;
    if (x==0) {
        return (int)(from + 0);
    }else
    {
        return (int)(from + (arc4random() % x));

    }
    
    
}


+(CGPoint) getMidPointBetween:(CGPoint) p1   andPoint:(CGPoint) p2
{
    CGPoint mid;
    if (p2.x > p1.x) {
        
        mid.x = p1.x + (p2.x - p1.x);
    }else
    {
        mid.x = p2.x + (p1.x - p2.x);

    }
    
    if (p2.y > p1.y) {
        
        mid.y = p1.y + (p2.y - p1.y);
    }else
    {
        mid.y = p2.y + (p1.y - p2.y);
        
    }
    
    
    return mid;
    
}


+(UIImage*) screenShot:(UIView*) view
{
    
    CGSize size = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(view.frame.origin.x, view.frame.origin.y,view.bounds.size.width, view.bounds.size.height);
    [view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenImage;
    
}

@end
