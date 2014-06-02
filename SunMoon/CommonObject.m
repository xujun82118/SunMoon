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

+ (NSString *)getCurrentDate
{
    NSDate *_date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateTime = [[format stringFromDate:_date] substringToIndex:8];
    return dateTime;
}

//判断是阳光还是月光,1:太阳，2：月亮
+ (NSInteger) checkSunOrMoonTime
{
    NSDate *_date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDateComponents* comps;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:_date];
    NSInteger hour = [comps hour];
    
    if (hour<=SUN_TIME_MAX && hour>=SUN_TIME_MIN) {
        return IS_SUN_TIME;
    }else if (hour<=MOON_TIME_MAX && hour>=MOON_TIME_MIN)
    {
        return IS_MOON_TIME;
    }
    
    return  0;
}

@end
