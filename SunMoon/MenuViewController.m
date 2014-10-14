//
//  DEMOMenuViewController.m
//  REFrostedViewControllerStoryboards
//
//  Created by Roman Efimov on 10/9/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "MenuViewController.h"
#import "MainSunMoonViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "UserSetViewController.h"
#import "AboutViewController.h"

#import "YouMiWall.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"默认头像.png"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        //[view addSubview:imageView];
        view;
    });
    
    
    //self.tableView.frame = CGRectMake(100, 100, 100, 200);
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
//{
//    if (sectionIndex == 0)
//        return nil;
//    //第二个section的view
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
//    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
//    label.text = @"Friends Online";
//    label.font = [UIFont systemFontOfSize:15];
//    label.textColor = [UIColor whiteColor];
//    label.backgroundColor = [UIColor clearColor];
//    [label sizeToFit];
//    [view addSubview:label];
//    
//    return view;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
//{
//    if (sectionIndex == 0)
//        return 0;
//    
//    return 34;
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        MainSunMoonViewController *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainSunMoonController"];
        navigationController.viewControllers = @[homeViewController];
    } else if (indexPath.section == 0 && indexPath.row == 1)
    {
        UserSetViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UserSetController"];
        navigationController.viewControllers = @[secondViewController];
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        [self youMiAd:nil];
    }

    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *titles = @[@"   我的天空", @"   我的设置",@"   更多推荐"];
    cell.textLabel.text = titles[indexPath.row];
    cell.textAlignment = NSTextAlignmentLeft;
    cell.backgroundColor = [UIColor redColor];
    
    if(indexPath.row == 0)
    {
        tableView.separatorColor = [UIColor whiteColor];

        cell.imageView.image = [UIImage imageNamed:@"home.png"];
    }else if(indexPath.row == 1)
    {
        tableView.separatorColor = [UIColor whiteColor];

        cell.imageView.image = [UIImage imageNamed:@"setting.png"];

    }else if(indexPath.row == 2)
    {
        tableView.separatorColor = [UIColor whiteColor];

        cell.imageView.image = [UIImage imageNamed:@"ning.png"];
        
    }
    
    return cell;
}


- (void)youMiAd:(id)sender
{
    [YouMiWall showOffers:NO didShowBlock:^{
        NSLog(@"有米墙已显示");
    } didDismissBlock:^{
        NSLog(@"有米墙已退出");
    }];
    
}

@end
