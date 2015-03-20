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

@synthesize name,sns_id,current_sun_sentence,current_moon_sentence,sunDataSourceArray,moonDataSourceArray,sunSentenceSelect,moonSentenceSelect, continueLogInSunCount,continueLogInMoonCount;
@synthesize isRegisterUser =  _isRegisterUser;
@synthesize sunAlertTimeCtl = _sunAlertTimeCtl;
@synthesize moonAlertTimeCtl = _moonAlertTimeCtl;
@synthesize userDataBase = _userDataBase;
@synthesize userType=_userType,useTime=_useTime;
@synthesize cloudSynAutoCtl = _cloudSynAutoCtl;
@synthesize photoSaveAutoCtl = _photoSaveAutoCtl;
@synthesize delayTakePhotoCtl = _delayTakePhotoCtl;
@synthesize isBringUpSun = _isBringUpSun, isBringUpMoon = _isBringUpMoon;
@synthesize isHaveAddSun = _isHaveAddSun, isHaveaddMoon = _isHaveaddMoon;
@synthesize startBringupSunTime = _startBringupSunTime, startBringupMoonTime = _startBringupMoonTime;

static UserInfo *sharedUserInfo;

+ (UserInfo *)sharedSingleUserInfo
{
    
    @synchronized(self)
    {
        if (!sharedUserInfo)
        {
           sharedUserInfo = [[UserInfo alloc] init];
        }
    
        return sharedUserInfo;
    }
}


- (id) init {
    self = [super init];
    return self;
}


//第一次打开程序，初始化必要的信息
-(instancetype) initDefaultInfoAtFirstOpenwithTime:(NSString*) time
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    self.name = INIT_DEFAULT_USER_NAME;
    self.reg_time = time;
    self.sns_id = INIT_DEFAULT_SNS_ID;
    self.userHeaderImage = [UIImage imageNamed:@"默认头像.png"];
    self.isRegisterUser = NO;
    self.userType = USER_TYPE_NEW;
    self.useTime = 1;
    
    [userBaseData setObject:self.name forKey:KEY_USER_NAME];
    [userBaseData setObject:self.reg_time forKey:KEY_REG_TIME];
    [userBaseData setObject:self.sns_id forKey:KEY_SNS_ID];
    [userBaseData setObject:UIImagePNGRepresentation(self.userHeaderImage) forKey:KEY_USER_HEADER_IMAGE];
    [userBaseData setBool:self.isRegisterUser forKey:KEY_IS_REGISTER_USER];
    [userBaseData setInteger:self.userType forKey:KEY_USER_TYPE];
    [userBaseData setInteger:self.useTime forKey:KEY_USER_TIME];
    [userBaseData synchronize];
    

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
    
    //起动定时时间
    UILocalNotification *alertNotification = [[UILocalNotification alloc] init];
    if (alertNotification!=nil)
    {
        alertNotification.fireDate = _sunAlertTime;
        alertNotification.repeatInterval = kCFCalendarUnitDay;
        alertNotification.timeZone=[NSTimeZone defaultTimeZone];
        alertNotification.soundName = UILocalNotificationDefaultSoundName;
        
        NSDictionary* info = [NSDictionary dictionaryWithObject:ALERT_IS_SUN_TIME forKey:ALERT_SUN_MOON_TIME];
        alertNotification.userInfo = info;
        
        alertNotification.alertBody = NSLocalizedString(@"Sun time is on", @"");
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
        
        
        alertNotification.fireDate = _moonAlertTime;
        
        NSDictionary* info1 = [NSDictionary dictionaryWithObject:ALERT_IS_MOON_TIME forKey:ALERT_SUN_MOON_TIME];
        alertNotification.userInfo = info1;
        
        alertNotification.alertBody = NSLocalizedString(@"Moon time is on", @"");
        
        [[UIApplication sharedApplication] scheduleLocalNotification:alertNotification];
    }
    
    
    _cloudSynAutoCtl = NO;
    [userBaseData setBool:_cloudSynAutoCtl forKey:CLOUD_SYN_CTL];
    _photoSaveAutoCtl = NO;
    [userBaseData setBool:_photoSaveAutoCtl forKey:PHOTO_SAVE_CTL];
    _delayTakePhotoCtl = NO;
    [userBaseData setBool:_delayTakePhotoCtl forKey:DELAY_TAKE_PHOTO_CTL];
    
    
    _isBringUpSun =  NO;
    [userBaseData setBool:_isBringUpSun forKey:KEY_IS_BRING_UP_SUN];
    _isBringUpMoon =  NO;
    [userBaseData setBool:_isBringUpMoon forKey:KEY_IS_BRING_UP_MOON];
    
    _startBringupSunTime = 0;
    [userBaseData setObject:_startBringupSunTime forKey:KEY_START_BRING_UP_SUN_TIME];
    _startBringupMoonTime = 0;
    [userBaseData setObject:_startBringupMoonTime forKey:KEY_START_BRING_UP_MOON_TIME];
    
    [userBaseData synchronize];
    
    
    [self getUserCommonData];

    return self;
}

//非第一次打开，即一般打开时，取得用户数据
-(instancetype) getUserInfoAtNormalOpen
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    self.user_id = [userBaseData objectForKey:KEY_USER_ID];
    self.name = [userBaseData objectForKey:KEY_USER_NAME];
    self.reg_time = [userBaseData objectForKey:KEY_REG_TIME];
    self.sns_id = [userBaseData objectForKey:KEY_SNS_ID];
    self.userHeaderImage = [UIImage imageWithData:[userBaseData objectForKey:KEY_USER_HEADER_IMAGE]];
    
    if (self.userHeaderImage == Nil) {
        self.userHeaderImage = [UIImage imageNamed:@"默认头像.png"];
    }
    
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

    
    [userBaseData synchronize];
    
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
    NSLog(@"in getUserCommonData: userDB =%@", userDB);

    //获取用户数据库数据
    //优化：线程处理
    _userDataBase = [userDB getUserImageLimite:MAX_PHOTO_COUNT];
    
    //获阳用户当天数据
    //优化：渡过半夜，重新更新
    UserInfo* userInfoDB = [userDB getUserDataByDateTime:[CommonObject getCurrentDate]];
    if (!userInfoDB) {
        NSLog(@"No user data in DB at date=%@!", [CommonObject getCurrentDate]);
        
        //初始化当天的数据
        self.date_time =[CommonObject getCurrentDate];
        self.sun_value =[self getMaxUserSunValue];
        self.moon_value =[self getMaxUserMoonValue];
        self.sun_image =Nil;
        self.sun_image_name =Nil;
        self.sun_image_sentence =Nil;
        self.moon_image =Nil;
        self.moon_image_name =Nil;
        self.moon_image_sentence =Nil;
        
        [self saveUserCheckByDataTime:self];

        
    }else
    {
        //填上当天的数据
        self.date_time =userInfoDB.date_time;
        self.sun_value =userInfoDB.sun_value;
        self.moon_value =userInfoDB.moon_value;
        self.sun_image =userInfoDB.sun_image;
        self.sun_image_name =userInfoDB.sun_image_name;
        self.sun_image_sentence =userInfoDB.sun_image_sentence;
        self.moon_image =userInfoDB.moon_image;
        self.moon_image_name =userInfoDB.moon_image_name;
        self.moon_image_sentence =userInfoDB.moon_image_sentence;
        
    }
    
    //取得定时时间
    _sunAlertTime = [userBaseData objectForKey:SUN_ALERT_TIME];
    _moonAlertTime = [userBaseData objectForKey:MOON_ALERT_TIME];
    _sunAlertTimeCtl = [userBaseData boolForKey:SUN_ALERT_TIME_CTL];
    _moonAlertTimeCtl = [userBaseData boolForKey:MOON_ALERT_TIME_CTL];
    _cloudSynAutoCtl = [userBaseData boolForKey:CLOUD_SYN_CTL];
    _photoSaveAutoCtl = [userBaseData boolForKey:PHOTO_SAVE_CTL];
    
    //取得延迟拍照
    _delayTakePhotoCtl = [userBaseData boolForKey:DELAY_TAKE_PHOTO_CTL];


    //是否有光育成
    _isBringUpSun = [userBaseData boolForKey:KEY_IS_BRING_UP_SUN];
    _isBringUpMoon = [userBaseData boolForKey:KEY_IS_BRING_UP_MOON];
    
    //当天的照片是否已加过阳光
    _isHaveAddSun = [userBaseData boolForKey:KEY_IS_HAVE_ADD_SUN];
    _isHaveaddMoon = [userBaseData boolForKey:KEY_IS_HAVE_ADD_MOON];

    //上次光育成的时间
    _startBringupSunTime = [userBaseData objectForKey:KEY_START_BRING_UP_SUN_TIME];
    _startBringupMoonTime = [userBaseData objectForKey:KEY_START_BRING_UP_MOON_TIME];
    
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



/**
 * @brief 保存或更新一条用户记录
 *
 * @param user 需要保存的用户数据
 */
- (void) saveUserCheckByDataTime:(UserInfo *) user{
    
    
    //初始创建数据库, 已存在，则不创建
    UserDB* userDB = [[UserDB alloc] init];
    [userDB createDataBase];
    
    if ([userDB getUserDataByDateTime:user.date_time]) {
        NSLog(@"Datetime=%@， 重复，先删后插入一条!", user.date_time);
        //有错误，导致存入后数据乱，原因不明，暂时用先删后存的方法
        [userDB deleteUserWithDataTime:user.date_time];
        [userDB saveUser:user];
    }else
    {
        NSLog(@"Datetime=%@， 新插入一条!", user.date_time);
        [userDB saveUser:user];        
    }
    
}


-(NSInteger)getMaxuserValueByTime
{
    NSString * countString;
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        countString =  [self getMaxUserSunValue];
    }else
    {
        countString = [self getMaxUserMoonValue];
    }
    
    return countString.integerValue;
        
    
}

-(NSString*)getMaxUserSunValue
{
    
    UserDB* userDB = [[UserDB alloc] init];
    UserInfo* tempInfo = [userDB findMaxByField:@"sun_value"];
    

    
    if (tempInfo) {
        if ([tempInfo.sun_value integerValue] < [_sun_value integerValue]) {
            NSLog(@"由于读库后，又新奖励了光 ，未入库，所次当天值大于库中值，返回最大值");
            return _sun_value;
        }else
        {
            return  tempInfo.sun_value;
            
        }
    }else
    {
        return  @"0";
    }
    
}

-(NSString*)getMaxUserMoonValue
{
    UserDB* userDB = [[UserDB alloc] init];
    UserInfo* tempInfo = [userDB findMaxByField:@"moon_value"];
    
    if (tempInfo) {
        if ([tempInfo.moon_value integerValue] < [_moon_value integerValue]) {
            NSLog(@"由于读库后，又新奖励了光 ，未入库，所次当天值大于库中值，返回最大值");
            return _moon_value;
        }else
        {
            return  tempInfo.moon_value;
            
        }
    }else
    {
        return  @"0";
    }
}

- (BOOL)checkSunPhotoCountOver
{
    
    NSInteger count = [_userDataBase count];
    if (count==0) {
        return  NO;
    }
    
    NSInteger sunImageCount = 0;
    for (int i = 0; i < count; i++) {
        UserInfo* tempUserInfo = nil;
        tempUserInfo = [_userDataBase objectAtIndex:i];
        
        UIImage* tempImage = [UIImage imageWithData:tempUserInfo.sun_image];
        if (tempImage != Nil) {
            
            sunImageCount++;
            
        }
        
    }
    
    if (sunImageCount>MAX_PHOTO_COUNT) {
        return YES;
    }else
    {
        return NO;
    }
    
}

- (BOOL)checkMoonPhotoCountOver
{
    
    NSInteger count = [_userDataBase count];
    if (count==0) {
        return  NO;
    }
    
    NSInteger moonImageCount = 0;
    for (int i = 0; i < count; i++) {
        UserInfo* tempUserInfo = nil;
        tempUserInfo = [_userDataBase objectAtIndex:i];
        UIImage* tempImage = [UIImage imageWithData:tempUserInfo.moon_image];
        if (tempImage != Nil) {
            
            moonImageCount++;
            
        }
        
    }
    
    if (moonImageCount>MAX_PHOTO_COUNT) {
        return YES;
    }else
    {
        return NO;
    }
    
}


-(void)updateSns_ID:(NSString*) share_sns_id PlateType:(ShareType) plateType
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([share_sns_id isEqualToString:INIT_DEFAULT_SNS_ID]) {
        
        [userBaseData setObject:INIT_DEFAULT_SNS_ID forKey:KEY_SNS_ID];
        
        [userBaseData setBool:NO forKey:KEY_IS_REGISTER_USER];
        
        sns_id = INIT_DEFAULT_SNS_ID;
        _isRegisterUser = NO;
        
    }else
    {
        NSString* tempString = [[NSString stringWithFormat:@"%d_",plateType] stringByAppendingString:share_sns_id];
        [userBaseData setObject:tempString forKey:KEY_SNS_ID];
        
        [userBaseData setBool:YES forKey:KEY_IS_REGISTER_USER];
        
        sns_id = tempString;
        _isRegisterUser = YES;
        
    }

    
    [userBaseData synchronize];

    
}

-(void)updateuserName:(NSString*) nameString
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];

    [userBaseData setObject:nameString forKey:KEY_USER_NAME];
    [userBaseData synchronize];
    
    name = nameString;
    
}


-(void)updateSunSentenceSelected:(NSInteger) sentenceSelect
{
    if (sentenceSelect>=sunDataSourceArray.count) {
        NSLog(@"sentenceSelect should not bigger than  sunDataSourceArray.count");
        return;
    }
    
    NSAssert((sentenceSelect<sunDataSourceArray.count), @"ERROR:sentenceSelect should not bigger than  sunDataSourceArray.count");
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setInteger:sentenceSelect forKey:SUN_CHOOSE_STRING_KEY];
    [userBaseData synchronize];
    
    sunSentenceSelect = sentenceSelect;
    current_sun_sentence = [sunDataSourceArray objectAtIndex:sentenceSelect];
    
}


-(void)updateMoonSentenceSelected:(NSInteger) sentenceSelect
{
    if (sentenceSelect>=moonDataSourceArray.count) {
        NSLog(@"sentenceSelect should not bigger than  moonDataSourceArray.count");
        return;
    }
    
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


-(void)updateSunorMoonBringupTime:(NSDate*) bringupTime
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        [userBaseData setObject:bringupTime forKey:KEY_START_BRING_UP_SUN_TIME];
        _startBringupSunTime = bringupTime;
    }else
    {
        [userBaseData setObject:bringupTime forKey:KEY_START_BRING_UP_MOON_TIME];
        _startBringupMoonTime = bringupTime;
        
    }
    
    [userBaseData synchronize];
    
}


-(void)updateUserHeaderImage:(UIImage*) image
{
    
    if (!image) {
        image = [UIImage imageNamed:@"默认头像.png"];
    }
    
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

-(void)updatecloudSynAutoCtl:(BOOL) iscloudSynAutoCtl
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:iscloudSynAutoCtl  forKey:CLOUD_SYN_CTL];
    [userBaseData synchronize];
    
    
    _cloudSynAutoCtl = iscloudSynAutoCtl;
    
}

-(void)updatePhotoSaveAutoCtl:(BOOL) isphotoSaveAutoCtl
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:isphotoSaveAutoCtl  forKey:PHOTO_SAVE_CTL];
    [userBaseData synchronize];
    
    
    _photoSaveAutoCtl = isphotoSaveAutoCtl;
    
}

-(void)updateDelayTakePhotoCtl:(BOOL) isDelayTakePhotoCtl
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:isDelayTakePhotoCtl  forKey:DELAY_TAKE_PHOTO_CTL];
    [userBaseData synchronize];
    
    
    _delayTakePhotoCtl = isDelayTakePhotoCtl;
    
}

-(void)updateTodayUserData:(UserInfo*) userInfo
{
    //初始创建数据库, 已存在，则不创建
    UserDB* userDB = [[UserDB alloc] init];
    [userDB createDataBase];
    
    [userDB deleteUserWithDataTime:userInfo.date_time];
    [userDB saveUser:userInfo];
    //[userDB mergeWithUserByDateTime:userInfo];
    
}

-(void)addSunOrMoonValue:(NSInteger) value
{
    if (value == 0) {
        NSLog(@"add sun or moon value == 0 ,return");
        return;
    }
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        self.sun_value = [NSString stringWithFormat:@"%lu",[self.sun_value integerValue]+ value];
        
        NSLog(@"Sun value + %lu", value);
        
    }else if([CommonObject checkSunOrMoonTime] == IS_MOON_TIME)
    {
        self.moon_value = [NSString stringWithFormat:@"%lu",[self.moon_value integerValue]+ value];
       
        NSLog(@"Moon value + %lu", value);


    }

    [self updateTodayUserData:self];
    
}

-(void)decreaseSunOrMoonValue:(NSInteger) value
{
    if (value == 0) {
        NSLog(@"decrease sun or moon value == 0 ,return");
        return;
    }
    
    NSInteger count;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {

        self.sun_value = [NSString stringWithFormat:@"%ld",[self.sun_value integerValue]- value];
        
        //当为0时，-1为-1
        count = self.sun_value.integerValue;
        if (count<=0) {
            self.sun_value =[NSString stringWithFormat:@"%d", 0];
        }
        
    }else if([CommonObject checkSunOrMoonTime] == IS_MOON_TIME)
    {
        self.moon_value = [NSString stringWithFormat:@"%ld",[self.moon_value integerValue]- value];
        
        count = self.moon_value.integerValue;
        if (count<=0) {
            self.moon_value =[NSString stringWithFormat:@"%d", 0];
        }
        
    }
    
    [self updateTodayUserData:self];
    
}


-(void) addContinueLogInCount
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        [userBaseData setInteger:(continueLogInSunCount+1)  forKey:KEY_CONTINUE_LOGIN_SUN_COUNT];
        continueLogInSunCount++;
        
    }else
    {
        [userBaseData setInteger:(continueLogInMoonCount+1)  forKey:KEY_CONTINUE_LOGIN_MOON_COUNT];
        continueLogInMoonCount++;

    }
    
    [userBaseData synchronize];

    
}


-(void)checkAddCurrValueWithCloudSunVaule:(NSInteger)cloudSunValue MoonValue:(NSInteger)cloudMoonValue
{
    //优化
    //需改成标识第一个增值是否为注册状态的增值
    
    if (self.sun_value.integerValue > cloudSunValue) {
        self.sun_value = [NSString stringWithFormat:@"%d",[self.sun_value integerValue]+ cloudSunValue];
    }else
    {
        self.sun_value = [NSString stringWithFormat:@"%d", cloudSunValue];
    }
    
    if (self.moon_value.integerValue > cloudMoonValue) {
        self.moon_value = [NSString stringWithFormat:@"%d",[self.moon_value integerValue]+ cloudMoonValue];
    }else
    {
        self.moon_value = [NSString stringWithFormat:@"%d", cloudMoonValue];
    }
    
    [self updateTodayUserData:self];
    
}

-(void)updateContinueLogInCount:(NSInteger) value
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        [userBaseData setInteger:value  forKey:KEY_CONTINUE_LOGIN_SUN_COUNT];
        continueLogInSunCount = value;
        
    }else
    {
        [userBaseData setInteger:value  forKey:KEY_CONTINUE_LOGIN_MOON_COUNT];
        continueLogInMoonCount = value;
        
    }
  
    [userBaseData synchronize];
    
    
    
}

-(void)setLoginToday
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    NSDate* fireDate = [CommonObject returnChooseTimeUnit:[NSDate date] Year:YES Month:YES Day:YES Hour:NO Minute:NO Second:NO];
    
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        [userBaseData setObject:fireDate forKey:KEY_LOGIN_LAST_SUN_DATE];

    }else
    {
        [userBaseData setObject:fireDate forKey:KEY_LOGIN_LAST_MOON_DATE];
    }
    
    NSLog(@"setLoginToday = %@, SUNorMoon = %d", fireDate, [CommonObject checkSunOrMoonTime]);
    
    [userBaseData synchronize];
    
}

-(BOOL)checkLoginLastDateIsToday
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    NSDate* lastDate = Nil;
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        lastDate = [userBaseData objectForKey:KEY_LOGIN_LAST_SUN_DATE];
        
    }else
    {
        lastDate = [userBaseData objectForKey:KEY_LOGIN_LAST_MOON_DATE];
    }
    
    
    //只取年月日
     NSDate* fireDate = [CommonObject returnChooseTimeUnit:[NSDate date] Year:YES Month:YES Day:YES Hour:NO Minute:NO Second:NO];
    
    NSLog(@"LastlogInDay = %@, TodayLoginDay = %@", lastDate, fireDate);
    
    return [lastDate isEqualToDate:fireDate];
    
}


-(BOOL)checkLoginLastDateIsYesterday
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    NSDate* lastDate = Nil;
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        lastDate = [userBaseData objectForKey:KEY_LOGIN_LAST_SUN_DATE];
        
    }else
    {
        lastDate = [userBaseData objectForKey:KEY_LOGIN_LAST_MOON_DATE];
    }
    
    if (lastDate == nil) {
        NSLog(@"最后一次登录时间，不存在，是新用户");
        return NO;
    }
    
    //只取年月日
    NSDate* fireDate = [CommonObject returnChooseTimeUnit:[NSDate date] Year:YES Month:YES Day:YES Hour:NO Minute:NO Second:NO];


    NSTimeInterval time=[fireDate timeIntervalSinceDate:lastDate];
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    
    
    NSLog(@"LastlogInDay = %@, TodayLoginDay = %@, timeinterval is day=%d, hour = %d", lastDate, fireDate, days, hours);
    
    if(days>1)
    {
        return NO;
    }else
    {
        return YES;
        
    }
    
}


-(void) updateisBringUpSun:(BOOL) isBringup
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:isBringup  forKey:KEY_IS_BRING_UP_SUN];
    [userBaseData synchronize];
    
    _isBringUpSun = isBringup;
    
}


-(void) updateisBringUpMoon:(BOOL) isBringup
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    [userBaseData setBool:isBringup  forKey:KEY_IS_BRING_UP_MOON];
    [userBaseData synchronize];
    
    _isBringUpMoon = isBringup;
    
}


-(void) updateisBringUpSunOrMoon:(BOOL) isBringup
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        [userBaseData setBool:isBringup  forKey:KEY_IS_BRING_UP_SUN];
        _isBringUpSun = isBringup;

    }else
    {
        [userBaseData setBool:isBringup  forKey:KEY_IS_BRING_UP_MOON];
        _isBringUpMoon = isBringup;

    }
    
    [userBaseData synchronize];

    
}

-(BOOL)checkIsBringUpinSunOrMoon
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        return [userBaseData boolForKey:KEY_IS_BRING_UP_SUN];
        
    }else
    {
        return [userBaseData boolForKey:KEY_IS_BRING_UP_MOON];
    }
    
}



-(void) updateIsHaveAddSunOrMoonValueForTodayPhoto:(BOOL) isOrNo
{
    
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        [userBaseData setBool:isOrNo forKey:KEY_IS_HAVE_ADD_SUN];
        
    }else
    {
        [userBaseData setBool:isOrNo forKey:KEY_IS_HAVE_ADD_MOON];
        
    }
    
    [userBaseData synchronize];
    
}

-(BOOL) checkIsHaveAddSunValueForTodayPhoto
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    BOOL tempBool = [userBaseData boolForKey:KEY_IS_HAVE_ADD_SUN];
    return tempBool;

}

-(BOOL) checkIsHaveAddMoonValueForTodayPhoto
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    BOOL tempBool = [userBaseData boolForKey:KEY_IS_HAVE_ADD_MOON];

    return tempBool;
    
}

-(BOOL) checkIsHaveAddSunOrMoonValueForTodayPhoto
{
    NSUserDefaults* userBaseData = [NSUserDefaults standardUserDefaults];
    
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        
        BOOL tempBool = [userBaseData boolForKey:KEY_IS_HAVE_ADD_SUN];

        return tempBool;

    }else
    {
        BOOL tempBool = [userBaseData boolForKey:KEY_IS_HAVE_ADD_MOON];

        return tempBool;

    }
    
}


@end
