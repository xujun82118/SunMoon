//
//  UserInfo.m
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserInfo.h"
#import "UserDB.h"

@implementation UserInfo

@synthesize current_sun_sentence,current_moon_sentence,sunDataSourceArray,moonDataSourceArray,sunSentenceSelect,moonSentenceSelect;
@synthesize isRegisterUser =  _isRegisterUser;
@synthesize sunAlertTimeCtl = _sunAlertTimeCtl;
@synthesize moonAlertTimeCtl = _moonAlertTimeCtl;
@synthesize userDataBase = _userDataBase;
@synthesize userType=_userType,useTime=_useTime;


+ (UserInfo *)sharedSingleUserInfo
{
    static UserInfo *sharedSingleUserInfo = nil;
    
    @synchronized(self)
    {
        if (!sharedSingleUserInfo)
            sharedSingleUserInfo = [[UserInfo alloc] init];
        return sharedSingleUserInfo;
    }
}


//第一次打开程序，初始化必要的信息
-(instancetype) initDefaultInfoAtFirstOpenwithTime:(NSString*) time
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:INIT_DEFAULT_USER_NAME forKey:KEY_USER_NAME];
    [userBaseData setObject:time forKey:KEY_REG_TIME];
    //[userBaseData setObject:snsID forKey:KEY_SNS_ID];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"默认头像.png"]);
    [userBaseData setObject:imageData forKey:KEY_USER_HEADER_IMAGE];
    [userBaseData setBool:NO forKey:KEY_IS_REGISTER_USER];
    [userBaseData setInteger:USER_TYPE_NEW forKey:KEY_USER_TYPE];
    [userBaseData setInteger:1 forKey:KEY_USER_TIME];
    [userBaseData synchronize];
    
    self.name = INIT_DEFAULT_USER_NAME;
    self.reg_time = time;
    //self.sns_id = snsID;
    self.userHeaderImage = [UIImage imageNamed:@"默认头像.png"];
    self.isRegisterUser = NO;
    self.userType = USER_TYPE_NEW;
    self.useTime = 1;

    //初始化选择的语录
    current_sun_sentence = NSLocalizedString(@"Sun_sentenc_1", @"");
    current_moon_sentence = NSLocalizedString(@"Moon_sentenc_1", @"");
    
    
    //初始化语录库
    if (self.sunDataSourceArray == nil)
    {
        
        sunDataSourceArray = [[NSMutableArray alloc] init];
        [sunDataSourceArray addObject:NSLocalizedString(@"Sun_sentenc_1", @"")];
        [sunDataSourceArray addObject:NSLocalizedString(@"Sun_sentenc_2", @"")];
        [sunDataSourceArray addObject:NSLocalizedString(@"Sun_sentenc_3", @"")];
        
        
        [userBaseData setObject:sunDataSourceArray forKey:SUN_DATA_STRING_KEY];
        [userBaseData synchronize];
    }
    
    if (self.moonDataSourceArray == nil)
    {
        
        moonDataSourceArray = [[NSMutableArray alloc] init];
        [moonDataSourceArray addObject:NSLocalizedString(@"Moon_sentenc_1", @"")];
        [moonDataSourceArray addObject:NSLocalizedString(@"Moon_sentenc_2", @"")];
        [moonDataSourceArray addObject:NSLocalizedString(@"Moon_sentenc_3", @"")];
        
        
        [userBaseData setObject:moonDataSourceArray forKey:MOON_DATA_STRING_KEY];
        [userBaseData synchronize];
    }
    
    //初始为第一条语录
    sunSentenceSelect = 0;
    moonSentenceSelect = 0;
    
    //初始创建数据库
    UserDB* userDB = [[UserDB alloc] init];
    [userDB createDataBase];
    
    
    //设置默认的提醒时间
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    //早上定时提醒时间
    [components setHour:7];
    [components setMinute:30];
    [components setSecond:0];
    _sunAlertTime = [calendar dateFromComponents:components];
    [userBaseData setObject:_sunAlertTime forKey:SUN_ALERT_TIME];
    [userBaseData synchronize];
    
    //晚上定时提配时间
    [components setHour:21];
    [components setMinute:30];
    [components setSecond:0];
    _moonAlertTime = [calendar dateFromComponents:components];
    [userBaseData setObject:_moonAlertTime forKey:MOON_ALERT_TIME];
    [userBaseData synchronize];
    
    
    _sunAlertTimeCtl = YES;
    _moonAlertTimeCtl = YES;
    [userBaseData setBool:_sunAlertTimeCtl forKey:SUN_ALERT_TIME_CTL];
    [userBaseData setBool:_moonAlertTimeCtl forKey:MOON_ALERT_TIME_CTL];
    [userBaseData synchronize];

    return self;
}

//非第一次打开，即一般打开时，取得用户数据
-(instancetype) getUserInfoAtNormalOpen
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    self.name = [userBaseData objectForKey:KEY_USER_NAME];
    self.reg_time = [userBaseData objectForKey:KEY_REG_TIME];
    self.sns_id = [userBaseData objectForKey:KEY_SNS_ID];
    self.userHeaderImage = [UIImage imageWithData:[userBaseData objectForKey:KEY_USER_HEADER_IMAGE]];
    self.isRegisterUser = [userBaseData boolForKey:KEY_IS_REGISTER_USER];

    //更新用户类型
    self.useTime = [userBaseData integerForKey:KEY_USER_TIME]+1;
    [userBaseData setInteger:self.useTime forKey:KEY_USER_TIME];
    
    if (self.useTime<USER_TYPE_STEADY_TIME && self.useTime>1) {
        [userBaseData setInteger:USER_TYPE_TYE forKey:KEY_USER_TYPE];
        self.userType = USER_TYPE_TYE;
        
    }else if(self.useTime>=USER_TYPE_STEADY_TIME && self.useTime%USER_TYPE_STEADY_TIME != 0)
    {
        [userBaseData setInteger:USER_TYPE_STEADY forKey:KEY_USER_TYPE];
        self.userType = USER_TYPE_STEADY;
        
    }
    else if (self.useTime%USER_TYPE_STEADY_TIME == 0)
    {
        [userBaseData setInteger:USER_TYPE_NEED_CARE forKey:KEY_USER_TYPE];
        self.userType = USER_TYPE_NEED_CARE;
        
    }

    
    
    
    //已注册则进行：提醒注册，通知服务器，云同步，等操作；
    if (self.isRegisterUser)
    {
        NSLog(@"User is registered!");
        
    }else
    {
        NSLog(@"User is not registered!");
    }
    
    [self getUserCommonData];
    
    return self;
}

-(instancetype) registerNewUserWithName:(NSString*) name regTime:(NSString*) time snsID:(NSString*) snsID headerImage:(UIImage*)image
{
  
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:name forKey:KEY_USER_NAME];
    [userBaseData setObject:time forKey:KEY_REG_TIME];
    [userBaseData setObject:snsID forKey:KEY_SNS_ID];
    //NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"默认头像.png"]);
    [userBaseData setObject:UIImagePNGRepresentation(image) forKey:KEY_USER_HEADER_IMAGE];
    [userBaseData setBool:YES forKey:KEY_IS_REGISTER_USER];
    [userBaseData synchronize];
    
    self.name = name;
    self.reg_time = time;
    self.sns_id = snsID;
    self.userHeaderImage = image;
    self.isRegisterUser = YES;
    
    [self getUserCommonData];
    
    return self;
}


//除用户身份信息外的信息
-(void)getUserCommonData
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    //取得语录
    self.sunDataSourceArray = [userBaseData objectForKey:SUN_DATA_STRING_KEY];
    self.moonDataSourceArray = [userBaseData objectForKey:MOON_DATA_STRING_KEY];
    self.sunSentenceSelect = [userBaseData integerForKey:SUN_CHOOSE_STRING_KEY];
    self.moonSentenceSelect = [userBaseData integerForKey:MOON_CHOOSE_STRING_KEY];
    self.current_sun_sentence = [sunDataSourceArray objectAtIndex:sunSentenceSelect];
    self.current_moon_sentence = [moonDataSourceArray objectAtIndex:moonSentenceSelect];
    
    
    //初始创建数据库, 已存在，则不创建
    UserDB* userDB = [[UserDB alloc] init];
    [userDB createDataBase];
    //获取用户数据库数据
    //优化：线程处理
    _userDataBase = [userDB getUserImageLimite:1000];
    
    //取得定时时间
    _sunAlertTime = [userBaseData objectForKey:SUN_ALERT_TIME];
    _moonAlertTime = [userBaseData objectForKey:MOON_ALERT_TIME];
    _sunAlertTimeCtl = [userBaseData boolForKey:SUN_ALERT_TIME_CTL];
    _moonAlertTimeCtl = [userBaseData boolForKey:MOON_ALERT_TIME_CTL];

    
}


- (instancetype)initWithAttributes:(NSDictionary *)attributes {

    self.user_id =[attributes valueForKeyPath:@"user_id"];
    self.sns_id =[attributes valueForKeyPath:@"sns_id"];
    self.name =[attributes valueForKeyPath:@"name"];
    self.sun_value =[attributes valueForKeyPath:@"sun_value"];
    self.moon_value =[attributes valueForKeyPath:@"moon_value"];

    
    return self;
}


- (instancetype)initWithArray:(NSArray *)array {

    self.user_id =[array valueForKeyPath:@"user_id"];
    self.sns_id =[array valueForKeyPath:@"sns_id"];
    self.name =[array valueForKeyPath:@"name"];
    self.sun_value =[array valueForKeyPath:@"sun_value"];
    
    return self;
}


//-(UserInfo*) getUserBaseInfo
//{
//    if (!self) {
//        
//        NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
//        self.user_id = [userBaseData objectForKey:@"user_id"];
//        self.sns_id = [userBaseData objectForKey:@"sns_id"];
//        self.name = [userBaseData objectForKey:@"name"];
//        self.sun_value = [userBaseData objectForKey:@"sun_value"];
//        self.moon_value = [userBaseData objectForKey:@"moon_value"];
//        
//        if (self.name.length == 0) {
//            return nil;
//        }
//
//
//        return self;
//    }
//    
//    return self;
//    
//}

-(void)updateSunSentenceSelected:(NSInteger) sentenceSelect
{
    NSAssert((sentenceSelect<sunDataSourceArray.count), @"ERROR:sentenceSelect should not bigger than  sunDataSourceArray.count");
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setInteger:sentenceSelect forKey:SUN_CHOOSE_STRING_KEY];
    [userBaseData synchronize];
    
    sunSentenceSelect = sentenceSelect;
    current_sun_sentence = [sunDataSourceArray objectAtIndex:sentenceSelect];
    
}


-(void)updateMoonSentenceSelected:(NSInteger) sentenceSelect
{
   NSAssert((sentenceSelect<moonDataSourceArray.count), @"ERROR:sentenceSelect should not bigger than  moonDataSourceArray.count");
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setInteger:sentenceSelect forKey:MOON_CHOOSE_STRING_KEY];
    [userBaseData synchronize];
    
    moonSentenceSelect = sentenceSelect;
    current_moon_sentence = [moonDataSourceArray objectAtIndex:sentenceSelect];

}

-(void)updateSunSentence:(NSMutableArray*) sentenceArry
{
    if (sentenceArry == nil || sentenceArry.count == 0) {
        NSLog(@"updateSunSentence = nil or 0 count");
        return;
    }
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:sentenceArry forKey:SUN_DATA_STRING_KEY];
    [userBaseData synchronize];
    
    sunDataSourceArray = sentenceArry;
    
    
}

-(void)updateMoonSentence:(NSMutableArray*) sentenceArry
{
    if (sentenceArry == nil || sentenceArry.count == 0) {
        NSLog(@"updateSunSentence = nil or 0 count");
        return;
    }
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:sentenceArry forKey:MOON_DATA_STRING_KEY];
    [userBaseData synchronize];
    
    moonDataSourceArray = sentenceArry;
    
    
}


-(void)updateSunAlertTime:(NSDate*) alertTime
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:alertTime forKey:SUN_ALERT_TIME];
    [userBaseData synchronize];
    
    _sunAlertTime = alertTime;
}

-(void)updateMoonAlertTime:(NSDate*) alertTime
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:alertTime forKey:MOON_ALERT_TIME];
    [userBaseData synchronize];
    
    _moonAlertTime = alertTime;
}

-(void)updateSunAlertTimeCtl:(BOOL) alertBool
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:alertBool  forKey:SUN_ALERT_TIME_CTL];
    [userBaseData synchronize];

    _sunAlertTimeCtl = alertBool;
    
}

-(void)updateMoonAlertTimeCtl:(BOOL) alertBool
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:alertBool  forKey:MOON_ALERT_TIME_CTL];
    [userBaseData synchronize];
    
    _moonAlertTimeCtl = alertBool;
    
}

-(void)updateUserHeaderImage:(UIImage*) image
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setObject:UIImagePNGRepresentation(image) forKey:KEY_USER_HEADER_IMAGE];
    [userBaseData synchronize];
    
    _userHeaderImage = image;
    
    
}

-(void)updateUserType:(NSInteger) iType
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setInteger:iType forKey:KEY_USER_TYPE];
    [userBaseData synchronize];
    
    _userType = iType;
    
}

@end
