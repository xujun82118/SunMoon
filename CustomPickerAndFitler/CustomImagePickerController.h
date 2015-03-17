//
//  CustomImagePickerController.h
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDB.h"
#import "AFPickerView.h"
#import "VoicePressedHold.h"
#import "AminationCustom.h"
#import "CustomAnimation.h"
#import "PulsingHaloLayer.h"

//#import "ImageFilterProcessViewController.h"




@protocol CustomImagePickerControllerDelegate;

@interface CustomImagePickerController : UIImagePickerController
<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPickerViewDataSource, AFPickerViewDelegate,pitchDelegate,AminationCustomDelegate,CustomAnimationDelegate>
{
    id<CustomImagePickerControllerDelegate> _customDelegate;
     AFPickerView *defaultPickerView;
    
    NSDictionary* imagePickerData;
    VoicePressedHold* pressedVoice;
}

@property(nonatomic)BOOL isSingle;
@property(nonatomic) NSInteger iSunORMoon; //1:太阳，2：月亮
@property(nonatomic)id<CustomImagePickerControllerDelegate> customDelegate;
@property (nonatomic, strong) NSDictionary* imagePickerData;

@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * userInfo;

@property (nonatomic, strong)UIProgressView *progressView;
@property (retain, nonatomic)  F3BarGauge *customRangeBar;

@property (nonatomic, strong)NSString*  voiceName;
@property (nonatomic, assign) PulsingHaloLayer *haloGive;


- (void)setNewPith:(float)pitchValue;



@end

//定义协议，一个统一的处理接口
@protocol CustomImagePickerControllerDelegate <NSObject>

- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn;

- (void)cancelCamera;
@end
