//
//  CommonObject.h
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//


//工作：梳理阳光值算法!!

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
#define INIT_DEFAULT_USER_NAME @"initDefaultNameWithoutRegister"

//用户类型
#define USER_TYPE_STEADY_TIME  10 //用户稳定期次数
#define USER_TYPE_NEW 0 //新用户,第一次使用
#define USER_TYPE_TYE 1 //试用期用户, 前n次使用
#define USER_TYPE_STEADY 2 //稳定用户
#define USER_TYPE_NEED_CARE 3 //第n*x次使用，需要某此用户关怀
#define USER_TYPE_VIP 10 //VIP用户

//阳光，月光时间
#define SUN_TIME_MIN  6
#define SUN_TIME_MAX  18
#define MOON_TIME_MIN  19
#define MOON_TIME_MAX  5  //次日

//阳光，月光标识
#define IS_SUN_TIME 1
#define IS_MOON_TIME 2

//用户基础信息
#define KEY_USER_NAME @"userName"
#define KEY_REG_TIME @"regTime"
#define KEY_SNS_ID @"snsID"
#define KEY_USER_HEADER_IMAGE @"userHeaderImage"
#define KEY_IS_REGISTER_USER @"isRegisterUser"
#define KEY_USER_TYPE @"userType" //用户类型
#define KEY_USER_TIME @"userTime" //用户使用次数

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

//相机传递的数据
#define CAMERA_IMAGE_KEY @"camera_image"
#define CAMERA_TIME_KEY @"camera_time"
#define CAMERA_SENTENCE_KEY @"camera_sentence"


#define SREEN_WIDTH   [[UIScreen mainScreen] bounds].size.width
#define SREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//控件定义
#define TOOL_BAR_HEIGHT  30
#define NAVI_BAR_HEIGHT 30
#define NAVI_BAR_BTN_Y  NAVI_BAR_HEIGHT-5 //距离导航条边
#define TOOL_BAR_BTN_Y SREEN_HEIGHT-TOOL_BAR_HEIGHT+5 //距离工具条上边缘

#define LEFT_NAVI_BTN_TO_SIDE_X 5
#define RIGHT_NAVI_BTN_TO_SIDE_X SREEN_WIDTH-5

#define TitleFont 18
#define TitleColor [UIColor whiteColor]


//tag 定义
#define  TAG_CAMERA_DECLEAR_LABEL 91
#define  TAG_EDITE_IMAGE_VIEW  92
#define  TAG_TIME_SCROLL_SUN 100
#define  TAG_TIME_SCROLL_MOON 101
#define  TAG_IMAGE_SCROLL_SUN 102
#define  TAG_IMAGE_SCROLL_MOON 103
#define  TAG_IMAGE_HIGH_LIGHT_SUN 104


#define ORIGINAL_MAX_WIDTH 640.0f


#define DEFAULT_CHOOSE_STRING_KEY  @"DefaultChooseString"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@interface CommonObject : NSObject

+ (NSString *)getCurrentTime;

+ (NSString *)getCurrentDate;

+ (NSInteger) checkSunOrMoonTime;


@end
