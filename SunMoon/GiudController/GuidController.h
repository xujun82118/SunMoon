//
//  GuidController.h
//  SunMoon
//
//  Created by songwei on 14-8-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
//初步为NO, 引导一次后更新为YES
#define KEY_GUID_STEP_NUMBER  @"guidStepNumber"  //引导流程控制
#define KEY_GUID_FIRSTLY_OPEN @"openGuid" //用户引导滑屏
#define KEY_GUID_FIRSTLY_GIVE_LIGHT  @"guidFirstlyGiveLight"  //第一次登录奖励光
#define KEY_GUID_INTO_CAMERA  @"guidIntoCamera" //引导用户点击拍照
#define KEY_GUID_TAP_BRING_LIGHT  @"guidTapBringLight" //提示点击光
#define KEY_GUID_TAP_HEADER  @"guidTapHeader" //提示点击头像
#define KEY_GUID_2S_DELAY  @"2SDelay" //提示2秒延时
#define KEY_GUID_PAN_TO_BRING @"guidPanToBring" //提示拖动光到育成

#define KEY_GUID_GIVE_ONE_LIGHT  @"guidGiveOneLight" //提示奖励一个光
#define KEY_GUID_HAVE_TAKE_PHOTO @"guidHaveTakePhoto" //提示已照过相了，每天只照一次
#define KEY_GUID_HAVE_GIVEN_LIGHT @"guidHaveGiveLight" //提示已奖励过光了，每天早晚只将来一次


//引导步控制，每界面的引导以start开始，以end结束
//支持按步走，重新开始，指定步
//用开关辅助，支持细化步控制
typedef enum
{
    guid_Start  = 0,
    guid_finishIntro_Start_firstOpen,
    //guid_bring_intro_tofront,
    giudStep_guidFirstlyGiveLight,
    guidStep_guidFirstlyGiveLight_waitForTouchLigh,
    giudStep_guidPanToBring,
    giudStep_guidPanToBring_waitForPan,
    guidStep_guidIntoCamera,
    guidStep_guidIntoCamera_waitForTouch,
    guidStep_mainView_End,
    guid_camera_start,
    guid_camera_End,
    guid_oneByOne = 100, //依次增1步,
    guid_backToStar = 101, // 1000:清0步开始
    guid_setNumber = 102, //指定第几步
    
}GuidStepNum;


@interface GuidController : NSObject

@property(nonatomic)  NSUserDefaults* guidInfo;

@property(nonatomic) NSInteger  guidStepNumber;

@property(nonatomic) BOOL  fristlyOpenGuidCtl;
@property(nonatomic) BOOL  guidFirstlyGiveLight;
@property(nonatomic) BOOL  guidIntoCamera;
@property(nonatomic) BOOL  guidTapLight;
@property(nonatomic) BOOL  guid2SDelay;
@property(nonatomic) BOOL  guidPanToBring;
@property(nonatomic) BOOL  guidHaveTakePhoto;
@property(nonatomic) BOOL  guidHaveGiveLight;





+ (GuidController *)sharedSingleUserInfo;

-(instancetype) initDefaultInfoAtFirstOpen:(BOOL) isGuid;

-(void) updateGuidStepNumber:(GuidStepNum) guidNum;

-(void) updateFirstlyOpenGuidCtl:(BOOL) isGuid;

-(void) updateGuidFirstlyGiveLight:(BOOL) isGuid;

-(void) updateGuidIntoCamera:(BOOL) isGuid;

-(void) updateGuidGiveOneLight:(BOOL) isGuid;

-(void) updateGuidITapLight:(BOOL) isGuid;

-(void) updateGuid2sDelay:(BOOL) isGuid;

-(void) updateGuidPanToBring:(BOOL) isGuid;

-(void) updateGuidHaveTakePhoto:(BOOL) isGuid;

-(void) updateGuidHaveGiveLight:(BOOL) isGuid;

-(void) AddTouchIndication:(UIView*) intoSuperView  TouchImageName:(NSString*) touchImageName  TouchFrame:(CGRect) touchedFrame;

-(void) RemoveTouchIndication;
@end

@protocol GuidControllerDelegate <NSObject >



@end

