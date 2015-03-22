//
//  SkyMethodViewController.m
//  SunMoon
//
//  Created by xujun on 15-3-22.
//  Copyright (c) 2015年 xujun. All rights reserved.
//

#import "SkyMethodViewController.h"

@interface SkyMethodViewController ()

@end

@implementation SkyMethodViewController



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.opaque = YES;
    
}


- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
}



@end
