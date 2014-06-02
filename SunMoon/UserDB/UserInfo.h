//
//  UserInfo.h
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserInfo : NSObject
{

    
}

//基本用户信息
@property (nonatomic, copy      ) NSString * uid;
@property (nonatomic, copy      ) NSString * user_id;
@property (nonatomic, copy      ) NSString * name;
@property (nonatomic, copy      ) NSString * sns_id;
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



//用户数据,存在数据库中的
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


//用户数据库
@property(nonatomic,copy) NSArray* userDataBase;


//用户提醒定时时间
@property(nonatomic,copy) NSDate * sunAlertTime;
@property(nonatomic,copy) NSDate * moonAlertTime;
@property(nonatomic) BOOL  sunAlertTimeCtl;
@property(nonatomic) BOOL  moonAlertTimeCtl;

+ (UserInfo *)sharedSingleUserInfo;


-(instancetype) initDefaultInfoAtFirstOpenwithTime:(NSString*) time;

-(instancetype) getUserInfoAtNormalOpen;

-(instancetype) registerNewUserWithName:(NSString*) name regTime:(NSString*) time snsID:(NSString*) snsID headerImage:(UIImage*)image;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithArray:(NSArray *)array;

-(UserInfo*) getUserBaseInfo;

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

@end
