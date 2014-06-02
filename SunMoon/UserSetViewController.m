//
//  UserSetViewController.m
//  SunMoon
//
//  Created by songwei on 14-4-1.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserSetViewController.h"
#import "NavBar.h"

@interface UserSetViewController ()

@end

@implementation UserSetViewController
@synthesize moonBringupSwitch, sunBringupSwitch, autoCloudSwitch, timeRemindSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //self.navigationController.navigationBarHidden = NO;
    //self.title = @"1234";
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    //[self.navigationItem setNewTitle:@"用户设置"];


    
}


- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
