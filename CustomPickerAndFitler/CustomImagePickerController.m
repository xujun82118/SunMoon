//
//  CustomImagePickerController.m
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import "CustomImagePickerController.h"
#import "IphoneScreen.h"
#import "UIImage+Cut.h"
//#import "ChooseStringViewController.h"

@interface CustomImagePickerController ()

@end

@implementation CustomImagePickerController

@synthesize customDelegate = _customDelegate, isSingle=_isSingle, iSunORMoon=iSunORMoon;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark get/show the UIView we want
- (UIView *)findView:(UIView *)aView withName:(NSString *)name {
	Class cl = [aView class];
	NSString *desc = [cl description];
	
	if ([name isEqualToString:desc])
		return aView;
	
	for (NSUInteger i = 0; i < [aView.subviews count]; i++) {
		UIView *subView = [aView.subviews objectAtIndex:i];
		subView = [self findView:subView withName:name];
		if (subView)
			return subView;
	}
	return nil;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    UIImage *backgroundImage = [UIImage imageNamed:@"bg_header.png"];
//    if (version >= 5.0) {
//        [navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
//    }
//    else{
//        [navigationController.navigationBar insertSubview:[[UIImageView alloc] initWithImage:backgroundImage] atIndex:1];
//    }
//    
    //获取单例用户数据
    self.user= [UserInfo  sharedSingleUserInfo];
    self.userData  = self.user.userDataBase;
    
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera){
   
        UIImage *deviceImage = [UIImage imageNamed:@"camera_button_switch_camera.png"];
        UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deviceBtn setBackgroundImage:deviceImage forState:UIControlStateNormal];
        [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [deviceBtn setFrame:CGRectMake(250, 30, deviceImage.size.width, deviceImage.size.height)];
        
        UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];
        [PLCameraView addSubview:deviceBtn];
        
        [self setShowsCameraControls:NO];
        
        
            
            
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(30, ScreenHeight-70-80, 280, 80)];
            
            //设置背景色
            //label1.backgroundColor = [UIColor grayColor];
           
            label1.tag = TAG_CAMERA_DECLEAR_LABEL;
            //设置标签文本
            NSString *preString = @"Say:\n";
        
        if(iSunORMoon == IS_SUN_TIME) {
            label1.text = self.user.current_sun_sentence;

        }else if (iSunORMoon == IS_MOON_TIME)
        {
            label1.text = self.user.current_moon_sentence;

        }
        
            //设置标签文本字体和字体大小
            label1.font = [UIFont fontWithName:@"Arial" size:20];
            label1.textColor = [UIColor whiteColor];
            
            //设置文本对其方式
            label1.textAlignment = UITextAlignmentCenter;
            //设置字体大小适应label宽度
            label1.adjustsFontSizeToFitWidth = YES;
            label1.numberOfLines = 4;
            /*
            UIImage *labelbgimage = [UIImage imageNamed:@"declare-bg.png"];
            UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, ScreenHeight-70-80, 280, 80)];
            bgImageView.image = labelbgimage;
            //[PLCameraView addSubview:bgImageView];
            */
            
            UITapGestureRecognizer *recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSentencePicker:)];
            
            recognizer1.numberOfTouchesRequired = 1;
            recognizer1.numberOfTapsRequired = 1;
            recognizer1.delegate = self;
            [label1 setUserInteractionEnabled:YES];
            [label1 addGestureRecognizer:recognizer1];
            [PLCameraView addSubview:label1];
        
    
        UIView *overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 70, 320, 44)];
        [overlyView setBackgroundColor:[UIColor clearColor]];
        
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backImage = [UIImage imageNamed:@"takePhoto_0004_返回.png"];
        [backBtn setImage: backImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setFrame:CGRectMake(8, 5, backImage.size.width, backImage.size.height)];
        [overlyView addSubview:backBtn];
        
        UIImage *camerImage = [UIImage imageNamed:@"拍照.png"];
        UIButton *cameraBtn = [[UIButton alloc] initWithFrame:
                               CGRectMake(/*110*/320/2-camerImage.size.width/2, 5, camerImage.size.width, camerImage.size.height)];
        [cameraBtn setImage:camerImage forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        [overlyView addSubview:cameraBtn];
        
        
        UIImage *photoImage = [UIImage imageNamed:@"takePhoto_0003_相册.png"];
        UIButton *photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 70, 40)];
        [photoBtn setImage:photoImage forState:UIControlStateNormal];
        [photoBtn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        [overlyView addSubview:photoBtn];
         
        self.cameraOverlayView = overlyView;
    }
}


- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
	// Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    //[super dealloc];
}


#pragma mark - 选择今天的宣言语录
- (IBAction)chooseSentencePicker:(UITapGestureRecognizer *)sender
{
   
    if (defaultPickerView == nil) {
        defaultPickerView = [[AFPickerView alloc] initWithFrame:CGRectMake(0,ScreenHeight-216,320,216) backgroundImage:@"PickerBG.png" shadowImage:@"PickerShadow.png" glassImage:@"pickerGlass.png" title:@"选择宣言"];
        defaultPickerView.dataSource = self;
        defaultPickerView.delegate = self;
        defaultPickerView.rowFont = [UIFont fontWithName:@"Arial" size:20];
        [self.view addSubview:defaultPickerView];
    }
    [defaultPickerView showPicker];
    [defaultPickerView reloadData];
    
    if(iSunORMoon == IS_SUN_TIME) {
        defaultPickerView.selectedRow = self.user.sunSentenceSelect;
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        defaultPickerView.selectedRow = self.user.moonSentenceSelect;

    }
    
    
}


#pragma mark - ButtonAction Methods

- (IBAction)swapFrontAndBackCameras:(id)sender {
    if (self.cameraDevice ==UIImagePickerControllerCameraDeviceFront ) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }else {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}


- (void)closeView
{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)takePicture
{

    [super takePicture];
}

- (void)showPhoto
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image clipImageWithScaleWithsize:CGSizeMake(320, 480)] ;
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        //[_customDelegate cameraPhoto:image];
        
        NSDictionary *imageData = [NSDictionary dictionaryWithObjectsAndKeys:
                                   image,CAMERA_IMAGE_KEY,
                                   @"time_string", CAMERA_TIME_KEY,
                                   @"语录。。。", CAMERA_SENTENCE_KEY,
                                   nil];
        
        [_customDelegate cameraPhoto:imageData];

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if(_isSingle){
        //[picker dismissModalViewControllerAnimated:YES];
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }else{
        if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            //[picker dismissModalViewControllerAnimated:YES];
            [picker dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}



#pragma mark - AFPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(AFPickerView *)pickerView {
    
    NSInteger count = 0;
    if(iSunORMoon == IS_SUN_TIME) {
        count = [self.user.sunDataSourceArray count];
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        count = [self.user.moonDataSourceArray count];
        
    }
    
    return count;
}


- (NSString *)pickerView:(AFPickerView *)pickerView titleForRow:(NSInteger)row {

    
    NSString *now = nil;
    if(iSunORMoon == IS_SUN_TIME) {
        now = self.user.current_sun_sentence;
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        now = self.user.current_moon_sentence;
        
    }
    
    return now;
}


#pragma mark - AFPickerViewDelegate

- (void)pickerView:(AFPickerView *)pickerView didSelectRow:(NSInteger)row {


    
    
    UIView *PLCameraView=[self findView:self.view
                               withName:@"PLCameraView"];
    
    UILabel *label = (UILabel*)[PLCameraView viewWithTag:TAG_CAMERA_DECLEAR_LABEL];
    
    NSString *preString = @"Say:\n";
    
    
    if(iSunORMoon == IS_SUN_TIME) {
        [self.user updateSunSentenceSelected:row];
        
        label.text = self.user.current_sun_sentence;
        
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        [self.user updateMoonSentenceSelected:row];
        label.text = self.user.current_moon_sentence;

        
    }
    
}
@end
