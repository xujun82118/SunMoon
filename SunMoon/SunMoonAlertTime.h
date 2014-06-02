//
//  SunAlertTime.h
//  SunMoon
//
//  Created by songwei on 14-5-15.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface SunMoonAlertTime : UIViewController
{
    
    UILocalNotification *alertNotification;

}

- (IBAction)doSelect:(id)sender;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property(nonatomic,copy) NSDate * alertTime;
@property(nonatomic) NSInteger iSunORMoon; //1:太阳，2：月亮

@end
