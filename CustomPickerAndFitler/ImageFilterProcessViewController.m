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
#import "ShareByShareSDR.h"
#import "CustomAlertView.h"
#import "GuidController.h"


@interface ImageFilterProcessViewController ()

{
    UIImageView *rootImageView;

    UIImage *editImageOld;
    UIImageView* editImageOldView;
    NSString* editOldSentence;
    UIImage *sunMoonImage;
    UIImageView *sunMoonImageView;
    NSString* timeString;
    UILabel *valuelabel;
    UIImage* bgImageScroll;
    UIImageView *bgImageViewScroll;
    UILabel *timelabel;
    UILabel *sentencelabel;
    UIImageView* sunMoonImageViewTop;
    UIImageView* bowLightView;
    
    NSInteger finalGiveLightCout;
    
    AminationCustom* addVauleAnimation;
    
    CustomAlertView* customAlertAutoDis;
    CustomAlertView* customAlertAutoDisYes;
    MONActivityIndicatorView *indicatorView;


}

@end

@implementation ImageFilterProcessViewController
@synthesize userInfo=userInfo,currentImage = currentImage,currentSentence=currentSentence, delegate = delegate, imagePickerData=imagePickerData,iSunORMoon=iSunORMoon;

//暂删
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    addVauleAnimation = [[AminationCustom alloc] initWithKey:@"addValueinEdite"];
    addVauleAnimation.aminationCustomDelegate =  self;
    
    //获取单例用户数据
    //self.userInfo= [UserInfo  sharedSingleUserInfo];
    
    //初始化指示器
    indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 4;
    indicatorView.radius = SCREEN_WIDTH/50;
    indicatorView.internalSpacing = 4;
    indicatorView.center = self.view.center;
    [self.view addSubview:indicatorView];
    

    
    currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    
    UIImage *bkImage = [UIImage imageNamed:@"编辑背景图V1.png"];
    UIImageView *bkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bkImageView.image = bkImage;
    bkImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bkImageView];
    
    //工具条
    UIImage *toolBarImage = [UIImage imageNamed:@"下部底图-黄.png"];
    //UIImageView *toolBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ScreenHeight-TOOL_BAR_HEIGHT, ScreenWidth, TOOL_BAR_HEIGHT)];
    NSInteger toolHeight;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        toolHeight = 60;
    }else
    {
        toolHeight = 40;
    }
    UIImageView *toolBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-toolHeight, SCREEN_WIDTH, toolHeight)];
    toolBarImageView.image = toolBarImage;
    [self.view addSubview:toolBarImageView];
    
    //加重拍按钮
    NSInteger rePhotoBtnWidth;
    NSInteger rePhotoBtnHeight;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        rePhotoBtnWidth = 35+20;
        rePhotoBtnHeight = 30+20;
    }else
    {
        rePhotoBtnWidth = 25+20;
        rePhotoBtnHeight = 20+20;
    }
    UIButton *rePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rePhotoBtn setImage:[UIImage imageNamed:@"camera-yellow.png"] forState:UIControlStateNormal];
    [rePhotoBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, toolBarImageView.center.y-rePhotoBtnHeight/2, rePhotoBtnWidth, rePhotoBtnHeight)];
    [rePhotoBtn addTarget:self action:@selector(reDoPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rePhotoBtn];
    
    //加分享按钮
    NSInteger shareBtnWidth = 25;
    NSInteger shareBtnHeight = 25;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        shareBtnWidth = 35;
        shareBtnHeight = 35;
    }else
    {
        shareBtnWidth = 25;
        shareBtnHeight = 25;
    }
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"分享-黄.png"] forState:UIControlStateNormal];
    [shareBtn setFrame:CGRectMake(ScreenWidth/2-shareBtnWidth/2, toolBarImageView.center.y-shareBtnHeight/2, shareBtnWidth, shareBtnHeight)];
    [shareBtn addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    
    //加保存到相册按钮
    NSInteger saveBtnWidth = 20;
    NSInteger saveBtnHeight = 20;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        saveBtnWidth = 35;
        saveBtnHeight = 35;
    }else
    {
        saveBtnWidth = 20;
        saveBtnHeight = 20;
    }
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    [saveBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X- saveBtnWidth, toolBarImageView.center.y-saveBtnHeight/2, saveBtnWidth, saveBtnHeight)];
    [saveBtn addTarget:self action:@selector(savetoAlbumHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    //设置只保存一次
    isHaveSavePhoto = NO;
    
    
    //加OK返回按钮
    NSInteger okBtnWidth = 20;
    NSInteger okBtnHeight = 20;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        okBtnWidth = 35;
        okBtnHeight = 35;
    }else
    {
        okBtnWidth = 20;
        okBtnHeight = 20;
    }
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    [okBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y, okBtnWidth, okBtnHeight)];
    [okBtn addTarget:self action:@selector(fitlerDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    //加丢弃并返回按钮
    NSInteger rightBtnWidth = 20;
    NSInteger rightBtnHeight = 20;
    if ([CommonObject CheckDeviceTypeVersion]==iphone6Pluse) {
        rightBtnWidth = 35;
        rightBtnHeight = 35;
    }else
    {
        okBtnWidth = 20;
        okBtnHeight = 20;
    }
    UIButton *rightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"丢弃.png"] forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-rightBtnWidth, NAVI_BAR_BTN_Y, rightBtnWidth, rightBtnHeight)];
    [rightBtn addTarget:self action:@selector(abandonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    //相片显示
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.388 alpha:1.000]];
    NSInteger y = 60;
    float imageWideth ;
    if ([CommonObject CheckDeviceTypeVersion] == iphone4_4s) {
        imageWideth = SCREEN_WIDTH/2+20;
    }else if ([CommonObject CheckDeviceTypeVersion] == iphone5_5s)
    {
        imageWideth = SCREEN_WIDTH/4*3-20;

    }else if([CommonObject CheckDeviceTypeVersion] == iphone6)
    {
        imageWideth = SCREEN_WIDTH/4*3;

    }else
    {
        imageWideth = SCREEN_WIDTH/4*3;
        y = 70;

    }
    
    
    float imageHeight = imageWideth*960/640;

    rootImageView = [[UIImageView alloc ] initWithFrame:CGRectMake(ScreenWidth/2-imageWideth/2, y, imageWideth, imageHeight)];
    rootImageView.image = currentImage;
    rootImageView.tag = TAG_EDITE_IMAGE_VIEW;
    [self.view addSubview:rootImageView];
    
    //取原相片
    editImageOld = Nil;
    if(iSunORMoon == IS_SUN_TIME) {
        editImageOld = [UIImage imageWithData:self.userInfo.sun_image];
        editOldSentence = self.userInfo.sun_image_sentence;
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        editImageOld = [UIImage imageWithData:self.userInfo.moon_image];
        editOldSentence = self.userInfo.moon_image_sentence;
    }
    
    float editImageOldWideth = 30;
    float editImageOldHeight = editImageOldWideth*960/640;
    editImageOldView = [[UIImageView alloc ] initWithFrame:CGRectMake(rootImageView.frame.origin.x-editImageOldWideth-10, rootImageView.frame.origin.y+rootImageView.frame.size.height-editImageOldHeight, editImageOldWideth, editImageOldHeight)];
    editImageOldView.image = editImageOld;
    editImageOldView.tag = TAG_EDIT_OLD_IMAGE_VIEW;
    editImageOldView.alpha = 1.0;
    [editImageOldView setUserInteractionEnabled:YES];
    [self.view addSubview:editImageOldView];
    
    //原相片增中触发
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseOldImage:)];
    recognizer.numberOfTouchesRequired = 1;
    recognizer.numberOfTapsRequired = 1;
    //recognizer.delegate = self;
    [editImageOldView addGestureRecognizer:recognizer];

    //时间框
    int timeImageHeight = 25;
    int timeImageWidth = 85;
    UIImage *timeImage = [UIImage imageNamed:@"时间框.png"];
    UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(rootImageView.frame.origin.x+imageWideth/2-timeImageWidth/2, rootImageView.frame.origin.y+imageHeight+5, timeImageWidth, timeImageHeight)];
    timeImageView.image = timeImage;
    [self.view addSubview:timeImageView];
    
    
    //日月
    int sunMoonImageDiameter = 60;
    sunMoonImage = [CommonObject getBaseLightImageByTime];
    sunMoonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(timeImageView.frame.origin.x-30, timeImageView.frame.origin.y+timeImageHeight/2-sunMoonImageDiameter/2, sunMoonImageDiameter, sunMoonImageDiameter)];
    sunMoonImageView.image = sunMoonImage;
    [self.view addSubview:sunMoonImageView];
    

    //时间值
    NSString* tempTime =[imagePickerData objectForKey:CAMERA_TIME_KEY];
    tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
    timeString = [tempTime stringByAppendingString:@"日"];
    int timelabelHeight = 20;
    int timelabelWidth = 100;
    timelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+5, timeImageView.center.y-timelabelHeight/2, timelabelWidth,timelabelHeight)];
    [timelabel setBackgroundColor:[UIColor clearColor]];
    [timelabel setText:timeString];
    [timelabel setTextAlignment:NSTextAlignmentCenter];
    [timelabel setFont:[UIFont systemFontOfSize:12.0f]];
    [timelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:timelabel];
    
    
    //阳光值
    int valuelabelHeight = 20;
    int valuelabelWidth = 20;
    if (!valuelabel) {
    valuelabel = [[UILabel alloc] initWithFrame:CGRectMake(sunMoonImageView.frame.origin.x+sunMoonImageView.frame.size.width/2-valuelabelWidth/2, sunMoonImageView.frame.origin.y+sunMoonImageView.frame.size.height/2-valuelabelHeight/2, valuelabelWidth,valuelabelHeight)];
    }

    [valuelabel setBackgroundColor:[UIColor clearColor]];
    [valuelabel setTextAlignment:NSTextAlignmentCenter];
    [valuelabel setFont:[UIFont systemFontOfSize:10.0f]];
    [valuelabel setTextColor:[UIColor blackColor]];
    //valuelabel.hidden = YES;
    [self.view addSubview:valuelabel];

    if (![valuelabel.text isEqualToString:@"+1"]) {
        [valuelabel setText:@""];
    }else
    {
        //为“+1”时，是重拍返回的，保持原来状态
        NSLog(@"是重拍返回的");
    }

    

    //语录
    currentSentence = [imagePickerData objectForKey:CAMERA_SENTENCE_KEY];
    int sentencelabelHeight = 40;
    int sentencelabelWidth = 200;
    sentencelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+timeImageWidth/2-sentencelabelWidth/2, timeImageView.frame.origin.y+timeImageHeight+5, sentencelabelWidth, sentencelabelHeight)];
    [sentencelabel setBackgroundColor:[UIColor clearColor]];
    [sentencelabel setText:currentSentence];
    [sentencelabel setTextAlignment:NSTextAlignmentCenter];
    [sentencelabel setFont:[UIFont systemFontOfSize:13.0f]];
    [sentencelabel setNumberOfLines:2];
    [sentencelabel setTextColor:[UIColor blackColor]];
    //[self.view addSubview:sentencelabel];
    

    //调色盘
    NSInteger scrollWidth = SCREEN_WIDTH;
    NSInteger scrollHeight;
    if ([CommonObject CheckDeviceTypeVersion] == iphone4_4s) {
        scrollHeight = 90;
    }else if ([CommonObject CheckDeviceTypeVersion] == iphone5_5s)
    {
        scrollHeight = 90;
    }else
    {
        scrollHeight = 100;
    }


    NSArray *arr = [NSArray arrayWithObjects:@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, valuelabel.frame.origin.y+valuelabelHeight+10, scrollWidth, scrollHeight)];
    scrollerView.tag = TAG_EDITE_PHOTO_SCROLL_VIEW;
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
    
    //调色盘
    float x ;
    for(int i=0;i<14;i++)
    {
        x = 10 + 51*i;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageStyle:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        NSInteger labelWidth;
        NSInteger labellHeight;
        NSInteger bgImageWidth;
        NSInteger bgImageHeight;
        
        if (SCREEN_HEIGHT>480) {
            labelWidth = 50;
            labellHeight = 34;
            
            bgImageWidth = 40;
            bgImageHeight = 55;
        }else
        {
            labelWidth = 40;
            labellHeight = 23;
            
            bgImageWidth = 30;
            bgImageHeight = 40;
        }
        

        
        bgImageViewScroll = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, bgImageWidth, bgImageHeight)];
        bgImageViewScroll.tag = i;
        [bgImageViewScroll addGestureRecognizer:recognizer];
        [bgImageViewScroll setUserInteractionEnabled:YES];
        bgImageScroll = [self changeImage:i imageView:nil];
        bgImageViewScroll.image = bgImageScroll;
        [scrollerView addSubview:bgImageViewScroll];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x-5, bgImageViewScroll.frame.origin.y+bgImageHeight+3, labelWidth, labellHeight)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[arr objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setUserInteractionEnabled:YES];
        [label setTag:TAG_EDITE_PHOTO_SCROLL_LABEL+i];
        //[label addGestureRecognizer:recognizer];
        [scrollerView addSubview:label];
        

    }
    scrollerView.contentSize = CGSizeMake(x + 55, 80);
    [self.view addSubview:scrollerView];
    
    
    //日月最上方的
    UIImage *sunMoonImageTop;
    sunMoonImageTop = [CommonObject getSunOrMooonImageByTime];
    NSInteger sunMoonImageTopWidth = 200;
    NSInteger sunMoonImageTopHeigth =200;
    sunMoonImageViewTop = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - sunMoonImageTopWidth/2, -140, sunMoonImageTopWidth, sunMoonImageTopHeigth)];
    sunMoonImageViewTop.image = sunMoonImageTop;
    UITapGestureRecognizer *recognizerSunMoon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapSunMoonInTakePhotoHandler:)];
    recognizerSunMoon.numberOfTouchesRequired = 1;
    recognizerSunMoon.numberOfTapsRequired = 1;
    //recognizerSunMoon.delegate = self;
    [sunMoonImageViewTop setUserInteractionEnabled:YES];
    [sunMoonImageViewTop addGestureRecognizer:recognizerSunMoon];
    [self.view addSubview:sunMoonImageViewTop];
    
    //日月闪烁
    NSMutableArray *iArr=[NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<3; i++) {
        
        NSString *name=[NSString stringWithFormat:@"headerFrameBow_%d",i];
        UIImage *image=[UIImage imageNamed:name];
        
        [iArr addObject:image];
        
    }
    
    NSInteger IntervalWidth = LIGHT_ANIMATION_INTERVAL;// 光环向头像外扩的宽度
    NSInteger lightBowSkySunMoonViewWidth = sunMoonImageViewTop.frame.size.width+IntervalWidth*2;
    NSInteger lightBowSkySunMoonViewHeigth = sunMoonImageViewTop.frame.size.height+IntervalWidth*2;
    
    bowLightView = [[UIImageView alloc] initWithFrame:CGRectMake(sunMoonImageViewTop.center.x-lightBowSkySunMoonViewWidth/2, sunMoonImageViewTop.center.y-lightBowSkySunMoonViewWidth/2, lightBowSkySunMoonViewWidth, lightBowSkySunMoonViewHeigth)];
    bowLightView.image=[UIImage imageNamed:@"空白图"];
    bowLightView.userInteractionEnabled=YES;
    bowLightView.contentMode=UIViewContentModeScaleToFill;
    bowLightView.animationImages=iArr;
    bowLightView.animationDuration=1;
    bowLightView.animationRepeatCount = 1;
    bowLightView.hidden = NO;
    [self.view addSubview:bowLightView];
    [self.view bringSubviewToFront:sunMoonImageViewTop];


}

- (void)TapSunMoonInTakePhotoHandler:(UITapGestureRecognizer*) gesture
{
    NSLog(@"Tap SunMoon in editePhoto UI");
    bowLightView.hidden = NO;
    [bowLightView startAnimating];
    
    
}


-(void)savetoAlbumHandle:(UIButton*)sender
{
    
    if (isHaveSavePhoto) {
        [self showCustomDelayAlertBottom:@"请不要重复保存"];
    }else
    {
        NSLog(@"保存到相册");
        //相片加水印
        UIImage* waterTemp =[self ShareImageWitheWater:rootImageView.image];
        
        
        UIImageWriteToSavedPhotosAlbum(waterTemp, nil, nil,nil);
        isHaveSavePhoto = YES;
        [self showCustomDelayAlertBottom:@"成功保存到相册"];

    }
    
    
    
}


//增加水印
-(UIImage*) ShareImageWitheWater:(UIImage*) srcImage
{
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareImage =srcImage;
    if (iSunORMoon ==  IS_SUN_TIME) {
        share.waterImage = [UIImage imageNamed:@"water-sun.png"];
        share.lightCount = self.userInfo.sun_value;

    }else
    {
        share.waterImage = [UIImage imageNamed:@"water-moon.png"];
        share.lightCount = self.userInfo.moon_value;

    }
    share.timeString = timeString;
    share.senttence = currentSentence;
    
    //计算水印位置
    CGFloat w = srcImage.size.width;
    CGFloat h = srcImage.size.width*(share.waterImage.size.height/share.waterImage.size.width);
    CGFloat x = 0;
    CGFloat y = srcImage.size.height-h;
    share.waterRect = CGRectMake(x,y,w,h);
    [share addWater];
    
//    //计算水印日期位置
//    CGFloat w1 = 30;
//    CGFloat h1 = 30;
//    CGFloat x1 = 40;
//    CGFloat y1 = share.shareImage.size.height -20 -h1/2;
//    share.textRect = CGRectMake(x1,y1,w1,h1);
//    [share addTimeText:@"timeImage-长.png"];
//    
//    //计算水印光个数的位置
//    CGFloat w2 = 30;
//    CGFloat h2 = 30;
//    CGFloat x2 = 25;
//    CGFloat y2 = y+30;
//    share.textRect = CGRectMake(x2,y2,w2,h2);
//    [share addLightCounText];
//    
//    //计算水印语录的位置
//    CGFloat w3 = (share.shareImage.size.width);
//    CGFloat h3 = 30;
//    CGFloat x3 = (share.shareImage.size.width)/2-w3/2;
//    CGFloat y3 = share.shareImage.size.height -25 -h3/2;
//    share.textRect = CGRectMake(x3,y3,w3,h3);
//    [share addSentenceText];
    
    
    //计算水印日期位置
    CGFloat w1 = 70;
    CGFloat h1 = 70*45/172;
    CGFloat x1 = share.shareImage.size.width/2-w1/2;
    CGFloat y1 = share.shareImage.size.height-15-h1/2;
    share.textRect = CGRectMake(x1,y1,w1,h1);
    [share addTimeText:@"timeImage-长.png"];
    
    //计算水印光个数的位置
    CGFloat w2 = 30;
    CGFloat h2 = 30;
    CGFloat x2 = share.shareImage.size.width/2-w2/2;
    CGFloat y2 = y+30;
    share.textRect = CGRectMake(x2,y2,w2,h2);
    [share addLightCounText];
    
    //计算水印语录的位置
    CGFloat w3 = (share.shareImage.size.width)/3*2;
    CGFloat h3 = 30;
    CGFloat x3 = (share.shareImage.size.width)/2-w3/2;
    CGFloat y3 = share.shareImage.size.height -40 -h3/2;
    share.textRect = CGRectMake(x3,y3,w3,h3);
    [share addSentenceText];
    
    return share.shareImage;
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    sunMoonImageViewTop.hidden = YES;

    
}

-(void) reFreshcelement
{
    //现有相片
    currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    rootImageView.image = currentImage;
    
    //取原相片
    editImageOld = Nil;
    if(iSunORMoon == IS_SUN_TIME) {
        editImageOld = [UIImage imageWithData:self.userInfo.sun_image];
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        editImageOld = [UIImage imageWithData:self.userInfo.moon_image];
    }
    editImageOldView.image =editImageOld;
    
    //时间值
    NSString* tempTime =[imagePickerData objectForKey:CAMERA_TIME_KEY];
    tempTime = [tempTime stringByReplacingOccurrencesOfString:@"." withString:@"月"];
    timeString = [tempTime stringByAppendingString:@"日"];
    [timelabel setText:timeString];
    
    
    //语录
    currentSentence = [imagePickerData objectForKey:CAMERA_SENTENCE_KEY];
    [sentencelabel setText:currentSentence];

    //调色盘
    for(int i=0;i<14;i++)
    {
        //UIImageView * scrollView = (UIImageView*)[self.view viewWithTag:(TAG_EDITE_PHOTO_SCROLL_VIEW)];
        UIImageView *scrollImageView= (UIImageView*)[scrollerView viewWithTag:(i)];
        bgImageScroll = [self changeImage:i imageView:nil];
        scrollImageView.image = bgImageScroll;
        
    }

    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    finalGiveLightCout = [self checkFinalWetherAndGiveLight];
    
    
}


// 最终确认是否增加光，返回光数
-(NSInteger) checkFinalWetherAndGiveLight
{
    
    NSInteger count = [[imagePickerData objectForKey:CAMERA_LIGHT_COUNT] integerValue];
    if (count==0) {
        NSLog(@" 获得的光的个数为0,从相册来，返回");
        return 0;
    }
    
    if ([self.userInfo checkIsHaveAddSunOrMoonValueForTodayPhoto]) {
        NSLog(@" 已奖励过光，返回");

        [self showCustomDelayAlertBottom:[NSString stringWithFormat:(@"今天的%@光已经摘走了"),([CommonObject checkSunOrMoonTime]==IS_SUN_TIME)?@"阳":@"月"]];
        return 0;

    }
    
    //增加光的动画准备
    UIImageView* srcView = [[UIImageView alloc] initWithImage:[CommonObject getBaseLightImageByTime]];
    LightType type = [CommonObject getBaseLightTypeByTime];
    NSDictionary *aniDic = [NSDictionary dictionaryWithObjectsAndKeys:srcView,KEY_ANIMATION_VIEW,[NSNumber numberWithInteger:type],KEY_ANIMATION_LIGHT_TYPE, nil];
    [self.view addSubview:srcView];
    
    CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimation];
    
    CGPoint startPoint = sunMoonImageViewTop.center;
    CGPoint endPoint = sunMoonImageView.center;
    
    float disX = endPoint.x - startPoint.x;
    float disY = endPoint.y - startPoint.y;
    
    CGPoint bazierPoint_1 = CGPointMake(startPoint.x+(disX/3)+20, startPoint.y + (disY/3) +20);
    
    [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
    
    CGPoint bazierPoint_2 = CGPointMake(startPoint.x+(disX/3*2)+20, startPoint.y + (disY/3*2) +20);
    [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
    
    [customAnimation setAniType:BEZIER_ANI_TYPE];
    [customAnimation setAniImageViewDic:aniDic];
    [customAnimation setBkLayer:self.view.layer];
    [customAnimation setAniStartSize:CGSizeMake(30, 30)];
    [customAnimation setAniEndSize:CGSizeMake(30, 30)];
    [customAnimation setAniStartPoint:startPoint];
    [customAnimation setAniEndpoint:endPoint];
    [customAnimation setCustomAniDelegate:self];
    [customAnimation setAnikey:@"animation_bazier_add_one_light"];
    [customAnimation setAniRepeatCount:1];
    [customAnimation setAniDuration:1.5];
    
    [customAnimation startCustomAnimation];

    

 
    return count;
}

#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    
    CGFloat red   = (arc4random() % 256)/255.0;
    CGFloat green = (arc4random() % 256)/255.0;
    CGFloat blue  = (arc4random() % 256)/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


#pragma mark - AminationCustomDelegate
- (void) customAnimationFinishedRuturn:(NSString*) aniKey  srcViewDic:(NSDictionary*) srcViewDic
{
        UIImageView* srcView = (UIImageView*)[srcViewDic objectForKey:KEY_ANIMATION_VIEW];
    
    [srcView removeFromSuperview];
    valuelabel.text = @"+1";
    
    
    if ([aniKey isEqualToString:@"animation_bazier_add_one_light"]) {
        
        AudioServicesPlaySystemSound(1113);
        
    }
    
    

}

#pragma mark -

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


//丢弃返回， 减少一个阳光
- (void)abandonAction
{

    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        
        if([valuelabel.text isEqualToString:@"+1"])
        {
            [CommonObject showActionSheetOptiontitleMsg:@"放弃将失去此次摘得的阳光" ShowInView:self.view CancelMsg:@"不放弃" DelegateObject:self Option:@"放弃"];
            
        }else
        {
            //从相册而来
            [CommonObject showActionSheetOptiontitleMsg:@"放弃吗？" ShowInView:self.view CancelMsg:@"不放弃" DelegateObject:self Option:@"放弃"];
        }

        
        
    }else if([CommonObject checkSunOrMoonTime] ==  IS_MOON_TIME)
    {
        if([valuelabel.text isEqualToString:@"+1"])
        {
            [CommonObject showActionSheetOptiontitleMsg:@"放弃将失去此次摘得的月光" ShowInView:self.view CancelMsg:@"不放弃" DelegateObject:self Option:@"放弃"];
            
        }else
        {
            //从相册而来
            [CommonObject showActionSheetOptiontitleMsg:@"放弃吗？" ShowInView:self.view CancelMsg:@"不放弃" DelegateObject:self Option:@"放弃"];
        }

    }
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        //放弃
        //减少阳光月光值
        //动画:...
        if([valuelabel.text isEqualToString:@"+1"])
        {
            //最后OK返回时，才加光，置已照过相
            //[self.userInfo decreaseSunOrMoonValue:1];
            [valuelabel setText:@""];
            //[self.userInfo updateIsHaveAddSunOrMoonValueForTodayPhoto:NO];
            
        }else
        {
            //从相册而来，为0，不减少
        }
        
        //删除语音
        VoicePressedHold* pressedVoiceFordelete = [[VoicePressedHold alloc] init];
        NSString* nameVoice = [imagePickerData objectForKey:CAMERA_VOICE_NAEM_KEY];
        [pressedVoiceFordelete setVoiceName:nameVoice];
        //[pressedVoiceFordelete deleteVoiceFile];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
        
    
    }else if (buttonIndex == 1) {

        //取消放弃

    }
}


- (void)fitlerDone:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{

        
        //待优化 增加写死为1， 出现了加光错乱的情况
        if (finalGiveLightCout>0) {
            [self.userInfo addSunOrMoonValue:1];
            [self.userInfo updateIsHaveAddSunOrMoonValueForTodayPhoto:YES];

        }
  
        NSDictionary* imageFilterData = [NSDictionary dictionaryWithObjectsAndKeys:rootImageView.image,CAMERA_IMAGE_KEY,
                                         [imagePickerData objectForKey:CAMERA_TIME_KEY], CAMERA_TIME_KEY,
                                         currentSentence, CAMERA_SENTENCE_KEY,
                                         [NSString stringWithFormat:@"%u", finalGiveLightCout],CAMERA_LIGHT_COUNT,
                                         nil];
        [delegate imageFitlerProcessDone:imageFilterData];
        
        
        
        if (self.userInfo.photoSaveAutoCtl) {
            [self savetoAlbumHandle:Nil];
        }
        
    }];
    
    
}

- (IBAction)reDoPhoto:(id)sender {

    
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
    [controller setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [controller setUserInfo:self.userInfo];
    [self presentViewController:controller
                       animated:YES
                     completion:^(void){
                         //NSLog(@"Picker View Controller is presented");
                     }];
    
    
}


-(void)doShare
{
    
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareTitle = NSLocalizedString(@"appName", @"");
    share.shareImage =[self ShareImageWitheWater:rootImageView.image];
    share.shareMsg = [imagePickerData objectForKey:CAMERA_SENTENCE_KEY];
    
    NSString* addShow = [NSString stringWithFormat:NSLocalizedString(@"CutScreenShareMsg", @""), [CommonObject getLightCharactorByTime]];
    share.shareMsgSignature = [addShow stringByAppendingString: NSLocalizedString(@"FromUri", @"")];
    
    NSString* tempShare;
    if (iSunORMoon == IS_SUN_TIME) {
        tempShare = [NSString stringWithFormat:@"我的天空养成了%d个阳光,", [self.userInfo.sun_value intValue]];
        share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixSun", @"")];
        

    }else
    {
        tempShare = [NSString stringWithFormat:@"我的天空养成了%d个月光,", [self.userInfo.moon_value intValue]];
        share.shareMsgPreFix = [tempShare stringByAppendingString:NSLocalizedString(@"MsgFrefixMoon", @"")];
    }
    share.customDelegate = self;

    
    [share shareImageNews];
    
}


//delegate
-(void) ShareStart
{
    
    [indicatorView startAnimating];
}

-(void) ShareCancel
{
    
    [indicatorView stopAnimating];
    
    [self showCustomDelayAlertBottom:@"取消分享"];
}

-(void) ShareReturnSucc
{
    
    [indicatorView stopAnimating];
    
    
    [self showCustomDelayAlertBottom:@"分享成功"];
    
}

-(void) ShareReturnFailed
{
    [indicatorView stopAnimating];
    
    [self showCustomYesAlertSuperView:@"分享失败\n请检查网络" AlertKey:@"shareFailed"];
}



- (void)cameraPhoto:(NSDictionary *) imagePickerDataReturn
{
    imagePickerData = imagePickerDataReturn;
    //重取一次
    finalGiveLightCout = [self checkFinalWetherAndGiveLight];

    [self viewDidLoad];

}


//优化：更换图片后，刷新效果不好
//替换为原来的相片
-(void)chooseOldImage:(UITapGestureRecognizer*) sender
{
    [indicatorView startAnimating];
    
    //存旧的相片
    UIImage* tempImage = editImageOld;
    NSString* tempString = editOldSentence;
    

    //交换位置
    //更新旧的相片为现有相片
    editImageOld = currentImage;
    editImageOldView.image =currentImage;
    editOldSentence = currentSentence;
    
    //更新现有相片
    currentImage = tempImage;
    rootImageView.image = tempImage;
    currentSentence =tempString;

    [indicatorView stopAnimating];


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


#pragma mark - Customer alert
-(void) showCustomYesAlertSuperView:(NSString*) msg AlertKey:alertKey
{
    
    customAlertAutoDisYes = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:[CommonObject getAlertBkByTime]  yesBtnImageName:@"OK.png" posionShowMode:userSet  AlertKey:alertKey];
    [customAlertAutoDisYes setStartCenterPoint:self.view.center];
    [customAlertAutoDisYes setEndCenterPoint:self.view.center];
    [customAlertAutoDisYes setStartAlpha:0.1];
    [customAlertAutoDisYes setEndAlpha:1.0];
    [customAlertAutoDisYes setStartHeight:0];
    [customAlertAutoDisYes setStartWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndWidth:SCREEN_WIDTH/5*3];
    [customAlertAutoDisYes setEndHeight:customAlertAutoDisYes.endWidth];
    [customAlertAutoDisYes setDelayDisappearTime:4.0];
    [customAlertAutoDisYes setMsgFrontSize:35];
    [customAlertAutoDisYes setAlertMsg:msg];
    [customAlertAutoDisYes setCustomAlertDelegate:self];
    [customAlertAutoDisYes RunCumstomAlert];
    
}

- (void)yesButtonHandler:(id)sender
{
    [customAlertAutoDisYes yesButtonHandler:nil];
    
}



-(void) showCustomDelayAlertBottom:(NSString*) msg
{
    customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view taget:(id)self bkImageName:[CommonObject getDelayBkByTime]  yesBtnImageName:nil posionShowMode:userSet AlertKey:nil];
    [customAlertAutoDis setStartHeight:0];
    [customAlertAutoDis setStartWidth:SCREEN_WIDTH/5*4];
    [customAlertAutoDis setEndWidth:SCREEN_WIDTH/5*4];
    [customAlertAutoDis setEndHeight:customAlertAutoDis.endWidth*216/547];
    [customAlertAutoDis setStartCenterPoint:self.view.center];
    [customAlertAutoDis setEndCenterPoint:self.view.center];
    [customAlertAutoDis setStartAlpha:0.1];
    [customAlertAutoDis setEndAlpha:0.8];
    [customAlertAutoDis setDelayDisappearTime:4.0];
    [customAlertAutoDis setMsgFrontSize:35];
    [customAlertAutoDis setAlertMsg:msg];
    [customAlertAutoDis RunCumstomAlert];
    
}


#pragma mark - CustomAlertDelegate
- (void) CustomAlertOkAnimationFinish:(NSString*) alertKey
{
    NSLog(@"custom aler ok return");
}

@end
