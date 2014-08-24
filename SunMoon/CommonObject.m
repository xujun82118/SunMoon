//
//  CommonObject.m
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "CommonObject.h"

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


@end
