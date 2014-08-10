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

@interface ImageFilterProcessViewController ()

{
    UIImage *editImageOld;
    UIImageView* editImageOldView;
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
    
    AminationCustom* addVauleAnimation;
}

@end

@implementation ImageFilterProcessViewController
@synthesize currentImage = currentImage,currentSentence=currentSentence, delegate = delegate, imagePickerData=imagePickerData,iSunORMoon=iSunORMoon;

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
    
    if(!isHaveRemindValue)
    {
        isHaveRemindValue = NO;

    }
 
    addVauleAnimation = [[AminationCustom alloc] initWithKey:@"addValueinEdite"];
    addVauleAnimation.aminationCustomDelegate =  self;
    
    //获取单例用户数据
    //self.userInfo= [UserInfo  sharedSingleUserInfo];
    
    currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    
    //UIImage *bkImage = [UIImage imageNamed:@"小屋内底图.png"];
    UIImageView *bkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 460)];
    //bkImageView.image = bkImage;
    bkImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bkImageView];
    
    //工具条
    UIImage *toolBarImage = [UIImage imageNamed:@"下部圆弧001.png"];
    //UIImageView *toolBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, ScreenHeight-TOOL_BAR_HEIGHT, ScreenWidth, TOOL_BAR_HEIGHT)];
    UIImageView *toolBarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 420, SCREEN_WIDTH, 60)];
    toolBarImageView.image = toolBarImage;
    [self.view addSubview:toolBarImageView];
    
    //加重拍按钮
    NSInteger rePhotoBtnWidth = 20;
    NSInteger rePhotoBtnHeight = 20;
    UIButton *rePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rePhotoBtn setImage:[UIImage imageNamed:@"拍照-small.png"] forState:UIControlStateNormal];
    [rePhotoBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, toolBarImageView.center.y-rePhotoBtnHeight/2, rePhotoBtnWidth, rePhotoBtnHeight)];
    [rePhotoBtn addTarget:self action:@selector(reDoPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rePhotoBtn];
    
    //加分享按钮
    NSInteger shareBtnWidth = 20;
    NSInteger shareBtnHeight = 20;
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"editePhoto_分享.png"] forState:UIControlStateNormal];
    [shareBtn setFrame:CGRectMake(ScreenWidth/2-shareBtnWidth/2, toolBarImageView.center.y-shareBtnHeight/2, shareBtnWidth, shareBtnHeight)];
    [shareBtn addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    
    //加保存到相册按钮
    NSInteger saveBtnWidth = 20;
    NSInteger saveBtnHeight = 20;
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"选择.png"] forState:UIControlStateNormal];
    [saveBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X- saveBtnWidth, toolBarImageView.center.y-saveBtnHeight/2, saveBtnWidth, saveBtnHeight)];
    [saveBtn addTarget:self action:@selector(savetoAlbumHandle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    
    //加OK返回按钮
    NSInteger okBtnWidth = 20;
    NSInteger okBtnHeight = 20;
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    [okBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y, okBtnWidth, okBtnHeight)];
    [okBtn addTarget:self action:@selector(fitlerDone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    //加丢弃并返回按钮
    NSInteger rightBtnWidth = 20;
    NSInteger rightBtnHeight = 20;
    UIButton *rightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"丢弃.png"] forState:UIControlStateNormal];
    [rightBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-rightBtnWidth, NAVI_BAR_BTN_Y, rightBtnWidth, rightBtnHeight)];
    [rightBtn addTarget:self action:@selector(abandonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    //相片显示
    float imageWideth = 180;
    float imageHeight = imageWideth*960/640;
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.388 alpha:1.000]];
    rootImageView = [[UIImageView alloc ] initWithFrame:CGRectMake(ScreenWidth/2-imageWideth/2, 40, imageWideth, imageHeight)];
    rootImageView.image = currentImage;
    rootImageView.tag = TAG_EDITE_IMAGE_VIEW;
    [self.view addSubview:rootImageView];
    
    //取原相片
    editImageOld = Nil;
    if(iSunORMoon == IS_SUN_TIME) {
        editImageOld = [UIImage imageWithData:self.userInfo.sun_image];
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        editImageOld = [UIImage imageWithData:self.userInfo.moon_image];
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
    int timeImageWidth = 100;
    UIImage *timeImage = [UIImage imageNamed:@"时间框.png"];
    UIImageView *timeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(rootImageView.frame.origin.x+imageWideth/2-60/2, rootImageView.frame.origin.y+imageHeight+5, timeImageWidth, timeImageHeight)];
    timeImageView.image = timeImage;
    [self.view addSubview:timeImageView];
    
    
    //日月
    int sunMoonImageDiameter = 50;
    if ([CommonObject checkSunOrMoonTime] ==  IS_SUN_TIME) {
        sunMoonImage = [UIImage imageNamed:@"sun.png"];

    }else
    {
        sunMoonImage = [UIImage imageNamed:@"moon.png"];

    }
    sunMoonImageView = [[UIImageView alloc]initWithFrame:CGRectMake(timeImageView.frame.origin.x-10, timeImageView.frame.origin.y+timeImageHeight/2-sunMoonImageDiameter/2, sunMoonImageDiameter, sunMoonImageDiameter)];
    sunMoonImageView.image = sunMoonImage;
    [self.view addSubview:sunMoonImageView];
    

    //时间值
    timeString = [imagePickerData objectForKey:CAMERA_TIME_KEY];
    int timelabelHeight = 20;
    int timelabelWidth = 100;
    timelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+10, timeImageView.center.y-timelabelHeight/2, timelabelWidth,timelabelHeight)];
    [timelabel setBackgroundColor:[UIColor clearColor]];
    [timelabel setText:timeString];
    [timelabel setTextAlignment:NSTextAlignmentCenter];
    [timelabel setFont:[UIFont systemFontOfSize:12.0f]];
    [timelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:timelabel];
    
    
    //阳光值
    int valuelabelHeight = 20;
    int valuelabelWidth = 20;
    valuelabel = [[UILabel alloc] initWithFrame:CGRectMake(sunMoonImageView.frame.origin.x+sunMoonImageView.frame.size.width/2-valuelabelWidth/2, sunMoonImageView.frame.origin.y+sunMoonImageView.frame.size.height/2-valuelabelHeight/2, valuelabelWidth,valuelabelHeight)];
    [valuelabel setBackgroundColor:[UIColor clearColor]];
    [valuelabel setText:@"+1"];
    [valuelabel setTextAlignment:NSTextAlignmentCenter];
    [valuelabel setFont:[UIFont systemFontOfSize:10.0f]];
    [valuelabel setTextColor:[UIColor blackColor]];
    valuelabel.hidden = YES;
    [self.view addSubview:valuelabel];
    

    //语录,暂时没用
    currentSentence = [imagePickerData objectForKey:CAMERA_SENTENCE_KEY];
    int sentencelabelHeight = 20;
    int sentencelabelWidth = 70;
    sentencelabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x+timeImageWidth/2-sentencelabelWidth/2, timeImageView.frame.origin.y+timeImageHeight+5, sentencelabelWidth, sentencelabelHeight)];
    [sentencelabel setBackgroundColor:[UIColor clearColor]];
    [sentencelabel setText:currentSentence];
    [sentencelabel setTextAlignment:NSTextAlignmentCenter];
    [sentencelabel setFont:[UIFont systemFontOfSize:13.0f]];
    [sentencelabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:sentencelabel];
    

    //调色盘
    NSArray *arr = [NSArray arrayWithObjects:@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐色",@"淡雅",@"酒红",@"青柠",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, timelabel.frame.origin.y+timelabelHeight+5, 320, 80)];
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
        recognizer.delegate = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x-5, 53, 40, 23)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setText:[arr objectAtIndex:i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:13.0f]];
        [label setTextColor:[UIColor whiteColor]];
        [label setUserInteractionEnabled:YES];
        [label setTag:TAG_EDITE_PHOTO_SCROLL_LABEL+i];
        //[label addGestureRecognizer:recognizer];
        [scrollerView addSubview:label];
        
        bgImageViewScroll = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, 30, 40)];
        bgImageViewScroll.tag = i;
        [bgImageViewScroll addGestureRecognizer:recognizer];
        [bgImageViewScroll setUserInteractionEnabled:YES];
        bgImageScroll = [self changeImage:i imageView:nil];
        bgImageViewScroll.image = bgImageScroll;
        [scrollerView addSubview:bgImageViewScroll];
        

    }
    scrollerView.contentSize = CGSizeMake(x + 55, 80);
    [self.view addSubview:scrollerView];
    
    
    //日月最上方的
    UIImage *sunMoonImageTop;
    if ([CommonObject checkSunOrMoonTime] == IS_SUN_TIME) {
        sunMoonImageTop = [UIImage imageNamed:@"sun.png"];
        
    }else
    {
        sunMoonImageTop = [UIImage imageNamed:@"moon.png"];
        
    }
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
    NSInteger lightBowSkyUserHeaderViewHeigth = sunMoonImageViewTop.frame.size.height+IntervalWidth*2;
    
    bowLightView = [[UIImageView alloc] initWithFrame:CGRectMake(sunMoonImageViewTop.center.x-lightBowSkySunMoonViewWidth/2, sunMoonImageViewTop.center.y-lightBowSkySunMoonViewWidth/2, lightBowSkySunMoonViewWidth, lightBowSkyUserHeaderViewHeigth)];
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
    UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil,nil);
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"保存成功！"
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
    
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    sunMoonImageViewTop.hidden = YES;

    
    if (self.userInfo.photoSaveAutoCtl) {
        [self savetoAlbumHandle:Nil];
    }
    
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
    timeString = [imagePickerData objectForKey:CAMERA_TIME_KEY];
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
    

    [self checkWetherAndGiveLight];
    
    
}


-(void) checkWetherAndGiveLight
{
    
    NSInteger count = [[imagePickerData objectForKey:CAMERA_LIGHT_COUNT] integerValue];
    if (count==0) {
        NSLog(@" 获得的光的个数为0，返回");
        return;
    }
    
    //增加光的动画准备
    [addVauleAnimation setStartPoint:sunMoonImageViewTop.center];
    [addVauleAnimation setEndpoint:sunMoonImageView.center];
    [addVauleAnimation setUseRepeatCount:count];
    [addVauleAnimation setBkView:self.view];
    if (iSunORMoon == IS_SUN_TIME) {
        [addVauleAnimation setImageName:@"sun.png"];
    }else
    {
        [addVauleAnimation setImageName:@"moon.png"];
    }
    [addVauleAnimation setAminationImageViewframe:CGRectMake(sunMoonImageViewTop.frame.origin.x, sunMoonImageViewTop.frame.origin.y, 60, 60)];
    
    //判断是否增加阳光月光值
    if ([CommonObject checkSunOrMoonTime]==IS_SUN_TIME) {
        if ([self.userInfo checkIsHaveAddSunValueForTodayPhoto]) {
            
            [CommonObject showAlert:@"已增加过阳光值" titleMsg:@"提示" DelegateObject:self];
            
        }else
        {
            [addVauleAnimation moveLightWithIsUseRepeatCount:YES];
            [self.userInfo addSunOrMoonValue:count];
            [self.userInfo updateIsHaveAddSunValueForTodayPhoto:YES];
            
        }
    }else
    {
        if ([self.userInfo checkIsHaveAddMoonValueForTodayPhoto]) {
            
            [CommonObject showAlert:@"已增加过月光值" titleMsg:@"提示" DelegateObject:self];
            
        }else
        {
            [addVauleAnimation moveLightWithIsUseRepeatCount:YES];
            [self.userInfo addSunOrMoonValue:count];
            [self.userInfo updateIsHaveAddMoonValueForTodayPhoto:YES];
            
            
        }
        
    }
    
    //test
    //[addVauleAnimation moveLightWithIsUseRepeatCount:YES];
    
}

#pragma mark - AminationCustomDelegate

- (void) animationFinishedRuturn
{
    
    valuelabel.hidden = NO;
    
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
        
        [CommonObject showActionSheetOptiontitleMsg:@"放弃将失去此次增加的阳光值" ShowInView:self.view CancelMsg:@"放弃" DelegateObject:self Option:@"不放弃"];
        
        
    }else if([CommonObject checkSunOrMoonTime] ==  IS_MOON_TIME)
    {
        [CommonObject showActionSheetOptiontitleMsg:@"放弃将失去此次增加的   月光值" ShowInView:self.view CancelMsg:@"放弃" DelegateObject:self Option:@"不放弃"];
    }
    
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //取消放弃
        
    }else if (buttonIndex == 1) {

        //放弃
        //减少阳光月光值
        //动画:...
        [self.userInfo decreaseSunOrMoonValue:1];
        
        [self dismissViewControllerAnimated:YES completion:NULL];

    }
    
}


- (IBAction)fitlerDone:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{


        NSDictionary* imageFilterData = [NSDictionary dictionaryWithObjectsAndKeys:rootImageView.image,CAMERA_IMAGE_KEY,
                                         [imagePickerData objectForKey:CAMERA_TIME_KEY], CAMERA_TIME_KEY,
                                         [imagePickerData objectForKey:CAMERA_SENTENCE_KEY], CAMERA_SENTENCE_KEY,
                                         nil];
        [delegate imageFitlerProcessDone:imageFilterData];
        

        
    }];
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


-(void)doShare
{
    
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareTitle = @"天天更美丽";
    share.shareImage =currentImage;
    share.shareMsg = currentSentence;
    share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
    share.waterImage = [UIImage imageNamed:@"waterlogo.png"];
    NSInteger x = share.shareImage.size.width/4;
    NSInteger y = share.shareImage.size.width*3/4;
    NSInteger w = share.shareImage.size.width/5;
    NSInteger h = share.shareImage.size.width/5*(share.waterImage.size.height/share.waterImage.size.width);
    share.waterRect = CGRectMake(x,y,w,h);
    
    if(iSunORMoon == IS_SUN_TIME) {
        share.shareMsgPreFix = @"我的阳光宣言：";

    }else if (iSunORMoon == IS_MOON_TIME)
    {
        share.shareMsgPreFix = @"我的月光宣言：";

    }
    
    [share addWater];
    
    [share shareImageNews];
    
}

//优化：更换图片后，刷新效果不好
- (void)cameraPhoto:(NSDictionary *) imagePickerDataReturn
{
    //currentImage = [imagePickerData objectForKey:CAMERA_IMAGE_KEY];
    imagePickerData = imagePickerDataReturn;
    //[rootImageView setImage:currentImage];
    [self viewDidLoad];

}


//替换为原来的相片
-(void)chooseOldImage:(UITapGestureRecognizer*) sender
{
    UIImage* tempOld = Nil;
    NSString* tempOldstring = Nil;
    if(iSunORMoon == IS_SUN_TIME) {
        tempOld = [UIImage imageWithData:self.userInfo.sun_image];
        tempOldstring = self.userInfo.sun_image_sentence;
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        tempOld = [UIImage imageWithData:self.userInfo.moon_image];
        tempOldstring = self.userInfo.moon_image_sentence;
    }
    
    //交换新旧图片
    //旧相片放到imagePickerData中
    imagePickerData = [NSDictionary dictionaryWithObjectsAndKeys:tempOld,CAMERA_IMAGE_KEY,
                                     [imagePickerData objectForKey:CAMERA_TIME_KEY], CAMERA_TIME_KEY,
                                     tempOldstring,CAMERA_SENTENCE_KEY,[imagePickerData objectForKey:CAMERA_VOICE_NAEM_KEY], CAMERA_VOICE_NAEM_KEY,
                                     nil];
    //换新照的相片存到userinfo中，当成上次照的旧相片
    if(iSunORMoon == IS_SUN_TIME) {
        self.userInfo.sun_image = UIImagePNGRepresentation(currentImage);
        self.userInfo.sun_image_sentence = currentSentence;
    }else if (iSunORMoon == IS_MOON_TIME)
    {
        self.userInfo.moon_image = UIImagePNGRepresentation(currentImage);
        self.userInfo.moon_image_sentence = currentSentence;

    }
    //更新数据库
    [self.userInfo updateTodayUserData:self.userInfo];
    
    [self reFreshcelement];

    
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
