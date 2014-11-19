//
//  WeatherLoc.m
//  SunMoon
//
//  Created by songwei on 14-6-22.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "WeatherLoc.h"
#import "CommonObject.h"

@implementation WeatherLoc
@synthesize currentLocation = _currentLocation, currentCity = _currentCity, weatherDay=_weatherDay,weatherNight=_weatherNight, temperatureDay = _temperatureDay, temperatureNight = _temperatureNight, windDay = _windDay, windNight = _windNight;

-(instancetype) init
{
    
    if (!self) {
        return nil;
    }
    
    return self;

}


-(void) startWeatherMission
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        //获取当前城市位置ID
        //解析网址通过ip 获取城市天气代码
        NSURL *url = [NSURL URLWithString:@"http://61.4.185.48:81/g/"];
        
        //    定义一个NSError对象，用于捕获错误信息
        NSError *error;
        NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        NSLog(@"Request city info return Json:%@",jsonString);
        
        if (jsonString != Nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 得到城市代码字符串，截取出城市代码
                NSString *Str;
                for (int i = 0; i<=[jsonString length]; i++)
                {
                    for (int j = i+1; j <=[jsonString length]; j++)
                    {
                        Str = [jsonString substringWithRange:NSMakeRange(i, j-i)];
                        if ([Str isEqualToString:@"id"]) {
                            if (![[jsonString substringWithRange:NSMakeRange(i+3, 1)] isEqualToString:@"c"]) {
                                _currentLocation = [jsonString substringWithRange:NSMakeRange(i+3, 9)];
                                NSLog(@"***%@***",_currentLocation);
                            }
                        }
                    }
                }
                
                
                [self startGetWeather];
                
                
            });
            
            
        }
        
    });
    
    
}

-(void) startGetWeather
{
    
    //中国天气网解析地址；
    NSString *path=@"http://m.weather.com.cn/data/cityNumber.html";
    //将城市代码替换到天气解析网址cityNumber 部分！
    if (!_currentLocation) {
        _currentLocation = @"101010100";
    }
    path=[path stringByReplacingOccurrencesOfString:@"cityNumber" withString:_currentLocation];
    
    NSLog(@"Get weather path is :%@",path);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
        [manager GET:@"http://m.weather.com.cn/data/101010100.html?format=json" parameters:nil  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *weatherDic =(NSDictionary *)responseObject;
            
            NSDictionary *weatherInfo = [weatherDic objectForKey:@"weatherinfo"];
            NSString* temp = [NSString stringWithFormat:@"今天是 %@  %@  %@  的天气状况是：%@  %@ ",[weatherInfo objectForKey:@"date_y"],[weatherInfo objectForKey:@"week"],[weatherInfo objectForKey:@"city"], [weatherInfo objectForKey:@"weather1"], [weatherInfo objectForKey:@"temp1"]];
            NSLog(@"weatherInfo字典里面的内容为--》%@", weatherDic );
            
            
            if (responseObject != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Get weatherinfo  answer=%@", temp);
                    
                    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
                        
                        _weatherDay = [weatherInfo objectForKey:@"weather1"];
                        _temperatureDay = [weatherInfo objectForKey:@"temp1"];
                       // _windDay = ;
                        
                        
                    }else
                    {
                        _weatherNight = [weatherInfo objectForKey:@"weather1"];
                        _temperatureNight = [weatherInfo objectForKey:@"temp1"];
                        //_windNight = ;
                        
                    }

                });
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
        }];
  
    });

}


-(void) startGetWeatherSimple
{
    
    //中国天气网解析地址；
    NSString *path=@"http://www.weather.com.cn/data/cityinfo/cityNumber.html";
    //将城市代码替换到天气解析网址cityNumber 部分！
    if (!_currentLocation) {
        _currentLocation = @"101010100";
    }
    path=[path stringByReplacingOccurrencesOfString:@"cityNumber" withString:_currentLocation];
    
    
    NSURL *URL =[NSURL URLWithString:path];
    NSError *error;
    NSString *stringFromFileAtURL = [[NSString alloc]
                                     initWithContentsOfURL:URL
                                     encoding:NSUTF8StringEncoding
                                     error:&error];
    NSString *strTempL;
    NSString *strTempH;
    NSString *strWeather;
    NSString *fileName=@"晴.png";
    if(stringFromFileAtURL !=nil)
    {
        
        NSLog(@"%@",stringFromFileAtURL);
        NSArray *strarray = [stringFromFileAtURL componentsSeparatedByString:@"\""];
        for(int i=0;i<strarray.count;i++)
        {
            NSLog(@"%@",[strarray objectAtIndex:i]);
            NSString *str = [strarray objectAtIndex:i];
            if(YES == [str isEqualToString:@"temp1"])//最高温度
            {
                strTempH = [strarray objectAtIndex:i+2];
            }
            else if(YES == [str isEqualToString:@"temp2"])//最低温度
            {
                strTempL = [strarray objectAtIndex:i+2];
            }
            else if(YES == [str isEqualToString:@"weather"])//天气
            {
                strWeather = [strarray objectAtIndex:i+2];
            }
            
        }
        
        
        NSString *sweather = [[NSString alloc]initWithFormat:@"景区天气:%@\n%@~%@",strWeather,strTempL,strTempH];
        
        
        if(NSNotFound != [strWeather rangeOfString:@"晴"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@",@"晴.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"多云"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"多云.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"阴"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"阴.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雨"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"中雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雪"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"小雪.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雷"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"雷雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雾"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"雾.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"大雪"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"大雪.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"大雨"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"大雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"中雪"].location)
        {
            fileName = [[NSString alloc]initWithFormat:@"%@",@"中雪.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"中雨"].location)
        {
            fileName = [[NSString alloc]initWithFormat:@"%@",@"中雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"小雪"].location)
        {
            fileName = [[NSString alloc]initWithFormat:@"%@",@"小雪.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"小雨"].location)
        {
            fileName = [[NSString alloc]initWithFormat:@"%@",@"中雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雨加雪"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"雨夹雪.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"阵雨"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"中雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"雷阵雨"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"雷阵雨.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"大雨转晴"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"大雨转晴.png"];
        }
        if(NSNotFound != [strWeather rangeOfString:@"阴转晴"].location)
        {
            fileName =[[NSString alloc]initWithFormat:@"%@", @"阴转晴.png"];
        }
        
        //if(sweather !=nil)
            //self.weathText.text = sweather;
    }
    //NSLog(fileName);
    //self.weathImage.image = [UIImage imageNamed:fileName];

    
}


@end
