//
//  ImageFilterProcessViewController.m
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import "ImageFilterProcessViewController.h"
#import "ImageUtil.h"
#import "ColorMatrix.h"
#import "IphoneScreen.h"
@interface ImageFilterProcessViewController ()

@end

@implementation ImageFilterProcessViewController
@synthesize currentImage = currentImage, delegate = delegate, imagePickerData=imagePickerData;

//暂删
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

//优化：增加提示用户，减少一个阳光
- (IBAction)backView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)fitlerDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //[delegate imageFitlerProcessDone:rootImageView.image];
        
        
        NSDictionary* imageFilterData = [NSDictionary dictionaryWithObjectsAndKeys:rootImageView.image,CAMERA_IMAGE_KEY,
                                         [imagePickerData objectForKey:CAMERA_TIME_KEY], CAMERA_TIME_KEY,
                                         [imagePickerData objectForKey:CAMERA_SENTENCE_KEY], CAMERA_SENTENCE_KEY,
                                         nil];
        [delegate imageFitlerProcessDone:imageFilterData];

    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    
    currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    
//    UIImage *backgroundImage = [UIImage imageNamed:@"朦胧图副本.png"];
//    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    bgImageView.image = backgroundImage;
//    [self.view addSubview:bgImageView];
  
    UIImage *toolBarImage = [UIImage imageNamed:@"editePhoto_底图.png"];
    UIImageView *toolBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ScreenHeight-TOOL_BAR_HEIGHT, ScreenWidth, TOOL_BAR_HEIGHT)];
    toolBarImageView.image = toolBarImage;
    [self.view addSubview:toolBarImageView];
    
    //加重拍按钮
    NSInteger rePhotoBtnWidth = 20;
    NSInteger rePhotoBtnHeight = 20;
    UIButton *rePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rePhotoBtn setImage:[UIImage imageNamed:@"拍照-small.png"] forState:UIControlStateNormal];
    [rePhotoBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, TOOL_BAR_BTN_Y, rePhotoBtnWidth, rePhotoBtnHeight)];
    [rePhotoBtn addTarget:self action:@selector(reDoPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rePhotoBtn];
    
    //加分享按钮
    NSInteger shareBtnWidth = 20;
    NSInteger shareBtnHeight = 20;
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"editePhoto_分享.png"] forState:UIControlStateNormal];
    [shareBtn setFrame:CGRectMake(ScreenWidth/2-shareBtnWidth/2, TOOL_BAR_BTN_Y, shareBtnWidth, shareBtnHeight)];
    [shareBtn addTarget:self action:@selector(reDoPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    //加完成并返回按钮
    NSInteger leftBtnWidth = 20;
    NSInteger leftBtnHeight = 20;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"takePhoto_返回.png"] forState:UIControlStateNormal];
    [leftBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y, leftBtnWidth, leftBtnHeight)];
    [leftBtn addTarget:self action:@selector(fitlerDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    //加取消并反回按钮
    NSInteger rightBtnWidth = 20;
    NSInteger rightBtnHeight = 20;
    UIButton *rightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"takePhoto_返回.png"] forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-rightBtnWidth, NAVI_BAR_BTN_Y, rightBtnWidth, rightBtnHeight)];
    [rightBtn addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    //相片显示
    float imageWideth = 180;
    float imageHeight = imageWideth*960/640;
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.388 alpha:1.000]];
    rootImageView = [[UIImageView alloc ] initWithFrame:CGRectMake(ScreenWidth/2-imageWideth/2, 40, imageWideth, imageHeight)];
    rootImageView.image = currentImage;
    rootImageView.tag = TAG_EDITE_IMAGE_VIEW;
    [self.view addSubview:rootImageView];
    
    //时间框
    int timeImageHeight = 20;
    int timeImageWidth = 70;
    UIImage *timeImage = [UIImage imageNamed:@"时间框.png"];
    UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(rootImageView.frame.origin.x+imageWideth/2-60/2, rootImageView.frame.origin.y+imageHeight+5, timeImageWidth, timeImageHeight)];
    timeImageView.image = timeImage;
    [self.view addSubview:timeImageView];
    
    
    //太阳
    int sunMoonImageDiameter = 50;
    UIImage *sunMoonImage = [UIImage imageNamed:@"star.png"];
    UIImageView *sunMoonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(timeImageView.frame.origin.x-10, timeImageView.frame.origin.y+timeImageHeight/2-sunMoonImageDiameter/2, sunMoonImageDiameter, sunMoonImageDiameter)];
    sunMoonImageView.image = sunMoonImage;
    [self.view addSubview:sunMoonImageView];
    

    //时间值
    NSString* timeString = [imagePickerData objectForKey:CAMERA_TIME_KEY];
    int timelabelHeight = 20;
    int timelabelWidth = 80;
    UILabel *timelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+10, timeImageView.frame.origin.y, timelabelWidth,timelabelHeight)];
    [timelabel setBackgroundColor:[UIColor clearColor]];
    [timelabel setText:timeString];
    [timelabel setTextAlignment:NSTextAlignmentCenter];
    [timelabel setFont:[UIFont systemFontOfSize:10.0f]];
    [timelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:timelabel];
    
    
    //阳光值
    int valuelabelHeight = 20;
    int valuelabelWidth = 20;
    UILabel *valuelabel = [[UILabel alloc] initWithFrame:CGRectMake(sunMoonImageView.frame.origin.x+sunMoonImageView.frame.size.width/2-valuelabelWidth/2, sunMoonImageView.frame.origin.y+sunMoonImageView.frame.size.height/2-valuelabelHeight/2, valuelabelWidth,valuelabelHeight)];
    [valuelabel setBackgroundColor:[UIColor clearColor]];
    [valuelabel setText:@"+1"];
    [valuelabel setTextAlignment:NSTextAlignmentCenter];
    [valuelabel setFont:[UIFont systemFontOfSize:10.0f]];
    [valuelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:valuelabel];
    

    //语录
    NSString* sentence = [imagePickerData objectForKey:CAMERA_SENTENCE_KEY];
    int sentencelabelHeight = 20;
    int sentencelabelWidth = 70;
    UILabel *sentencelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+timeImageWidth/2-sentencelabelWidth/2, timeImageView.frame.origin.y+timeImageHeight+5, sentencelabelWidth, sentencelabelHeight)];
    [sentencelabel setBackgroundColor:[UIColor clearColor]];
    [sentencelabel setText:sentence];
    [sentencelabel setTextAlignment:NSTextAlignmentCenter];
    [sentencelabel setFont:[UIFont systemFontOfSize:13.0f]];
    [sentencelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:sentencelabel];

    //调色盘
    NSArray *arr = [NSArray arrayWithObjects:@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 120, 320, 80)];
    scrollerView.backgroundColor = [UIColor clearColor];
    scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    scrollerView.showsHorizontalScrollIndicator = NO;
    scrollerView.showsVerticalScrollIndicator = NO;//关闭纵向滚动条
    scrollerView.bounces = NO;
    

    
  
    //调色盘底色
//    UIImage *scrollerViewBkImage = [UIImage imageNamed:@"editePhoto_框.png"];
//    UIImageView *scrollerViewBkView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 110, 300, 40)];
//    scrollerViewBkView.image = scrollerViewBkImage;
//    [self.view addSubview:scrollerViewBkView];
    
    
    float x ;
    for(int i=0;i<14;i++)
    {
        x = 10 + 51*i;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        recognizer.delegate = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x-5, 53, 40, 23)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[arr objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setUserInteractionEnabled:YES];
        [label setTag:i];
        [label addGestureRecognizer:recognizer];
        
        [scrollerView addSubview:label];
       // [label release];
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, 30, 40)];
        [bgImageView setTag:i];
        [bgImageView addGestureRecognizer:recognizer];
        [bgImageView setUserInteractionEnabled:YES];
        UIImage *bgImage = [self changeImage:i imageView:nil];
        bgImageView.image = bgImage;
        [scrollerView addSubview:bgImageView];
        //[bgImageView release];
        
        //[recognizer release];

    }
    scrollerView.contentSize = CGSizeMake(x + 55, 80);
    [self.view addSubview:scrollerView];
    
    

}

- (IBAction)setImageStyle:(UITapGestureRecognizer *)sender
{
    UIImage *image =   [self changeImage:sender.view.tag imageView:nil];
    [rootImageView setImage:image];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)reDoPhoto:(id)sender {
    
    
    //调用自定义的图片处理控制器
    CustomImagePickerController* picker = [[CustomImagePickerController alloc] init];
    //判断是否有相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [picker setIsSingle:YES];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [picker setCustomDelegate:self];
    
    //调起pick处理器，及其view
    [picker setISunORMoon:[CommonObject checkSunOrMoonTime]];
    [self presentViewController:picker animated:YES completion:NULL];
    
}

//优化：更换图片后，刷新效果不好
- (void)cameraPhoto:(NSDictionary *) imagePickerDataReturn
{
    //currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    imagePickerData = imagePickerDataReturn;
    //[rootImageView setImage:currentImage];
    [self viewDidLoad];

}


-(UIImage *)changeImage:(int)index imageView:(UIImageView *)imageView
{
    UIImage *image;
    switch (index) {
        case 0:
        {
            return currentImage;
        }
            break;
        case 1:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_lomo];
        }
            break;
        case 2:
        {
           image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_heibai];
        }
            break;
        case 3:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_huajiu];
        }
            break;
        case 4:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_gete];
        }
            break;
        case 5:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_ruise];
        }
            break;
        case 6:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_danya];
        }
            break;
        case 7:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_qingning];
        }
            break;
        case 9:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_langman];
        }
            break;
        case 10:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_guangyun];
        }
            break;
        case 11:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_landiao];
            
        }
            break;
        case 12:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_menghuan];
        
        }
            break;
        case 13:
        {
            image = [ImageUtil imageWithImage:currentImage withColorMatrix:colormatrix_yese];
            
        }
    }
    return image;
}

@end
