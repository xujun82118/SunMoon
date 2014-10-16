//
//  UserInfo.h
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDKDef.h>


//@interface UserInfoDataBase : NSObject
//{
//    
//    
//}
//
////用户数据,存在数据库中的
//@property (nonatomic, copy      ) NSString * date_time;
//@property (nonatomic, copy      ) NSString * sun_value;
//@property (nonatomic,copy       ) NSString * moon_value;
//@property (nonatomic, copy      ) NSData   * sun_image;
//@property (nonatomic, copy      ) NSString * sun_image_name;
//@property (nonatomic, copy      ) NSString * sun_image_sentence;//此照片的语录
//@property (nonatomic,copy       ) NSData   * moon_image;
//@property (nonatomic, copy      ) NSString * moon_image_name;
//@property (nonatomic, copy      ) NSString * moon_image_sentence;//此照片的语录
//
//
//@end

@interface UserInfo : NSObject
{

    
}

//基本用户信息
@property (nonatomic, copy      ) NSString * uid;
@property (nonatomic, copy      ) NSString * user_id;
@property (nonatomic, copy      ) NSString * name;
@property (nonatomic, copy      ) NSString * sns_id; //"x_ID",x对应ShareType, ID为鉴权的用户uid
@property (nonatomic, copy      ) NSString * reg_time;
@property (nonatomic, copy      ) UIImage  * userHeaderImage;

//是否已注册
@property(nonatomic) BOOL  isRegisterUser;

//用户的使用阶段
//0:第一次使用；
//1:前期试用，前n次使用：n=USE_STAGE_STEADY_TIME；
//2:稳定用户，大于n次使用, 此时，第n*X次使用，需定时关怀用户
//3：VIP用户（待定）
@property(nonatomic) NSInteger userType;
@property(nonatomic) NSInteger useTime; //第几次使用



//用户当前登录连续登录次数
@property (nonatomic) NSInteger continueLogInSunCount;
@property (nonatomic) NSInteger continueLogInMoonCount;

//是否有光在育成
@property (nonatomic) BOOL isBringUpSun;
@property (nonatomic) BOOL isBringUpMoon;


//当天的照片是否已加过光值
@property (nonatomic) BOOL isHaveAddSun;
@property (nonatomic) BOOL isHaveaddMoon;

//开始养育光的时间
@property (nonatomic) NSDate* startBringupSunTime;
@property (nonatomic) NSDate* startBringupMoonTime;



//云同步等级
//0:不支持同步
//1：手动同步
//2: 自动同步
@property(nonatomic) NSInteger cloudSynchronizeClass;
//云同步内容等级
//0：同步阳光月光值
//1:同步照片与阳光月光值
@property(nonatomic) NSInteger cloudSynchronizeContent;


//开启自动云同步
@property(nonatomic) BOOL  cloudSynAutoCtl;

//开启相片相动本地存储
@property(nonatomic) BOOL  photoSaveAutoCtl;

//开启延迟拍照
@property(nonatomic) BOOL  delayTakePhotoCtl;




//用户数据,存在数据库中的, 存当前天数据
@property (nonatomic, copy      ) NSString * date_time;
@property (nonatomic, copy      ) NSString * sun_value;
@property (nonatomic,copy       ) NSString * moon_value;
@property (nonatomic, copy      ) NSData   * sun_image;
@property (nonatomic, copy      ) NSString * sun_image_name;
@property (nonatomic, copy      ) NSString * sun_image_sentence;//此照片的语录
@property (nonatomic,copy       ) NSData   * moon_image;
@property (nonatomic, copy      ) NSString * moon_image_name;
@property (nonatomic, copy      ) NSString * moon_image_sentence;//此照片的语录


//当前选择的默认语录
@property (nonatomic, copy      ) NSString * current_sun_sentence;
@property (nonatomic, copy      ) NSString * current_moon_sentence;

//语录库
@property (nonatomic, retain) NSMutableArray *sunDataSourceArray;
@property (nonatomic, retain) NSMutableArray *moonDataSourceArray;

//语录库的选择,列表时使用
@property (nonatomic) NSInteger sunSentenceSelect;
@property (nonatomic) NSInteger moonSentenceSelect;


//用户数据库取得的数据,多天的
@property(nonatomic,copy) NSArray* userDataBase;


//用户提醒定时时间
@property(nonatomic,copy) NSDate * sunAlertTime;
@property(nonatomic,copy) NSDate * moonAlertTime;
@property(nonatomic) BOOL  sunAlertTimeCtl;
@property(nonatomic) BOOL  moonAlertTimeCtl;






+ (UserInfo *)sharedSingleUserInfo;


-(instancetype) initDefaultInfoAtFirstOpenwithTime:(NSString*) time;

-(instancetype) getUserInfoAtNormalOpen;
-(void)getUserCommonData;

-(instancetype) registerNewUserWithName:(NSString*) name regTime:(NSString*) time snsID:(NSString*) snsID headerImage:(UIImage*)image;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithArray:(NSArray *)array;


/**
 * @brief 保存或更新一条用户记录
 *
 * @param user 需要保存的用户数据
 */
- (void) saveUserCheckByDataTime:(UserInfo *) user;


-(NSString*)getMaxUserSunValue;
-(NSString*)getMaxUserMoonValue;


-(BOOL)checkLoginLastDateIsToday;
-(void)setLoginToday;
-(void) addContinueLogInCount;
-(BOOL)checkLoginLastDateIsYesterday;


-(void)updateSns_ID:(NSString*) share_sns_id PlateType:(ShareType) plateType;
-(void)updateuserName:(NSString*) nameString;

-(void)updateSunSentenceSelected:(NSInteger) sentenceSelect;
-(void)updateMoonSentenceSelected:(NSInteger) sentenceSelect;


-(void)updateSunSentence:(NSMutableArray*) sentenceArry;
-(void)updateMoonSentence:(NSMutableArray*) sentenceArry;


-(void)updateSunAlertTime:(NSDate*) alertTime;
-(void)updateMoonAlertTime:(NSDate*) alertTime;


-(void)updateSunAlertTimeCtl:(BOOL) alertBool;
-(void)updateMoonAlertTimeCtl:(BOOL) alertBool;

-(void)updateUserHeaderImage:(UIImage*) image;

-(void)updateUserType:(NSInteger) iType;

-(void)updateTodayUserData:(UserInfo*) userInfo;

-(void)updatecloudSynAutoCtl:(BOOL) iscloudSynAutoCtl;

-(void)updatePhotoSaveAutoCtl:(BOOL) isphotoSaveAutoCtl;

-(void)updateDelayTakePhotoCtl:(BOOL) isDelayTakePhotoCtl;

-(void)addSunOrMoonValue:(NSInteger) value;
-(void)decreaseSunOrMoonValue:(NSInteger) value;

-(void)updateContinueLogInCount:(NSInteger) value;

-(void) updateisBringUpSun:(BOOL) isBringup;
-(void) updateisBringUpMoon:(BOOL) isBringup;
-(void) updateisBringUpSunOrMoon:(BOOL) isBringup;

-(BOOL)checkIsBringUpinSunOrMoon;


-(void) updateIsHaveAddSunValueForTodayPhoto:(BOOL) isOrNo;
-(void) updateIsHaveAddMoonValueForTodayPhoto:(BOOL) isOrNo;

-(BOOL) checkIsHaveAddSunValueForTodayPhoto;
-(BOOL) checkIsHaveAddMoonValueForTodayPhoto;

-(void)updateSunorMoonBringupTime:(NSDate*) bringupTime;

- (BOOL)checkSunPhotoCountOver;
- (BOOL)checkMoonPhotoCountOver;

@end
