//
//  MainSunMoonViewController.m
//  SunMoon
//
//  Created by songwei on 14-3-30.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "MainSunMoonViewController.h"
#import "EAIntroView.h"
#import "NavBar.h"
#import "UserSetViewController.h"
#import "HomeInsideViewController.h"
#import "TakePhotoViewController.h"
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomImagePickerController.h"
#import "ImageFilterProcessViewController.h"
#import "ImageFilterViewController.h"

@interface MainSunMoonViewController ()

@end

@implementation MainSunMoonViewController

@synthesize mainBgImage,user,userDB,userHeaderImageView = userHeaderImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //起动引导界面
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isHaveOpen = [defaults boolForKey:FIRST_START_OPEN_GUID];
    if (isHaveOpen == NO || isOpenGuid) {
        
        [self showIntroWithCrossDissolve];
        [defaults setBool:YES forKey:FIRST_START_OPEN_GUID];
        [defaults synchronize];
    }
    
    //获取用户账号
    self.user= [UserInfo  sharedSingleUserInfo];
    
    //第一次起动，使用默认用户
    if (isHaveOpen == NO)
    {
        self.user = [self.user initDefaultInfoAtFirstOpenwithTime:[CommonObject getCurrentTime]];
        
    }else
    {
        self.user = [self.user getUserInfoAtNormalOpen];
    }

    //获取同一个数据库，注：userDB不能放到userInfo中，会发生错误，原因不明
    userDB = [[UserDB alloc] init];
    [userDB createDataBase];

    self.userCloud = [[UserInfoCloud alloc] init];
    self.userCloud.userInfoCloudDelegate = self;
    
    //加载头像
    self.userHeaderImageView.image = self.user.userHeaderImage;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBarHidden = YES;
    //self.navigationController.navigationBar.backgroundColor = [UIColor yellowColor];
//    self.navigationController.navigationBar.alpha = 0.1;
//    self.navigationController.navigationBar.opaque = YES;
//    self.navigationController.toolbarHidden = YES;
    //[self.navigationItem setNewTitle:@"测试"];
    


}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"userSet"]) {
        // for iPhone, our segue will push the TextViewController, so configure it here in preparation for that push
        UserSetViewController *destinationVC = (UserSetViewController *)segue.destinationViewController;
        destinationVC.title = @"119";
        //destinationVC.navigationItem.title = @"438";
        //destinationVC.navigationController.navigationBarHidden = NO;

    }

}



- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    //page1.title = @"";
    //page1.desc = @"";
    //page1.bgImage = [UIImage imageNamed:@"intro-1"];
    page1.titleImage = [UIImage imageNamed:@"Guid-start"];
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}



#pragma mark  ------测试-------
- (IBAction)testNet:(id)sender {
    
    [_userCloud updateUserImage:Nil];
    
    
    /*
    UserInfo * user = [UserInfo new];
    user.name = @"xujun";
    user.user_id = @"001";
    user.sns_id = @"12345";
    user.sun_value = @"11";
    //user.sun_image = UIImagePNGRepresentation(image);
    
    [_userDB saveUser:user];
    
    //test 取数据
    _userData = [NSMutableArray arrayWithArray:[_userDB findWithUid:nil limit:10000]];
    
    
    
//    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* _name = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@",@"UserSunMoonDB.sqlite"]];
//    NSLog(@"*****%@", _name);
//    
//    NSLog(@"-----***%@", [_userDB getDBPath]);
    
    
    
    //云上传数据
    if ([_userCloud upateUserInfo:user]) {
        
        NSLog(@"Update cloud userinfo succeed!");
        
    }else
    {
        NSLog(@"Update cloud userinfo failed!");
        
    }
    
    
    [_userCloud getUserInfoBySnsId:user.sns_id userName:user.name];
    
    */
}

#pragma mark 测试存用户数据
-(void) saveUserImage:(UIImage*)image  withTime: (NSString*) dateTime
{
    
    user.date_time = dateTime;
    user.sun_value = @"11";
    user.sun_image_name = @"imagename";
    user.sun_image_sentence = @"xxxx"; //xuj:待定
    user.sun_image =UIImagePNGRepresentation(image);
    
    user.moon_value = @"11";
    user.moon_image_name = @"imagename";
    user.moon_image_sentence = @"xxxx";//xuj:待定
    user.moon_image =UIImagePNGRepresentation(image);
    
    [userDB saveUser:user];
    
    
}

-(void) saveUserData:(NSDictionary*)imageData
{
    
    if ([CommonObject checkSunOrMoonTime]== IS_SUN_TIME) {
        user.date_time = [imageData objectForKey:CAMERA_TIME_KEY];
        user.sun_value = @"11";
        user.sun_image = UIImagePNGRepresentation([imageData objectForKey:CAMERA_IMAGE_KEY]);
        user.sun_image_sentence = [imageData objectForKey:CAMERA_SENTENCE_KEY];
        user.sun_image_name = [imageData objectForKey:CAMERA_TIME_KEY];
    }else if ([CommonObject checkSunOrMoonTime] == IS_MOON_TIME)
    {
        user.date_time = [imageData objectForKey:CAMERA_TIME_KEY];
        user.moon_value = @"11";
        user.moon_image = UIImagePNGRepresentation([imageData objectForKey:CAMERA_IMAGE_KEY]);
        user.moon_image_sentence = [imageData objectForKey:CAMERA_SENTENCE_KEY];
        user.moon_image_name = [imageData objectForKey:CAMERA_TIME_KEY];
        
    }
    

    
    [userDB saveUser:user];
    
    
}


#pragma mark - UserInfoCloudDelegate
- (void) getUserInfoFinishReturn:(UserInfo*) userInfo
{
    
    NSLog(@"userinfo --%@", userInfo.user_id);
    
    
}


- (IBAction)doCamera:(id)sender {
    
    CustomImagePickerController *controller = [[CustomImagePickerController alloc] init];
    
    // 拍照
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos])
    {

        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([self isFrontCameraAvailable])
        {
            controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;

    }
    else
    {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            [controller setIsSingle:YES];
        }
    }
    
    
    //指向他的委托函数
    [controller setCustomDelegate:self];
    [controller setISunORMoon:[CommonObject checkSunOrMoonTime]];
    [self presentViewController:controller
                       animated:YES
                     completion:^(void){
                         NSLog(@"Picker View Controller is presented");
                     }];
    
    
    
}

#pragma mark - customimagePicker delegate
- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn
{
    
    ImageFilterProcessViewController*  fitler = [[ImageFilterProcessViewController alloc] init];

    [fitler setDelegate:self];
    [fitler setISunORMoon:[CommonObject checkSunOrMoonTime]];
    fitler.imagePickerData = imagePickerDataReturn;
    [self presentViewController:fitler animated:YES completion:NULL];
    

    
}

- (void)cancelCamera
{
    
    
}

#pragma mark - imagefilter delegate
#pragma mark 照完象， 存用户据
- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData
{
    //存图片到数据库
    
    //获取时间
    NSString* imageTime = [CommonObject getCurrentDate];
    NSLog(@"--image time =%@",  imageTime);
    

    [self saveUserData:imageFilterData];
    
    NSLog(@"---path=%@", [userDB getDBPath]);
    
    UserInfo* userer=[userDB getUserImageByDateTime:imageTime];
    
}



#pragma mark - userHeaderImageView getter
- (UIImageView *)userHeaderImageView {

        [userHeaderImageView setFrame:CGRectMake(userHeaderImageView.frame.origin.x, userHeaderImageView.frame.origin.y, userHeaderImageView.frame.size.width, userHeaderImageView.frame.size.height)];
        [userHeaderImageView.layer setCornerRadius:(userHeaderImageView.frame.size.height/2)];
        userHeaderImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [userHeaderImageView.layer setMasksToBounds:YES];
        [userHeaderImageView setContentMode:UIViewContentModeScaleAspectFill];
        [userHeaderImageView setClipsToBounds:YES];
        userHeaderImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        userHeaderImageView.layer.shadowOffset = CGSizeMake(4, 4);
        userHeaderImageView.layer.shadowOpacity = 0.5;
        userHeaderImageView.layer.shadowRadius = 2.0;
        userHeaderImageView.layer.borderColor = [[UIColor redColor] CGColor];
        userHeaderImageView.layer.borderWidth = 2.0f;
        userHeaderImageView.layer.cornerRadius =30.0;
        userHeaderImageView.userInteractionEnabled = YES;
        userHeaderImageView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getIntoHome)];
        [userHeaderImageView addGestureRecognizer:portraitTap];

    
    return userHeaderImageView;
}

#pragma mark - 用户头像函数
-(void)getIntoHome
{
    if (self.user.userType == USER_TYPE_NEW || self.user.userType == USER_TYPE_NEED_CARE) {
        [self.user updateUserType:USER_TYPE_TYE];
        [self editUserHeader];
    }else
    {
        //进入小屋
        [self performSegueWithIdentifier:@"getintoHome" sender:self];
   
    }
    
    
}

//弹出选择编辑按钮
- (void)editUserHeader {
    
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"下次再说"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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


#pragma mark - UIImagePickerControllerDelegate
//相机或相册的回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
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
    self.userHeaderImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        [self.user updateUserHeaderImage:editedImage];
        [self.user updateUserType:USER_TYPE_TYE];

    
    }];
}
//实现委托函数
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
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


#pragma mark - 测试数据

- (IBAction)reCreatDataBase:(id)sender
{
    [userDB deleteDataBaseFile];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[userDB getDBPath]];
    NSLog(@"db path=%@", [userDB getDBPath]);
    if(exist)
    {
        NSLog(@"删除数据库文件失败！！");
    }else{
        NSLog(@"删除数据库文件成功！");
        
    }
    
    userDB = [[UserDB alloc] init];
    [userDB createDataBase];

}

- (IBAction)deleteDataBase:(id)sender {
    
    [userDB deleteDataBaseFile];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:[userDB getDBPath]];
    NSLog(@"db path=%@", [userDB getDBPath]);
    if(exist)
    {
        NSLog(@"删除数据库文件失败！！");
    }else{
        NSLog(@"删除数据库文件成功！");
        
    }
    
    
    
}

@end
