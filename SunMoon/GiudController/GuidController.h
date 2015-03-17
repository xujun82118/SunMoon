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
#define KEY_GUID_START  @"guidStart" //引导用户点击拍照
#define KEY_GUID_finishIntro_Start_firstOpen @"GUID_finishIntro_Start_firstOpen"
#define KEY_GUID_giudStep_guidFirstlyGiveLight @"GUID_giudStep_guidFirstlyGiveLight"
#define KEY_GUID_giudStep_guidPanToBring @"GUID_giudStep_guidPanToBring"
#define KEY_GUID_guidPanToBring_waitForPan @"GUID_guidPanToBring_waitForPan"
#define KEY_GUID_guidIntoCamera @"GUID_guidIntoCamera"
#define KEY_GUID_guidIntoCamera_waitForTouch @"GUID_guidIntoCamera_waitForTouch"
#define KEY_GUID_mainView_End @"GUID_mainView_End"
#define KEY_GUID_camera_start @"GUID_camera_start"
#define KEY_GUID_camera_End @"GUID_camera_End"



#define KEY_GUID_HAVE_TAKE_PHOTO @"guidHaveTakePhoto" //提示已照过相了，每天只照一次


//引导步控制，每界面的引导以start开始，以end结束
//支持按步走，重新开始，指定步
//用开关辅助，支持细化步控制
typedef enum
{
    guid_Start  = 0,
    guid_finishIntro_Start_firstOpen,
    giudStep_guidFirstlyGiveLight,
    giudStep_guidPanToBring,
    giudStep_guidPanToBring_waitForPan,
    guidStep_guidIntoCamera,
    guidStep_guidIntoCamera_waitForTouch,
    guidStep_mainView_End,
    guid_camera_start,
    guid_camera_End,
    guid_oneByOne = 100, //依次增1步,
    guid_backToStar = 101, // 1000:清0步开始
    guid_setNumber = 102, //指定为完成的步
    
}GuidStepNum;


@interface GuidController : NSObject

@property(nonatomic)  NSUserDefaults* guidInfo;

@property(nonatomic) NSInteger  guidStepNumber;

//按步guid的定义
@property(nonatomic) BOOL  guidStart;
@property(nonatomic) BOOL  guidFinishIntroStartFirstOpen;
@property(nonatomic) BOOL  guidFirstlyGiveLight;
@property(nonatomic) BOOL  guidPanToBring;
@property(nonatomic) BOOL  guidPanToBring_waitForPan;
@property(nonatomic) BOOL  guidIntoCamera;
@property(nonatomic) BOOL  guidIntoCamera_waitForTouch;
@property(nonatomic) BOOL  mainView_End;
@property(nonatomic) BOOL  camera_start;
@property(nonatomic) BOOL  camera_End;


//其它辅助
@property(nonatomic) BOOL  guidHaveTakePhoto;





+ (GuidController *)sharedSingleUserInfo;

-(instancetype) initDefaultInfoAtFirstOpen:(BOOL) isGuid;

-(void) AddTouchIndication:(UIView*) intoSuperView  TouchImageName:(NSString*) touchImageName  TouchFrame:(CGRect) touchedFrame;

-(void) RemoveTouchIndication;
@end

@protocol GuidControllerDelegate <NSObject >



@end

