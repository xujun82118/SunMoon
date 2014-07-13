//
//  tapToImage.m
//  SunMoon
//
//  Created by songwei on 14-7-13.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "tapToImage.h"
#import "TapSeeImage.h"

@interface tapToImage ()

@end

@implementation tapToImage
@synthesize showImage =  _showImage;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pop:(id)sender {
    [TapSeeImage dismissClickView];
    
}

@end
