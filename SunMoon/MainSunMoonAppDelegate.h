//
//  MainSunMoonAppDelegate.h
//  SunMoon
//
//  Created by songwei on 14-3-30.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoCloud.h"



@interface MainSunMoonAppDelegate : UIResponder <UIApplicationDelegate,UserInfoCloudDelegate>
{
    
    UILocalNotification *alertNotification;

    
}

@property (strong, nonatomic) UIWindow *window;

/**
 * @brief 在状态栏显示 一些Log
 *
 * @param string 需要显示的内容
 * @param duration  需要显示多长时间
 */
+ (void) showStatusWithText:(NSString *) string duration:(NSTimeInterval) duration;
@end
