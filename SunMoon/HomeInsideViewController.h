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



@interface HomeInsideViewController : UIViewController<InfiniteScrollPickerDelegate,UserInfoCloudDelegate,ShareByShareSDRDelegate,CustomAlertDelegate>
{
      InfiniteScrollPicker *imageScrollSun;
      InfiniteScrollPicker *imageScrollMoon;
      VoicePressedHold* pressedVoiceForPlay;

      NSMutableArray *_shareTypeArray;


}
@property (weak, nonatomic) IBOutlet InfiniteScrollPicker *sunScroll;
@property (weak, nonatomic) IBOutlet InfiniteScrollPicker *moonScroll;
@property (weak, nonatomic) IBOutlet UIImageView * bkGroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView * sunScrollImageView;
@property (weak, nonatomic) IBOutlet UIImageView * moonScrollImageView;


@property (weak, nonatomic) IBOutlet UITextField *sunTimeText;
@property (weak, nonatomic) IBOutlet UITextField *moonTimeText;
@property (weak, nonatomic) IBOutlet UILabel *moonValueStatic;
@property (weak, nonatomic) IBOutlet UILabel *sunValueStatic;
@property (weak, nonatomic) IBOutlet UIButton *moonTimeCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *sunTimeCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *cloudCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareSunCtlBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareMoonCtlBtn;
@property (weak, nonatomic) IBOutlet UIImageView *lightSunSentence;
@property (weak, nonatomic) IBOutlet UIImageView *lightMoonSentence;
@property (weak, nonatomic) IBOutlet UIButton *voiceReplaySunBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceReplayMoonBtn;


@property (weak, nonatomic) IBOutlet UILabel *sunWordShow;
@property (weak, nonatomic) IBOutlet UILabel *moonWordShow;
@property (weak, nonatomic) IBOutlet UIButton *moonTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sunTimeBtn;

@property(nonatomic, copy) NSDictionary* currentSelectDataSun;
@property(nonatomic, copy) NSDictionary* currentSelectDataMoon;


@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * user;
@property (nonatomic, copy) UserDB * userDB;
@property (nonatomic, strong) UserInfoCloud* userCloud;


- (IBAction)moonAlertCtl:(id)sender;
- (IBAction)sunAlertCtl:(id)sender;

- (IBAction)shareNight:(id)sender;
- (IBAction)shareMorning:(id)sender;

- (IBAction)DeleteMoonImage:(id)sender;
- (IBAction)DeleteSunImage:(id)sender;

- (IBAction)replaySunVoice:(id)sender;
- (IBAction)replayMoonVoice:(id)sender;

- (IBAction)infoTextChanged:(id)sender;

-(IBAction)synClouderUserInfo:(id)sender;


-(void) back;


@end
