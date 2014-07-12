//
//  WeatherLoc.h
//  SunMoon
//
//  Created by songwei on 14-6-22.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherLoc : NSObject


@property (nonatomic, copy      ) NSString * currentLocation;

@property (nonatomic, copy      ) NSString * currentCity;

@property (nonatomic, copy      ) NSString * weatherDay;
@property (nonatomic, copy      ) NSString * weatherNight;
@property (nonatomic, copy      ) NSString * temperatureDay;
@property (nonatomic, copy      ) NSString * temperatureNight;
@property (nonatomic, copy      ) NSString * windDay;
@property (nonatomic, copy      ) NSString * windNight;

-(instancetype) init;
-(void) startGetWeather;
-(void) startGetWeatherSimple;

@end
