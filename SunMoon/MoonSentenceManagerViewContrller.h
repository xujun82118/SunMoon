//
//  MoonSentenceManager.h
//  SunMoon
//
//  Created by songwei on 14-5-14.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface MoonSentenceManagerViewContrller : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *moonSentenceTable;

@property (weak, nonatomic) IBOutlet UITextField *addNewSentence;
@property (weak, nonatomic) IBOutlet UIButton *addNewSentenceBtn;

- (IBAction)doAddMoonSentence:(id)sender;
- (void)canEditSentence:(id)sender;

- (IBAction)back:(id)sender;
@property (nonatomic, strong) UserInfo * user;

@end
