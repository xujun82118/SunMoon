//
//  UserSetViewController.m
//  SunMoon
//
//  Created by songwei on 14-4-1.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserSetViewController.h"
#import "NavBar.h"
#import "ShareByShareSDR.h"


@interface UserSetViewController ()


/**
 *	@brief	用户信息更新
 *
 *	@param 	notif 	通知
 */
- (void)userInfoUpdateHandler:(NSNotification *)notif;


@end

@implementation UserSetViewController
@synthesize moonBringupSwitch, sunBringupSwitch, autoCloudSwitch, timeSunRemindSwitch,timeMoonRemindSwitch,userHeaderImageView,user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        

        
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    
    //获取单例用户数据
    self.user= [UserInfo  sharedSingleUserInfo];

    [self setTableHeaderView];
    
    //监听用户信息变更
    //[ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
     //                          target:self
       //                        action:@selector(userInfoUpdateHandler:)];
    [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
                              target:self
                            action:@selector(userInfoUpdateHandler:)];
    
    _shareTypeArray = [[NSMutableArray alloc] init];
    
    NSArray *shareTypes = [ShareSDK connectedPlatformTypes];
    for (int i = 0; i < [shareTypes count]; i++)
    {
        NSNumber *typeNum = [shareTypes objectAtIndex:i];
        ShareType type = (ShareType)[typeNum integerValue];
        id<ISSPlatformApp> app = [ShareSDK getClientWithType:type];
        
//        if ([app isSupportOneKeyShare] || type == ShareTypeInstagram || type == ShareTypeGooglePlus || type == ShareTypeQQSpace)
//        if (type == ShareTypeSinaWeibo || type == ShareTypeTencentWeibo || type == ShareTypeQQSpace|| type == ShareTypeWeixiSession|| type == ShareTypeWeixiTimeline|| type == ShareTypeQQ)
        if (type == ShareTypeSinaWeibo || type == ShareTypeTencentWeibo)
        {
            [_shareTypeArray addObject:[NSMutableDictionary dictionaryWithObject:[shareTypes objectAtIndex:i]
                                                                          forKey:@"type"]];
        }
    }
    
    NSArray *authList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()] atomically:YES];
    }
    else
    {
        for (int i = 0; i < [authList count]; i++)
        {
            NSDictionary *item = [authList objectAtIndex:i];
            for (int j = 0; j < [_shareTypeArray count]; j++)
            {
                if ([[[_shareTypeArray objectAtIndex:j] objectForKey:@"type"] integerValue] == [[item objectForKey:@"type"] integerValue])
                {
                    [_shareTypeArray replaceObjectAtIndex:j withObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                    break;
                }
            }
        }
    }


}


-(void) setTableHeaderView
{
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 90.0f)];
        //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 70, 70)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = self.user.userHeaderImage;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 35.0;
        imageView.layer.borderColor = [UIColor brownColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        [view addSubview:imageView];
        view;
    });
    
    
    //头像触发
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeaderImage)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 1;
    recognizer.delegate = self;
    [self.tableView.tableHeaderView addGestureRecognizer:recognizer];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //self.navigationController.navigationBarHidden = NO;
    //self.title = @"1234";
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    //[self.navigationItem setNewTitle:@"用户设置"];


    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ShareSDK removeAllNotificationWithTarget:self];
    
}





-(void)changeHeaderImage;
{
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:@"请选择头像"
                                                             delegate:self
                                                    cancelButtonTitle:@"下次再说"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
    
    
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:@"是否替换当前相片" ]) {
        //替换
        if (buttonIndex == 0) {
            
            
        } else if (buttonIndex == 1)//不替换
        {
            
        }
    }
    
    if ([actionSheet.title isEqualToString:@"请选择头像"]) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
    
    
}


#pragma mark - UIImagePickerControllerDelegate
//相机或相册的回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
       // UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage* portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];

        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - VPImageCropperDelegate
//实现委托函数
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.user.userHeaderImage = editedImage;
    [self setTableHeaderView];

    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        [self.user updateUserHeaderImage:self.user.userHeaderImage];
        
        
    }];
}
//实现委托函数
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
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

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
        view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
        label.text = @"选择一种登录方法";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
        
        return view;
    }

    if (sectionIndex == 1)
    {
        //第二个section的view
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
        view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
        label.text = @"设置";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        [view addSubview:label];
        
        return view;
    
    
    }
    
    //第三个section的view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"关于";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
    


}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
//    if (sectionIndex == 0)
//        return 34;
    
    return 34;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section  == 2 && indexPath.row == 0)
    {
        
        //查看网络
        NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
        if (typeNet == netNon) {
            [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
            return;
        }
        
        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tian-tian-geng-mei-li/id782426992?ls=1&mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    if (indexPath.section  == 2 && indexPath.row == 1)
    {
        //查看网络
        NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
        if (typeNet == netNon) {
            [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
            return;
        }
        
        [CommonObject showAlert:@"你的任何意见，我们都无比重视^" titleMsg:@"用户关怀" DelegateObject:self];
        
        
        ShareByShareSDR* share = [ShareByShareSDR alloc];
        [share WeiBoMe];
        

    }
    
}


//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section  == 2 && indexPath.row == 0)
//    {
//        
//        NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tian-tian-geng-mei-li/id782426992?ls=1&mt=8"];
//        [[UIApplication sharedApplication] openURL:url];
//    }
//    
//}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return [_shareTypeArray count];
    }else if(sectionIndex == 1)
    {
        return 2;
    }
    
    return 2;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = Nil;
    if (indexPath.section == 0)
    {
        
        static NSString *cellIdentifier = @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
        }
        
        UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchCtrl sizeToFit];
        [switchCtrl addTarget:self action:@selector(authSwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchCtrl;
        
        if (indexPath.row < [_shareTypeArray count])
        {
            NSDictionary *item = [_shareTypeArray objectAtIndex:indexPath.row];
            
            NSInteger temp =[[item objectForKey:@"type"] integerValue];
            NSString* tempString =[NSString stringWithFormat:
                                   @"sns_icon_%ld.png",
                                   (long)temp];
            UIImage *img = [UIImage imageNamed:tempString];
            cell.imageView.image = img;
            
            ((UISwitch *)cell.accessoryView).on = [ShareSDK hasAuthorizedWithType:(ShareType)[[item objectForKey:@"type"] integerValue]];
            ((UISwitch *)cell.accessoryView).tag = indexPath.row;
            
            if (((UISwitch *)cell.accessoryView).on)
            {
                cell.textLabel.text = [item objectForKey:@"username"];
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"TEXT_UNAUTH_2", @"尚未授权");
            }
        }
        
    }
    
    if (indexPath.section == 1) {
        
        static NSString *cellIdentifier = @"Cell1";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        if (indexPath.row == 0) {
            
            
            cell.textLabel.text = @"开启自动云同步";
            
            UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchCtrl.tag =TAG_AUTO_CLOUD_SWITCH;
            [switchCtrl sizeToFit];
            [switchCtrl addTarget:self action:@selector(autoCloudSwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchCtrl;
            
            switchCtrl.on = self.user.cloudSynAutoCtl;
            
        }
        
        if (indexPath.row == 1) {
            
            
            cell.textLabel.text = @"相片自动本地存储";
            
            UISwitch *switchCtrl = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchCtrl sizeToFit];
            [switchCtrl addTarget:self action:@selector(photoSaveSwitchChangeHandler:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchCtrl;
            
            switchCtrl.on = self.user.photoSaveAutoCtl;
            
        }
        

    }

    
    if (indexPath.section == 2)
    {
        
        static NSString *cellIdentifier = @"Cell2";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        
        if (indexPath.row == 0) {
            
            
            cell.textLabel.text = @"给个星评";
            

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
        
        if (indexPath.row == 1) {
            
            
            cell.textLabel.text = @"提个意见@我们";
            
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    }
    return cell;
}


#pragma mark - Switcher Handler
- (void)autoCloudSwitchChangeHandler:(UISwitch *)sender
{
    if (sender.on) {
        
        //查看网络
        NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
        if (typeNet == netNon) {
            [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
            sender.on = FALSE;
            return;
        }
        
        //判断是否注册过
        if (!self.user.isRegisterUser) {
            //没注册过，则关闭
            sender.on = NO;
            
            [CommonObject showAlert:@"请选绑定账户进行登录~" titleMsg:Nil DelegateObject:self];
        }
    }
    
    [self.user updatecloudSynAutoCtl:sender.on];

    
    
    
}


- (void)photoSaveSwitchChangeHandler:(UISwitch *)sender
{
    
    [self.user updatePhotoSaveAutoCtl:sender.on];

}

- (void)authSwitchChangeHandler:(UISwitch *)sender
{
    //MainSunMoonAppDelegate *appDelegate = (MainSunMoonAppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    
    //tag与表中的授权选项行对应
    NSInteger index = sender.tag;
    
    if (index < [_shareTypeArray count])
    {
        NSMutableDictionary *item = [_shareTypeArray objectAtIndex:index];
        if (sender.on)
        {
            
            //查看网络
            NetConnectType typeNet = [CommonObject CheckConnectedToNetwork];
            if (typeNet == netNon) {
                [CommonObject showAlert:@"请检查网络" titleMsg:nil DelegateObject:self];
                sender.on = FALSE;
                return;
            }
            
            //用户用户信息
            ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
            
            id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                                 allowCallback:YES
                                                                 authViewStyle:SSAuthViewStyleFullScreenPopup
                                                                  viewDelegate:nil
                                                       authManagerViewDelegate:Nil];
            
            //在授权页面中添加关注官方微博
            [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                            SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                            [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                            SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                            nil]];
            
            [ShareSDK getUserInfoWithType:type
                              authOptions:authOptions
                                   result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
                                       if (result)
                                       {
                                           //授权成功
                                           [item setObject:[userInfo nickname] forKey:@"username"];
                                           NSString* temp =[userInfo uid];
                                           NSLog(@"uid = %@", temp);
                                           [_shareTypeArray writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()] atomically:YES];
                                           
                                           //取消另一个登录
                                           NSArray *shareTypes = [ShareSDK connectedPlatformTypes];
                                           for (int i = 0; i < [shareTypes count]; i++)
                                           {
                                               NSNumber *typeNum = [shareTypes objectAtIndex:i];
                                               ShareType typeAll = (ShareType)[typeNum integerValue];
                                               
                                               if (typeAll!=[userInfo type]) {
                                                   //取消授权
                                                   [ShareSDK cancelAuthWithType:typeAll];

                                               }
                                               
                                           }
                                           
                                       }
                                       NSLog(@"%ld:%@",(long)[error errorCode], [error errorDescription]);

                                       [self.tableView reloadData];
                                   }];
            
            

            
            
        }
        else
        {
            //取消授权
            [ShareSDK cancelAuthWithType:(ShareType)[[item objectForKey:@"type"] integerValue]];
            [self.tableView reloadData];
            
            //关闭云同步
            UISwitch *switchCtrl = (UISwitch*)[self.view viewWithTag:TAG_AUTO_CLOUD_SWITCH];
            switchCtrl.on = NO;
            [self.user updatecloudSynAutoCtl:NO];
            
            
            //清空用户SNS信息
            [self.user updateSns_ID:INIT_DEFAULT_SNS_ID PlateType:0];
            [self.user updateuserName:INIT_DEFAULT_USER_NAME];
            [self.user updateUserHeaderImage:Nil];
            //刷新头像
            [self setTableHeaderView];
            
        }
        
    }
    
    

    
    
}

#pragma mark - shareSDK 回调
//增加用户信息时，才会调用，删除鉴权时不会
- (void)userInfoUpdateHandler:(NSNotification *)notif
{
    NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    
    for (int i = 0; i < [_shareTypeArray count]; i++)
    {
        NSMutableDictionary *item = [_shareTypeArray objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
        }else
        {
            //取消另一个授权，保持只有一个
            [ShareSDK cancelAuthWithType:type];

        }
        [self.tableView reloadData];

    }
    
    
    //存用户授权信息
    NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()]];
    if (authList == nil)
    {
        authList = [NSMutableArray array];
    }
    
    NSString *platName = nil;
    //NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
    switch (plat)
    {
        case ShareTypeSinaWeibo:
            platName = NSLocalizedString(@"TEXT_SINA_WEIBO", @"新浪微博");
            break;
        case ShareTypeTencentWeibo:
            platName = NSLocalizedString(@"TEXT_TENCENT_WEIBO", @"腾讯微博");
            break;
            
        default:
            platName = NSLocalizedString(@"TEXT_UNKNOWN", @"未知");
    }
    
    //id<ISSPlatformUser> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
    BOOL hasExists = NO;
    for (int i = 0; i < [authList count]; i++)
    {
        NSMutableDictionary *item = [authList objectAtIndex:i];
        ShareType type = (ShareType)[[item objectForKey:@"type"] integerValue];
        if (type == plat)
        {
            [item setObject:[userInfo nickname] forKey:@"username"];
            hasExists = YES;
            break;
        }
    }
    
    if (!hasExists)
    {
        NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 platName,
                                 @"title",
                                 [NSNumber numberWithInteger:plat],
                                 @"type",
                                 [userInfo nickname],
                                 @"username",
                                 nil];
        [authList addObject:newItem];
    }
    
    [authList writeToFile:[NSString stringWithFormat:@"%@/loginListCache.plist",NSTemporaryDirectory()] atomically:YES];
    
    
    //更新本地用户信息
    [self.user updateSns_ID:[userInfo uid] PlateType:[userInfo type]];
    [self.user updateuserName:[userInfo nickname]];
    
    NSURL *portraitUrl = [NSURL URLWithString:[userInfo profileImage]];
    UIImage *protraitImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:portraitUrl]];
    [self.user updateUserHeaderImage:protraitImg];
    //刷新头像
    [self setTableHeaderView];
    
    [self.tableView reloadData];

}


#pragma mark - image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    //开辟新的画图区
    UIGraphicsBeginImageContext(targetSize); // this will crop
    //清0
    CGRect thumbnailRect = CGRectZero;
    //定义大小
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    //把源图画到指定位置和大小上
    [sourceImage drawInRect:thumbnailRect];
    //取画好的图
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


@end
