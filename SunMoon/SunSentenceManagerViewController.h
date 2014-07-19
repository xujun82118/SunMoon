//
//  SunSentenceManagerViewController.h
//  SunMoon
//
//  Created by songwei on 14-5-11.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface SunSentenceManagerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sunSentenceTable;

@property (weak, nonatomic) IBOutlet UITextField *addNewSentence;
@property (weak, nonatomic) IBOutlet UIButton *addNewSentenceBtn;

- (IBAction)doAddSunSentence:(id)sender;
- (void)canEditSentence:(id)sender;


- (IBAction)back:(id)sender;

@property (nonatomic, strong) UserInfo * user;

@end
