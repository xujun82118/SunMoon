//
//  GuidController.h
//  SunMoon
//
//  Created by songwei on 14-8-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
//初步为NO, 引导一次后更新为YES
#define KEY_GUID_FIRSTLY_OPEN @"openGuid" //用户引导滑屏
#define KEY_GUID_INTO_CAMERA  @"guidIntoCamera" //引导用户点击拍照
#define KEY_GUID_TAP_BRING_LIGHT  @"guidTapBringLight" //提示点击光
#define KEY_GUID_TAP_HEADER  @"guidTapHeader" //提示点击头像
#define KEY_GUID_2S_DELAY  @"2SDelay" //提示2秒延时
#define KEY_GUID_PAN_TO_BRING @"guidPanToBring" //提示拖动光到育成

#define KEY_GUID_GIVE_ONE_LIGHT  @"guidGiveOneLight" //提示奖励一个光
#define KEY_GUID_HAVE_TAKE_PHOTO @"guidHaveTakePhoto" //提示已照过相了，每天只照一次
#define KEY_GUID_HAVE_GIVEN_LIGHT @"guidHaveGiveLight" //提示已奖励过光了，每天早晚只将来一次



@interface GuidController : NSObject

@property(nonatomic)  NSUserDefaults* guidInfo;

@property(nonatomic) BOOL  fristlyOpenGuidCtl;
@property(nonatomic) BOOL  guidIntoCamera;
@property(nonatomic) BOOL  guidTapLight;
@property(nonatomic) BOOL  guid2SDelay;
@property(nonatomic) BOOL  guidPanToBring;
@property(nonatomic) BOOL  guidHaveTakePhoto;
@property(nonatomic) BOOL  guidHaveGiveLight;





+ (GuidController *)sharedSingleUserInfo;

-(instancetype) initDefaultInfoAtFirstOpen:(BOOL) isGuid;

-(void) updateFirstlyOpenGuidCtl:(BOOL) isGuid;

-(void) updateGuidIntoCamera:(BOOL) isGuid;

-(void) updateGuidGiveOneLight:(BOOL) isGuid;

-(void) updateGuidITapLight:(BOOL) isGuid;

-(void) updateGuid2sDelay:(BOOL) isGuid;

-(void) updateGuidPanToBring:(BOOL) isGuid;

-(void) updateGuidHaveTakePhoto:(BOOL) isGuid;

-(void) updateGuidHaveGiveLight:(BOOL) isGuid;


@end
