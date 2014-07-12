//
//  CommonObject.h
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

// 第一次登录送一个阳光，点击太阳，移动到头像，点亮头像
//工作：梳理阳光值算法!!
//动画, 判断动画的类型,
// 捕捉手指的移动
// 可爱提示框



#import <Foundation/Foundation.h>
#import "UserDB.h"




#define  FIRST_START_OPEN_GUID  @"isFirstTimeUseAndOpenGuid"

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

//全局变量
static BOOL isOpenGuid = NO; //全部提醒功能的总开关


//默认用户名
#define INIT_DEFAULT_USER_NAME @"MyDefaultNameWithoutRegister"

//用户类型
#define USER_TYPE_STEADY_TIME  10 //用户稳定期次数
#define USER_TYPE_NEW 255 //新用户,第一次使用
#define USER_TYPE_TYE 1 //试用期用户, 前n次使用
#define USER_TYPE_STEADY 2 //稳定用户
#define USER_TYPE_NEED_CARE 3 //第n*x次使用，需要某些用户关怀
#define USER_TYPE_VIP 10 //VIP用户


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


//阳光，月光时间
#define SUN_TIME_MIN  6
#define SUN_TIME_MAX  18
#define MOON_TIME_MIN  19
#define MOON_TIME_MAX  5  //次日

//阳光，月光标识
#define IS_SUN_TIME 1
#define IS_MOON_TIME 2

//用户基础信息
#define KEY_USER_ID @"userID"
#define KEY_USER_NAME @"userName"
#define KEY_REG_TIME @"regTime"
#define KEY_SNS_ID @"snsID"
#define KEY_USER_HEADER_IMAGE @"userHeaderImage"
#define KEY_IS_REGISTER_USER @"isRegisterUser"
#define KEY_USER_TYPE @"userType" //用户类型
#define KEY_USER_TIME @"userTime" //用户使用次数


//用户最近登录的时期
#define KEY_LOGIN_LAST_SUN_DATE   @"userLoginLastSunDate"
#define KEY_LOGIN_LAST_MOON_DATE   @"userLoginLastMoonDate"


//用户连续登录次数
#define KEY_CONTINUE_LOGIN_SUN_COUNT @"continueLoginSunCount"
#define KEY_CONTINUE_LOGIN_MOON_COUNT @"continueLoginMoonCount"


//是否有光在育成
#define KEY_IS_BRING_UP_SUN @"isBringUpSun"
#define KEY_IS_BRING_UP_MOON @"isBringUpMoon"

//当天照片是否加过光值
#define KEY_IS_HAVE_ADD_SUN @"isHaveAddSun"
#define KEY_IS_HAVE_ADD_MOON @"isHaveAddMoon"

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


#define SCREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//控件定义
#define TOOL_BAR_HEIGHT  30
#define NAVI_BAR_HEIGHT 30
#define NAVI_BAR_BTN_Y  NAVI_BAR_HEIGHT-5 //距离导航条边
#define TOOL_BAR_BTN_Y SCREEN_HEIGHT-TOOL_BAR_HEIGHT+5 //距离工具条上边缘

#define LEFT_NAVI_BTN_TO_SIDE_X 5
#define RIGHT_NAVI_BTN_TO_SIDE_X SCREEN_WIDTH-5

#define TitleFont 18
#define TitleColor [UIColor whiteColor]


//tag 定义
#define  TAG_CAMERA_DECLEAR_LABEL 91
#define  TAG_EDITE_IMAGE_VIEW  92
#define  TAG_CAMERA_OLD_IMAGE_VIEW 93
#define  TAG_EDIT_OLD_IMAGE_VIEW  94
#define  TAG_TIME_SCROLL_SUN 100
#define  TAG_TIME_SCROLL_MOON 101
#define  TAG_IMAGE_SCROLL_SUN 102
#define  TAG_IMAGE_SCROLL_MOON 103
#define  TAG_IMAGE_HIGH_LIGHT_SUN 104

#define  TAG_EDITE_PHOTO_SCROLL_VIEW 109
#define  TAG_EDITE_PHOTO_SCROLL_LABEL 200 //200到215

#define  TAG_LIGHT_USER_HEADER 300 //300到307


#define ORIGINAL_MAX_WIDTH 640.0f


#define DEFAULT_CHOOSE_STRING_KEY  @"DefaultChooseString"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

#define BUNDLE_NAME @"Resource"

@interface CommonObject : NSObject

+ (NSString *)getCurrentTime;

+ (NSString *)getCurrentDate;

+(NSDate*) returnChooseTimeUnit:(NSDate*) dateTime Year:(BOOL) needYear Month:(BOOL) needMonth Day:(BOOL) needDay Hour:(BOOL) needHour Minute:(BOOL) needMinute Second:(BOOL) needSecond;

+ (NSInteger) checkSunOrMoonTime;

+(void)showAlert:(NSString *)msg titleMsg:(NSString *)title DelegateObject:(id) delegateObject;

+(void)showActionSheetOptiontitleMsg:(NSString *)title ShowInView:(UIView*)view CancelMsg:(NSString*) cancelMsg  DelegateObject:(id) delegateObject Option:(NSString*)option,...;

@end
