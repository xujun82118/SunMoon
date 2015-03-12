//
//  CommonObject.h
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "UserDB.h"
#import "MONActivityIndicatorView.h"



//常用
//[NSString stringWithFormat:(@"%@光养育了%d小时, 每3个小时奖励1个%@光"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月", totalHours,([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"];



#if __IPHONE_6_0 // iOS6 and later

#   define kTextAlignmentCenter    NSTextAlignmentCenter
#   define kTextAlignmentLeft      NSTextAlignmentLeft
#   define kTextAlignmentRight     NSTextAlignmentRight

#   define kTextLineBreakByWordWrapping      NSLineBreakByWordWrapping
#   define kTextLineBreakByCharWrapping      NSLineBreakByCharWrapping
#   define kTextLineBreakByClipping          NSLineBreakByClipping
#   define kTextLineBreakByTruncatingHead    NSLineBreakByTruncatingHead
#   define kTextLineBreakByTruncatingTail    NSLineBreakByTruncatingTail
#   define kTextLineBreakByTruncatingMiddle  NSLineBreakByTruncatingMiddle

#else // older versions

#   define kTextAlignmentCenter    UITextAlignmentCenter
#   define kTextAlignmentLeft      UITextAlignmentLeft
#   define kTextAlignmentRight     UITextAlignmentRight

#   define kTextLineBreakByWordWrapping       UILineBreakModeWordWrap
#   define kTextLineBreakByCharWrapping       UILineBreakModeCharacterWrap
#   define kTextLineBreakByClipping           UILineBreakModeClip
#   define kTextLineBreakByTruncatingHead     UILineBreakModeHeadTruncation
#   define kTextLineBreakByTruncatingTail     UILineBreakModeTailTruncation
#   define kTextLineBreakByTruncatingMiddle   UILineBreakModeMiddleTruncation

#endif


//默认用户名
#define INIT_DEFAULT_USER_NAME @"MyDefaultNameWithoutRegister"
#define INIT_DEFAULT_SNS_ID    @"MyDefaultSnsID"

//用户类型
#define USER_TYPE_STEADY_TIME  10 //用户稳定期次数
#define USER_TYPE_NEW 255 //新用户,第一次使用
#define USER_TYPE_TYE 1 //试用期用户, 前n次使用
#define USER_TYPE_STEADY 2 //稳定用户
#define USER_TYPE_NEED_CARE 3 //第n*x次使用，需要某些用户关怀
#define USER_TYPE_VIP 10 //VIP用户


//几个小时养成1个光
#define BRING_UP_LIGHT_HOUR  1 

//本地通知定义
#define NOTIFY_LOCAL_NEED_CHANGE_UI   @"NeedChangeUI"




//报了个奇怪的错误,先自定义规避
//Definition of 'struct in_addr' must be imported from module 'Darwin.POSIX.netinet.in' before it is required
struct in_addr_my {
    in_addr_t s_addr;
};

struct sockaddr_in_my {
    __uint8_t	sin_len;
    sa_family_t	sin_family;
    in_port_t	sin_port;
    struct	in_addr_my sin_addr;
    char		sin_zero[8];
};

//云同步等级
//0:不支持同步
//1：手动同步
//2: 自动同步
typedef enum
{
    cloudSynClassNotSupport = 0,
    cloudSynClassHand  = 1,
    cloudSynClassAuto = 2
    
}cloudSynchronizeClass;

/**
光的类型
 */
typedef enum
{
    lightTypeWhiteLight = 0,
    lightTypeYellowLight,
    lightTypeWhiteSpirite,
    lightTypeYellowSpirte,
    
}LightType;

/**
 引导所用图片的类型
 */
typedef enum
{
    guidImageTouch,
    guidImageMove,
    
}GuidImageType;

//云同步同容等级
//0：同步阳光月光值
//1: 同步值与语录
//2:同步值与语录与照片
typedef enum
{
    cloudSynContentValue = 0,
    cloudSynContentValueAndSentence = 1,
    cloudSynContentValueAndSentenceAndImage = 2

}CloudSynchronizeContent;


typedef enum
{
    netPhone = 0,
    netWifi = 1,
    netNon = 2
    
}NetConnectType;

typedef enum
{
    iphone4_4s = 0,
    iphone5_5s = 1,
    iphone6 = 2,
    iphone6Pluse = 3,
    iphoneOther = 4
    
}DeviceTypeVersion;

//阳光，月光时间
#define SUN_TIME_MIN  3
#define SUN_TIME_MAX  18
//#define MOON_TIME_MIN  18
//#define MOON_TIME_MAX  6  //次日


//阳光，月光标识
#define IS_SUN_TIME 1
#define IS_MOON_TIME 2

//指示器
#define CUSTOM_ALERT_WIDTH  SCREEN_WIDTH/5*4
#define CUSTOM_ALERT_HEIGHT  CUSTOM_ALERT_WIDTH*216/547

//无穷大的数
#define BIGGEST_NUMBER 1

//用户基础信息
#define KEY_USER_ID @"userID"
#define KEY_USER_NAME @"userName"
#define KEY_REG_TIME @"regTime"
#define KEY_SNS_ID @"snsID"
#define KEY_USER_HEADER_IMAGE @"userHeaderImage"
#define KEY_IS_REGISTER_USER @"isRegisterUser"
#define KEY_USER_TYPE @"userType" //用户类型
#define KEY_USER_TIME @"userTime" //用户使用次数



//用户最近登录的时间
#define KEY_LOGIN_LAST_SUN_DATE   @"userLoginLastSunDate"
#define KEY_LOGIN_LAST_MOON_DATE   @"userLoginLastMoonDate"

//通知用户在育成光的时间
#define KEY_NOTIFY_NEED_BRINGING_LAST_TIME @"notifyNeedBringLastTime"
#define KEY_NOTIFY_IS_BRINGING_LAST_TIME @"notifyIsBringLastTime"
#define REMINDER_INTERVEL_TIME 2 //提醒时间间隔

//光类型的计数
#define KEY_LIGHT_TYPE_SUM_COUNT  @"LightType_SumLight_Count"
#define KEY_LIGHT_TYPE_LEFT_BASE_COUNT  @"LightType_LeftBase_Count"
#define KEY_LIGHT_TYPE_SPIRITE_COUNT  @"LightType_SPIRITE_Count"

//动画view的信息
#define KEY_ANIMATION_VIEW  @"Animation_view"
#define KEY_ANIMATION_LIGHT_TYPE  @"Animation_Light_type"


//主页背图
#define  MAIN_BK_IMAGE_SUN    @"sky_bk_sun_0.png"
#define  MAIN_BK_IMAGE_MOON    @"sky_bk_moon_0.png"
#define  MAIN_WINDOW_IMAGE_SUN    @"sky_window_sun_0.png"
#define  MAIN_WINDOW_IMAGE_MOON    @"sky_window_moon_0.png"

//太阳月亮图
#define  SKY_IMAGE_SUN    @"sun.png"
#define  SKY_IMAGE_MOON    @"moon.png"

//用户连续登录次数
#define KEY_CONTINUE_LOGIN_SUN_COUNT @"continueLoginSunCount"
#define KEY_CONTINUE_LOGIN_MOON_COUNT @"continueLoginMoonCount"


//是否有光在育成
#define KEY_IS_BRING_UP_SUN @"isBringUpSun"
#define KEY_IS_BRING_UP_MOON @"isBringUpMoon"

//退出后台的时间
#define KEY_BACK_GROUND_TIME @"backGroundTime"
#define KEY_BACK_GROUND_TIME_SUNMOON @"backGroundTimeSunMoon"


//当天照片是否加过光值
#define KEY_IS_HAVE_ADD_SUN @"isHaveAddSun"
#define KEY_IS_HAVE_ADD_MOON @"isHaveAddMoon"

//奖励光的音量
#define GIVE_ONE_LIGHT_VOICE_VALUE  200

//开始养育光的时间
#define KEY_START_BRING_UP_SUN_TIME @"startBringupSunTime"
#define KEY_START_BRING_UP_MOON_TIME @"startBringupMoonTime"

//用户选择的语录
#define SUN_CHOOSE_STRING_KEY  @"SUNChooseString"
#define MOON_CHOOSE_STRING_KEY  @"MOONChooseString"
//语录库
#define SUN_DATA_STRING_KEY  @"SUNDataString"
#define MOON_DATA_STRING_KEY  @"MOONDataString"


#define SUN_ALERT_TIME @"SunAlertTime"
#define MOON_ALERT_TIME @"MoonAlertTime"
#define SUN_ALERT_TIME_CTL @"SunAlertTimeCtl"
#define MOON_ALERT_TIME_CTL @"MoonAlertTimeCtl"
#define CLOUD_SYN_CTL @"CouldSynCtl"
#define PHOTO_SAVE_CTL @"PhotoSaveAutoCtl"
#define DELAY_TAKE_PHOTO_CTL @"DelayTakePhotoCtl"

//相机传递的数据
#define CAMERA_IMAGE_KEY @"camera_image"
#define CAMERA_TIME_KEY @"camera_time"
#define CAMERA_SENTENCE_KEY @"camera_sentence"
#define CAMERA_VOICE_NAEM_KEY @"camera_voice_name"
#define CAMERA_LIGHT_COUNT @"camera_light_count"


//屏长宽
#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//定时通知KEY
#define ALERT_SUN_MOON_TIME   @"AlertSunOrMoonTime"
#define ALERT_IS_SUN_TIME     @"AlertIsSunTime"
#define ALERT_IS_MOON_TIME     @"AlertIsMoonTime"

//动画光环扩出动画实体的宽度
#define LIGHT_ANIMATION_INTERVAL  1



//控件定义
#define TOOL_BAR_HEIGHT  60
#define NAVI_BAR_HEIGHT 60
#define NAVI_BAR_BTN_Y  NAVI_BAR_HEIGHT/2 //距离导航条边,还需减去控件的高的一半
#define TOOL_BAR_BTN_Y SCREEN_HEIGHT-TOOL_BAR_HEIGHT+5 //距离工具条上边缘

#define LEFT_NAVI_BTN_TO_SIDE_X 15
#define RIGHT_NAVI_BTN_TO_SIDE_X SCREEN_WIDTH-15 //还需减去控件的宽

#define TitleFont 18
#define TitleColor [UIColor whiteColor]


//tag 定义
#define  TAG_HOME_MAIN_VIEW 90
#define  TAG_CAMERA_DECLEAR_LABEL 91
#define  TAG_EDITE_IMAGE_VIEW  92
#define  TAG_CAMERA_OLD_IMAGE_VIEW 93
#define  TAG_EDIT_OLD_IMAGE_VIEW  94
#define  TAG_TIME_SCROLL_SUN 100
#define  TAG_TIME_SCROLL_MOON 101
#define  TAG_IMAGE_SCROLL_SUN 102
#define  TAG_IMAGE_SCROLL_MOON 103
#define  TAG_IMAGE_HIGH_LIGHT_SUN 104
#define  TAG_AUTO_CLOUD_SWITCH 105
#define  TAB_VOICE_VALUE   106
#define  TAG_PLCAMERA   107

#define  TAG_EDITE_PHOTO_SCROLL_VIEW 109
#define  TAG_EDITE_PHOTO_SCROLL_LABEL 200 //200到215
#define  TAG_CUSTOM_ALER_BTN  250   //自定义aler的BTN
#define  TAG_BRING_LING_BTN   251
#define  TAG_INTO_CAMERA_BTN   252
#define  TAG_SHARE_SKY_BTN   253


#define  TAG_LIGHT_USER_HEADER 300 //300到307
#define  TAG_LIGHT_TRACE 1000 //1000以后
#define  TAG_SWIM_LIGHT_TRACE 10000 //10000以后

#define KEY_IS_GIVE_FIRST_LIGHT       @"reminderGiveFirstLight"

//aler提示KEY
#define KEY_REMINDER_PAN_FOR_LIGHT    @"reminderPanForLight"
#define KEY_REMINDER_GETINTO_CAMERA    @"reminderGetIntoCamera"
#define KEY_REMINDER_PHOTO_COUNT_OVER  @"reminderPhotoCountOver"
//#define KEY_REMINDER_SUCC_GET_LIGHT    @"reminderSuccGetLight"
//#define KEY_REMINDER_GIVE_LIGHT        @"reminderGiveLight"
#define KEY_REMINDER_GIVE_LIGHT_FROM_INTOHOME        @"reminderGiveLight_from_intoHome"  //点击头像，触发光的奖励
#define KEY_REMINDER_GIVE_LIGHT_FROM_CAMERA        @"reminderGiveLight_from_Camera"//从相机拍照回来，触发光的奖励
#define KEY_REMINDER_GIVE_LIGHT_FROM_PAN_TO_USERHEADER        @"reminderGiveLight_from_Pan_to_userheader"//拖动回头像，触发光的奖励(未用到，走的其它召回流程)
#define KEY_REMINDER_GIVE_LIGHT_FROM_CONTINUE_LOGIN        @"reminderGiveLight_from_Continue_login"//连续登录，触发光的奖励
#define KEY_REMINDER_GIVE_LIGHT_BUT_TIME_ERROR        @"reminderGiveLight_but_error_time"//时间倒序，什么也不做
#define KEY_REMINDER_HOW_TO_GET_SPIRITE        @"reminderHowToGiveSpirite"//提示如何召唤精灵





//光与精灵动画key,流程入口为refreshLightStateForCallBackOrPopout
//流程1：刷新天空
//      <1>未养成状态，光都在头像，新的天空，从KEY_ANIMATION_FLY_SIMPLE_LIGHT_TO_SKY_FOR_NEWSKY开始，然后，先放出精灵，再放出光
//      <2>养成状态，光在天空，有新奖励的光，从KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD开始，先增加光到天空，再计算是否要增加精灵，如要，先收回光，再放出新的精灵，再检查是否要放出多余的光
//流程2：收回光
//      <1>从KEY_ANIMATION_SWIM_LIGHT_BACK_FORFIANLBACK，KEY_ANIMATION_SWIM_SPIRITE_BACK开始，光和精灵同时回到日月，然后所有的光回到头像
#define KEY_ANIMATION_PAN_TO_SKY_FAILED_TO_USERHEADER @"animation_pan_to_sky_failed_to_userHeader"//拖回日月失败，光又回到了头像
#define KEY_ANIMATION_PAN_TO_USERHEADER_FAILED_TO_SKY @"animation_pan_to_userheader_failed_to_sky"//拖回头像失败，光又回到了日月

#define KEY_ANIMATION_FLY_TO_USER_HEADER_FOR_GIVE_LIGHT @"animation_fly_to_user_header"//奖励光，由于光都在头像中，所以飞到头像
//飞出光的KEY
#define KEY_ANIMATION_FLY_SIMPLE_LIGHT_TO_SKY_FOR_NEWSKY @"animation_fly_to_sky_for_newsky"//新的天空，光飞回到日月，然后执行飞出动画
#define KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_NEWSKY @"animation_swim_spirite_bazier_out_for_newSky" //新的天空，先放出精灵
#define KEY_ANIMATION_SWIM_LIGHT_OUT_FOR_NEWSKY @"animation_swim_light_bazier_out_for_newSky"//新的天空，直接弹出光
#define KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_REFRESH_ADD  @"animation_swim_spirite_bazier_out_for_refresh"//由于光满了，需要刷新增加天空精灵
#define KEY_ANIMATION_SWIM_LIGHT_OUT_REFRESH_ADD  @"animation_bazier_give_one_light_add"//刷新天空，增加奖励的光,光从日月飞出
#define KEY_ANIMATION_SWIM_LIGHT_OUT_FINAL_ADD  @"animation_bazier_give_one_light_final_add" //刷新天空，最后再确认是否有光弹出，光从日月飞出

#define KEY_ANIMATION_SWIM_AROUND   @"animation_swim_around"
//飞回光的KEY
#define KEY_ANIMATION_SWIM_LIGHT_BACK_FORREFRESH   @"animation_swim_light_back_forRefresh"//刷新时，光满了，需回到日月
#define KEY_ANIMATION_SWIM_LIGHT_BACK_FORFIANLBACK   @"animation_swim_light_back_forFinalBack"//手动召回时，光回到日月,然后一起回到头像
#define KEY_ANIMATION_SWIM_SPIRITE_BACK   @"animation_swim_spirite_back"
#define KEY_ANIMATION_FIANL_BACK_LIGHT  @"animation_bazier_final_back_light"//最后所有的光，从日月回到头像，手动召回时

//精灵touch飞行动画
#define KEY_ANIMATION_SPIRITE_FLY_TRACE_TOUCH  @"animation_spirte_fly_trace_touch"
#define KEY_ANIMATION_SPIRITE_FLY_AUTO  @"animation_spirte_fly_AUTO"


//引导动画KEY
#define KEY_ANIMATION_GUID_PAN_LIGHT_TO_SKY  @"animation_guid_pan_to_sky"
#define KEY_ANIMATION_GUID_TOUCH_CAMEREA  @"animation_guid_touch_camera"


#define FULL_SKY_LIGHT_COUNT  25
#define EVERY_LING_LIGHT_COUNT 5

#define kMaxRadius 160

#define SPIRITE_W_H 120
#define LIGHT_W_H 30



//控制在秒内全部释放完成，2秒内完成
#define POP_OUT_ALL_LIGHT_TO_SKY_TIME  2 //从日月飞出光到天空，弹出的整个时间
#define POP_OUT_ALL_SPIRITE_TO_SKY_TIME  2 //从日月飞出精灵到天空，弹出的整个时间
#define POP_OUT_ONE_ANIMATION_TIME  1 //从日月飞出光或精灵到天空, 每个光的动画滞空时间

//左右摆动的时间
#define SWIM_AROUND_LIGHT_TIME  1
//延迟一定时间才能召回，要等动画完成定位后,包括释放动画，摇摆动画(距离较小，不计)
#define POP_BACK_SKY_LIGHT_TIME  1.0 //召回天空中的光回到日月的弹出时间
#define POP_BACK_SPIRITE_TIME  0.5 //召回精灵回到日月的弹出时间
#define FLY_BACK_TO_USERHEAER_TOTAL_TIME 2 //从太阳到头像的总弹出空时间
#define SIMPLE_FLY_EVERY_LIGHT_TIME 0.5 //每一个光的飞行时间,在太阳与头像之间的，或奖励光的
#define FLY_FROM_USERHEADRE_TO_SUN_MOON_TIME 2 //从头像到日月的时间
#define POP_BACK_ONE_ANIMATION_TIME  1.0 //从天空飞回光和精灵到日月，每个光的动画滞空时长

//点击屏幕，精灵飞动时间
#define SPIRITE_FLY_FLY_INTER_TIME  0.5  //每个精灵开始飞行的时间间隔
#define SPIRITE_FLY_TIME_AUTO 1 //每段飞行的滞空时间
#define SPIRITE_FLY_TIME_TOUCH 3 //每段飞行的滞空时间
#define SPIRITE_FLY_AUTO_INTERVAL 8.0 //触发精灵自动飞行的间隔

//左右摆动的距离
#define SWIM_AROUND_SPIRITE_DISTANCE  3
#define SWIM_AROUND_LIGHT_DISTANCE  3

//日月与头像之间飞动的最大的光数
#define FLY_BETWEEN_SKY_USERHEADER_MAX_COUNT   100

#define ORIGINAL_MAX_WIDTH 320.0f


#define DEFAULT_CHOOSE_STRING_KEY  @"DefaultChooseString"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

#define MAX_PHOTO_COUNT  100  //最大照片数

#define BUNDLE_NAME @"Resource"

@interface CommonObject : NSObject

+ (NSString *)getCurrentTime;

+ (NSString *)getCurrentDate;


+(NSDate*) returnChooseTimeUnit:(NSDate*) dateTime Year:(BOOL) needYear Month:(BOOL) needMonth Day:(BOOL) needDay Hour:(BOOL) needHour Minute:(BOOL) needMinute Second:(BOOL) needSecond;

+ (NSInteger) checkSunOrMoonTime;

+(NSString*) getUsedSunMoonImageNameByTime;
+(UIImage*) getAniStartImageByLightType:(LightType) lightType;
+(UIImage*) getStaticImageByLightType:(LightType) lightType;
+(UIImage*) getUsedCameraImageNameByTime:(BOOL)isIndi;
+(NSString*) getImageNameByLightType:(LightType) lightType;
+(LightType) getBaseLightTypeByTime;
+(UIImage*) getBaseLightImageByTime;
+(LightType) getSpiriteTypeByTime;
+(UIImage*) getSunOrMooonImageByTime;
+(NSString*) getImageNameByAniArrayImageType:(NSInteger) aniType;

+(UIImage*)getSkyBkImageByTime;
+(UIImage*)getSunMoonImageByTime;
+(UIImage*)getSkyWindowImageByTime;

+(UIColor*)getIndicationColorByTime;

+(NSString*)getLightCharactorByTime;
+(NSString*)getAlertBkByTime;
+(NSString*)getDelayBkByTime;
+(NSString*)getDelayBkByTimeType:(NSInteger) type;


+(void)showAlert:(NSString *)msg titleMsg:(NSString *)title DelegateObject:(id) delegateObject;

+(void)showActionSheetOptiontitleMsg:(NSString *)title ShowInView:(UIView*)view CancelMsg:(NSString*) cancelMsg  DelegateObject:(id) delegateObject Option:(NSString*)option,...;

//+(void) showCustomYesAlertSuperView:(id) sViewID  AlertMsg:(NSString*) msg;

+ (NetConnectType) CheckConnectedToNetwork;

+ (DeviceTypeVersion) CheckDeviceTypeVersion;

+ (void)DisableUserInteractionInView:(UIView *)superView exceptViewWithTag:(NSInteger)enableViewTag;
+ (void)EnableUserInteractionInView:(UIView *)superView;


+ (int)getRandomNumber:(int)from to:(int)to;

+(CGPoint) getMidPointBetween:(CGPoint) p1   andPoint:(CGPoint) p2;


+(UIImage*) screenShot:(UIView*) view;

@end
