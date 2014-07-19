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


@interface HomeInsideViewController : UIViewController<InfiniteScrollPickerDelegate>
{
      InfiniteScrollPicker *imageScrollSun;
      InfiniteScrollPicker *imageScrollMoon;

}
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




- (IBAction)moonAlertCtl:(id)sender;
- (IBAction)sunAlertCtl:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *moonTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *sunTimeBtn;
- (IBAction)shareNight:(id)sender;
- (IBAction)shareMorning:(id)sender;

- (IBAction)DeleteMoonImage:(id)sender;
- (IBAction)DeleteSunImage:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *sunWordShow;
@property (weak, nonatomic) IBOutlet UILabel *moonWordShow;


@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * user;
@property (nonatomic, copy) UserDB * userDB;
@property(nonatomic, copy) NSDictionary* currentSelectDataSun;
@property(nonatomic, copy) NSDictionary* currentSelectDataMoon;


-(void) back;


@end
