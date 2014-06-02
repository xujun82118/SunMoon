//
//  aboutViewController.m
//  SunMoon
//
//  Created by songwei on 14-5-31.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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


- (IBAction)addStars:(id)sender
{
    
    //    NSString *str = [NSString stringWithFormat:
    //                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d",
    //                     782426992 ];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"去给'%@'打分吧！",@"天天更美丽"]
    //                                                        message:@"您的评价对我们很重要"
    //                                                       delegate:self
    //                                              cancelButtonTitle:nil
    //                                              otherButtonTitles:@"稍后评价",@"去评价",nil];
    //    [alertView show];
    
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tian-tian-geng-mei-li/id782426992?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:url];
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
