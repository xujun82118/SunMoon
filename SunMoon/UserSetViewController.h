//
//  UserSetViewController.h
//  SunMoon
//
//  Created by songwei on 14-4-1.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "UserDB.h"
#import "VPImageCropperViewController.h"
#import <ShareSDK/ShareSDK.h>


@interface UserSetViewController : UITableViewController<VPImageCropperDelegate>
{
    
    NSMutableArray *_shareTypeArray;
    
}
@property (weak, nonatomic) IBOutlet UISwitch *moonBringupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sunBringupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timeSunRemindSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timeMoonRemindSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *autoCloudSwitch;


@property (weak, nonatomic) IBOutlet UILabel *testlabel;

@property (nonatomic, strong) IBOutlet UIImageView *userHeaderImageView;

@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * user;

- (IBAction)showMenu;

@end
