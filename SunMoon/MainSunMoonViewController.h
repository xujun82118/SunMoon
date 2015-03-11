//
//  MainSunMoonViewController.h
//  SunMoon
//
//  Created by songwei on 14-3-30.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImagePickerController.h"
#import "ImageFilterProcessViewController.h"
#import "UserDB.h"
#import "UserInfoCloud.h"
#import "REFrostedViewController.h"
#import "VPImageCropperViewController.h"
#import "CommonObject.h"
#import "CustomAlertView.h"
#import "CustomAnimation.h"
#import "PulsingHaloLayer.h"




@interface MainSunMoonViewController : UIViewController<CustomImagePickerControllerDelegate,ImageFitlerProcessDelegate, UserInfoCloudDelegate,VPImageCropperDelegate,CustomAlertDelegate,CustomAnimationDelegate,PulsingHaloLayerAnimationDelegate,ShareByShareSDRDelegate>
{

}
- (IBAction)testButton1:(id)sender;

- (IBAction)showMenu;


- (IBAction)doUserHeaderBtn:(id)sender;
- (IBAction)testNet:(id)sender;
- (IBAction)deleteDataBase:(id)sender;
- (IBAction)reCreatDataBase:(id)sender;

-(void) saveUserImage:(UIImage*)image  withTime: (NSString*) dateTime;



- (IBAction)intoCamera:(id)sender;
- (IBAction)getBringedUpLight:(id)sender;
- (IBAction)screenShare:(id)sender;



@property (nonatomic, copy) UserDB * userDB;

@property (nonatomic, strong) UserInfo * userInfo;

@property (nonatomic, strong) UserInfoCloud* userCloud;

@property (nonatomic, strong) UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIImageView *mainBgImage;

@property (weak, nonatomic) IBOutlet UIImageView *skySunorMoonImage;

@property (weak, nonatomic) IBOutlet UIImageView *panSunorMoonImageView;

@property (weak, nonatomic) IBOutlet UIButton* menuBtn;
@property (nonatomic, assign) IBOutlet UIButton* screenShareBtn;


@property (weak, nonatomic) IBOutlet UIImageView *skyWindow;
@property (weak, nonatomic) IBOutlet UIImageView *lightPostionFrame;


//@property (weak, nonatomic) IBOutlet UIButton* intoCameraBtn;

@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (nonatomic, strong) PulsingHaloLayer *haloTouch;
@property (nonatomic, assign) PulsingHaloLayer *haloToHeader;
@property (nonatomic, assign) PulsingHaloLayer *haloToSky;
@property (nonatomic, assign) PulsingHaloLayer *haloToReminber;




//@property (weak, nonatomic) IBOutlet UIButton * intoCameraBtn;
//@property (weak, nonatomic) IBOutlet UIButton * showBringLightBtn;



@end
