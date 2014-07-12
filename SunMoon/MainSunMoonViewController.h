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

@interface MainSunMoonViewController : UIViewController<CustomImagePickerControllerDelegate,ImageFitlerProcessDelegate, UserInfoCloudDelegate,VPImageCropperDelegate>
{

}

- (IBAction)showMenu;


- (IBAction)doUserHeaderBtn:(id)sender;
- (IBAction)testNet:(id)sender;
- (IBAction)deleteDataBase:(id)sender;
- (IBAction)reCreatDataBase:(id)sender;

-(void) saveUserImage:(UIImage*)image  withTime: (NSString*) dateTime;



- (IBAction)doCamera:(id)sender;

@property (nonatomic, copy) UserDB * userDB;

@property (nonatomic, strong) UserInfo * userInfo;

@property (nonatomic, strong) UserInfoCloud* userCloud;

@property (nonatomic, strong) IBOutlet UIImageView *userHeaderImageView;

@property (weak, nonatomic) IBOutlet UIImageView *mainBgImage;

@property (weak, nonatomic) IBOutlet UIImageView *skySunorMoonImage;

@property (weak, nonatomic) IBOutlet UIImageView *panSunorMoonImageView;

@end
