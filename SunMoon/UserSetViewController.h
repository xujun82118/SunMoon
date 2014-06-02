//
//  UserSetViewController.h
//  SunMoon
//
//  Created by songwei on 14-4-1.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"


@interface UserSetViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *moonBringupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *sunBringupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *timeRemindSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoCloudSwitch;


@property (weak, nonatomic) IBOutlet UILabel *testlabel;


- (IBAction)showMenu;

@end
