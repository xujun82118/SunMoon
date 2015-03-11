//
//  HomeInsideViewController.h
//  SunMoon
//
//  Created by songwei on 14-4-6.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfiniteScrollPicker.h"
#import "UserDB.h"
#import "VoicePressedHold.h"
#import "UserInfoCloud.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareByShareSDR.h"
#import "CustomAlertView.h"
#import "PulsingHaloLayer.h"
#import "SunSentenceManagerViewController.h"
#import "MoonSentenceManagerViewContrller.h"




@interface HomeInsideViewController : UIViewController<InfiniteScrollPickerDelegate,UserInfoCloudDelegate,ShareByShareSDRDelegate,CustomAlertDelegate,pitchDelegate>
{
      InfiniteScrollPicker *imageScrollSun;
      VoicePressedHold* pressedVoiceForPlay;

      NSMutableArray *_shareTypeArray;


}
@property (weak, nonatomic) IBOutlet UIButton *changeDayType;


@property (weak, nonatomic) IBOutlet UIImageView * bkGroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView * sunMoonScrollImageView;
@property (nonatomic, assign) IBOutlet UIButton *sunMoonCenter;



@property (weak, nonatomic) IBOutlet UILabel *sunMoonValueStatic;
@property (weak, nonatomic) IBOutlet UIButton *sunMoonTimeCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *sunTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *moonTimeBtn;
@property (weak, nonatomic) IBOutlet UITextField *sunMoonTimeText;


@property (weak, nonatomic) IBOutlet UIButton *cloudCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareCtlBtn;
@property (weak, nonatomic) IBOutlet UIImageView *lightSentence;
@property (weak, nonatomic) IBOutlet UIButton *voiceReplayBtn;

@property (weak, nonatomic) IBOutlet UIButton *editeSunWordBtn;
@property (weak, nonatomic) IBOutlet UIButton *editeMoonWordBtn;




@property (weak, nonatomic) IBOutlet UILabel *sunMoonWordShow;

@property(nonatomic, copy) NSDictionary* currentSelectData;


@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * user;
@property (nonatomic, copy) UserDB * userDB;
@property (nonatomic, strong) UserInfoCloud* userCloud;


@property (nonatomic, assign) PulsingHaloLayer *haloAdd;

@property(nonatomic, assign) NSInteger  DayType;


- (IBAction)changeDayTime:(id)sender;

- (IBAction)sunMoonAlertCtl:(id)sender;

- (IBAction)shareSunMoon:(id)sender;

- (IBAction)DeleteSunMoonImage:(id)sender;

- (IBAction)replaySunMoonVoice:(id)sender;

- (IBAction)infoTextChanged:(id)sender;

-(IBAction)synClouderUserInfo:(id)sender;

- (IBAction)backSegueFromViewController:(UIStoryboardSegue *)segue;


-(IBAction) back;


@end
