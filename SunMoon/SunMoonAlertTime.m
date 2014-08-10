//
//  SunAlertTime.m
//  SunMoon
//
//  Created by songwei on 14-5-15.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "SunMoonAlertTime.h"


@interface SunMoonAlertTime ()

@end

@implementation SunMoonAlertTime
@synthesize alertTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.opaque = YES;
    
    //加返回按钮
    NSInteger backBtnWidth = 18;
    NSInteger backBtnHeight = 22;
    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回-黄.png"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y-backBtnHeight/2+10, backBtnWidth, backBtnHeight)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    alertNotification=[[UILocalNotification alloc] init];
    
    //获取单例用户数据
    if (_iSunORMoon == IS_SUN_TIME) {
        alertTime = [UserInfo  sharedSingleUserInfo].sunAlertTime;
    }else if (_iSunORMoon == IS_MOON_TIME)
    {
        alertTime = [UserInfo  sharedSingleUserInfo].moonAlertTime;
        
    }

    //设置时间
    [self.datePicker setDate:alertTime animated:YES];
    [self.datePicker setDatePickerMode:UIDatePickerModeTime];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSelect:(id)sender {
    
    NSDate *selected = [self.datePicker date];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    
    //当前的时分秒获得
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:selected];
    NSInteger hour = [comps hour];
    NSInteger miniute = [comps minute];
    NSString *message = [[NSString alloc] initWithFormat:
                         @"%d:%d", hour, miniute];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setHour:hour];
    [components setMinute:miniute];
    [components setSecond:0];
    NSDate *fireDate = [calendar dateFromComponents:components];//目标时间
    
    
    //存用户选择的时间
    if (_iSunORMoon == IS_SUN_TIME) {
        [[UserInfo  sharedSingleUserInfo] updateSunAlertTime:fireDate];
        
        //设置定时每天通知
        NSArray *myArray=[[UIApplication sharedApplication] scheduledLocalNotifications];
        //NSLog(@"local notify is %d", [myArray count]);
        for (int i=0; i<[myArray count]; i++)
        {
            UILocalNotification *myUILocalNotification=[myArray objectAtIndex:i];
            
            if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_SUN_TIME])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            }
            
        }
        
        
        if (alertNotification!=nil)
        {
            
            alertNotification.fireDate = fireDate;
            alertNotification.repeatInterval = kCFCalendarUnitDay;
            alertNotification.timeZone=[NSTimeZone defaultTimeZone];
            alertNotification.soundName = @"cute.mp3";
            
            NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_SUN_TIME forKey:ALERT_SUN_MOON_TIME];
            alertNotification.userInfo = info;
            
            alertNotification.alertBody = NSLocalizedString(@"Sun time is on", @"");
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
        }
        
    }else if (_iSunORMoon == IS_MOON_TIME)
    {
        [[UserInfo  sharedSingleUserInfo] updateMoonAlertTime:fireDate];
        
        //设置定时每天通知
        NSArray *myArray=[[UIApplication sharedApplication] scheduledLocalNotifications];
        //NSLog(@"local notify is %d", [myArray count]);
        for (int i=0; i<[myArray count]; i++)
        {
            UILocalNotification *myUILocalNotification=[myArray objectAtIndex:i];
            
            if ([[[myUILocalNotification userInfo] objectForKey:ALERT_SUN_MOON_TIME] isEqualToString:ALERT_IS_MOON_TIME])
            {
                [[UIApplication sharedApplication] cancelLocalNotification:myUILocalNotification];
            }
            
        }
        
        
        if (alertNotification!=nil)
        {
            
            alertNotification.fireDate = fireDate;
            alertNotification.repeatInterval = kCFCalendarUnitDay;
            alertNotification.timeZone=[NSTimeZone defaultTimeZone];
            alertNotification.soundName = @"cute.mp3";
            
            NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_MOON_TIME forKey:ALERT_SUN_MOON_TIME];
            alertNotification.userInfo = info;
            
            alertNotification.alertBody = NSLocalizedString(@"Moon time is on", @"");
            
            [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
            
        }
        
    }
    
   
    
    // NSString *message = [[NSString alloc] initWithFormat:
    //                      @"The date and time you selected is: %@", selected];
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:@"定时时间为："
//                          message:message
//                          delegate:nil
//                          cancelButtonTitle:@"Yes"
//                          otherButtonTitles:nil];
//    [alert show];
//    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
