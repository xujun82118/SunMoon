//
//  HomeInsideViewController.m
//  SunMoon
//
//  Created by songwei on 14-4-6.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "HomeInsideViewController.h"
#import "Navbar.h"
#import "AddWaterMask.h"
#import <ShareSDK/ShareSDK.h>
#import "SunMoonAlertTime.h"
#import "ShareByShareSDR.h"


@interface HomeInsideViewController ()

@end

@implementation HomeInsideViewController

@synthesize user,userData,userDB,sunWordShow,moonWordShow,currentSelectDataSun,currentSelectDataMoon;
@synthesize sunTimeBtn,moonTimeBtn,moonTimeCtlBtn,sunTimeCtlBtn,sunValueStatic,moonValueStatic,sunTimeText,moonTimeText;


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
 
    //获取单例用户数据
    self.user= [UserInfo  sharedSingleUserInfo];
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;
    
    userDB = [[UserDB alloc] init];
    

    //[self.navigationItem setNewTitle:@"测试"];
    [self.navigationItem setRightItemWithTarget:self  action:@selector(back) image:@"HomeInside_0000s_0001_设置.png"];
    
    [self.navigationItem setLeftItemWithTarget:self  action:@selector(back) image:@"HomeInside_0000s_0000_返回.png"];

    

    [self addScrollUserImageSunReFresh:NO];
    [self addScrollUserImageMoonReFresh:NO];
    
}

-(void) addScrollUserImageSunReFresh:(BOOL) isFresh
{
    NSInteger count = [userData count];
    NSLog(@"-------count = %d", count);
    NSMutableArray *setSun = [[NSMutableArray alloc] init];
    if (count>0) {
        
        //太阳数据
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            //构造带时间的照片
            //UIImage* addImageBk = [self addTimeToImage:[UIImage imageNamed:@"相框.png"] withTime:userInfo.sun_image_name];
            //UIImage* addImage = [self addToImage:[UIImage imageWithData:userInfo.sun_image] withBkImage:addImageBk];
            //传入dictionary，以携带更多信息
            UIImage* addImage = [UIImage imageWithData:userInfo.sun_image];
            if (addImage == Nil) {
                break;
            }
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               addImage,@"image_data",
                               userInfo.sun_image_name,@"image_name_time",//name 即为时间
                               userInfo.sun_image_sentence,@"image_sentence",
                               nil]];
            
        }
        
    }
   
    
    //目前最多支持8张相片，小于8张的用默认图片填充
    if (count<8) {
        int temp = 1;
        for (int i = count; i<8; i++) {
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",temp++]],@"image_data",
                               @" ",@"image_name_time",
                               @" ",@"image_sentence",
                               nil]];
            
        }
        
    }
    
    
    //取第一张默认相片的尺寸
    CGSize size;
    if (count>0) {
        size = [(UIImage*)[(NSDictionary*)[setSun objectAtIndex:0] objectForKey:@"image_data"] size];
    }else
    {
        size =[[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    }
    
    //第一次登录时照片为空，size=0
    if (size.width ==0) {
        size =[[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    }
    
    
    //取得时间轴的相对位置
    UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
    //如果时间轴高度小于相片的高度，则缩小相片,使时间轴包进相片
    //    if (scrollPosition.frame.size.height<=size.height) {
    //        float rat = size.width/size.height;
    //        size.height = scrollPosition.frame.size.height -5;
    //        size.width = size.height*rat;
    //
    //    }
    


    
    if (!isFresh) {
        imageScrollSun = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-15, SCREEN_WIDTH, 100)];
        [imageScrollSun setImageAry:setSun];
        [imageScrollSun setItemSize:size];
        [imageScrollSun setHeightOffset:30];
        [imageScrollSun setPositionRatio:2];
        [imageScrollSun setAlphaOfobjs:0.8];
        [imageScrollSun setMode:0];
        [imageScrollSun setScrollDelegate:self];
        [self.view addSubview:imageScrollSun];

    }else
    {
        [imageScrollSun removeFromSuperview];
        imageScrollSun = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-15, SCREEN_WIDTH, 100)];
        [imageScrollSun setImageAry:setSun];
        [imageScrollSun setItemSize:size];
        [imageScrollSun setHeightOffset:30];
        [imageScrollSun setPositionRatio:2];
        [imageScrollSun setAlphaOfobjs:0.8];
        [imageScrollSun setMode:0];
        [imageScrollSun setScrollDelegate:self];
        [self.view addSubview:imageScrollSun];

        
    }
    
    

}


-(void) addScrollUserImageMoonReFresh:(BOOL) isFresh
{
    NSInteger count = [userData count];

    NSMutableArray *setMoon = [[NSMutableArray alloc] init];
    if (count>0) {
        
        //月亮数据
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            UIImage* addImage = [UIImage imageWithData:userInfo.moon_image];
            //传入dictionary，以携带更多信息
            [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                addImage,@"image_data",
                                userInfo.moon_image_name,@"image_name_time",//name 即为时间
                                userInfo.moon_image_sentence,@"image_sentence",
                                nil]];
            
        }
        
    }
    
    
    //目前最多支持8张相片，小于8张的用默认图片填充
    if (count<8) {
        int  temp1=1;
        for (int i = count; i<8; i++) {
            [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",temp1++]],@"image_data",
                                @" ",@"image_name_time",
                                @" ",@"image_sentence",
                                nil]];
            
        }
        
    }
    
    
    //取第一张默认相片的尺寸
    CGSize size;
    if (count>0) {
        size = [(UIImage*)[(NSDictionary*)[setMoon objectAtIndex:0] objectForKey:@"image_data"] size];
    }else
    {
        size =[[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    }
    
    //第一次登录时照片为空，size=0
    if (size.width ==0) {
        size =[[UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",1]] size];
    }
    
    
    if (!isFresh) {
        UIImageView* scrollPosition1 = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_MOON];
        imageScrollMoon = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition1.frame.origin.y-15, SCREEN_WIDTH, 100)];
        [imageScrollMoon setImageAry:setMoon];
        [imageScrollMoon setItemSize:size];
        [imageScrollMoon setHeightOffset:30];
        [imageScrollMoon setPositionRatio:2];
        [imageScrollMoon setAlphaOfobjs:0.8];
        [imageScrollMoon setMode:1];
        [imageScrollMoon setScrollDelegate:self];
        [self.view addSubview:imageScrollMoon];
        
    }else
    {
        [imageScrollMoon removeFromSuperview];
        UIImageView* scrollPosition1 = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_MOON];
        imageScrollMoon = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition1.frame.origin.y-15, SCREEN_WIDTH, 100)];
        [imageScrollMoon setImageAry:setMoon];
        [imageScrollMoon setItemSize:size];
        [imageScrollMoon setHeightOffset:30];
        [imageScrollMoon setPositionRatio:2];
        [imageScrollMoon setAlphaOfobjs:0.8];
        [imageScrollMoon setMode:1];
        [imageScrollMoon setScrollDelegate:self];
        [self.view addSubview:imageScrollMoon];
        
    }
    

    
    
    
}



-(void)refreshScrollUserImageSun
{
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;


    [self addScrollUserImageSunReFresh:YES];

    
}

-(void)refreshScrollUserImageMoon
{
    //重取一次数据
    [self.user getUserInfoAtNormalOpen];
    self.userData  = self.user.userDataBase;

    
    [self addScrollUserImageMoonReFresh:YES];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    
    //self.navigationController.navigationBarHidden = NO;

    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回.png"]
                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem =addButton;
    
    //加返回按钮
    NSInteger backBtnWidth = 20;
    NSInteger backBtnHeight = 20;
    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y, backBtnWidth, backBtnHeight)];
    //[backBtn setFrame:CGRectMake(200, NAVI_BAR_BTN_Y, backBtnWidth, backBtnHeight)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    /*
    UIImage *backButtonBackgroundImage = [UIImage imageNamed:@"返回.png"];
    // The background should be pinned to the left and not stretch.
    backButtonBackgroundImage = [backButtonBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, backButtonBackgroundImage.size.width - 1, 0, 0)];
    
    id appearance = [UIBarButtonItem appearanceWhenContainedIn:[HomeInsideViewController class], nil];
    [appearance setBackButtonBackgroundImage:backButtonBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:NULL];
    self.navigationItem.backBarButtonItem = backBarButton;
    */
    
    //显示定时时间
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.sunAlertTime];
    NSInteger hour = [comps hour];
    NSInteger miniute = [comps minute];
    NSString *timeString = [[NSString alloc] initWithFormat:
                            @"%d:%d", hour, miniute];
    [sunTimeBtn setTitle:timeString forState:UIControlStateNormal];
    [sunTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    comps =[calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit)fromDate:self.user.moonAlertTime];
    NSInteger hour1 = [comps hour];
    NSInteger miniute1 = [comps minute];
    NSString *timeString1 = [[NSString alloc] initWithFormat:
                             @"%d:%d", hour1, miniute1];
    [moonTimeBtn setTitle:timeString1 forState:UIControlStateNormal];
    [moonTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    //动态显示阳光，月光值
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(animateIncreaseValue:)
                                   userInfo:nil
                                    repeats:NO];
   
}

- (void) viewDidAppear:(BOOL)animated
{

    //高亮相框移动到最上层
//    UIImageView* highlightSun = (UIImageView*)[self.view viewWithTag:TAG_IMAGE_HIGH_LIGHT_SUN];
//    highlightSun.contentMode = UIViewContentModeRedraw;
//    [highlightSun setFrame:CGRectMake(0,30,40,40)];
//    [self.view bringSubviewToFront:highlightSun];
    
//    UIImageView *highlightSun = [[UIImageView alloc] initWithFrame:CGRectMake(0,30,40,40)];
//    highlightSun.image = [UIImage imageNamed:@"相框.png"];
//    [self.view addSubview:highlightSun];
    
    

    
}


-(void) animateIncreaseValue:(NSTimer *)timer
{
    //显示阳光，月光值, 从1增加到最大
    int count = [userData count];
    for (int i = 0; i<count; i++) {
        UserInfo* userInfo = [userData objectAtIndex:i];
        sunValueStatic.text = userInfo.sun_value;
        moonValueStatic.text = userInfo.moon_value;
        sleep(0.5);
    }
}


/**
 * @brief 给相片增加日期时间
 *
 * @param image 要增加图片
 * @param time 要增加的时间字串
 */
- (UIImage*) addTimeToImage: (UIImage*) image  withTime:(NSString*) time
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addText:image text:time];
    
    return  imageAdd;
}


/**
 * @brief 给相片叠加时间底图
 *
 * @param timeImage 时间底图
 * @param image 加到底图上的原图
 */
- (UIImage*) addToImage: (UIImage*) image  withBkImage:(UIImage*) timeImage
{
    
    AddWaterMask* add = [AddWaterMask alloc];
    UIImage* imageAdd = [add addImage:timeImage addMsakImage:image];
    
    return  imageAdd;
}




-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
    
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



#pragma mark - 用户分享

/**
 * @brief 分享早上选中的相片
 *
 */
- (IBAction)shareNight:(id)sender {
    
    
    UIImageView* imageData = [currentSelectDataMoon objectForKey:@"image_data"];
    NSString* imageSentence = [currentSelectDataMoon objectForKey:@"image_sentence"];
    
    ShareByShareSDR* share = [ShareByShareSDR alloc];
    share.shareTitle = @"天天更美丽";
    share.shareImage =imageData.image;
    share.shareMsg = imageSentence;
    share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
    share.shareMsgPreFix = @"晚安，送上我的月光语录：";
    share.waterImage = [UIImage imageNamed:@"waterlogo.png"];
    NSInteger x = share.shareImage.size.width/4;
    NSInteger y = share.shareImage.size.width*3/4;
    NSInteger w = share.shareImage.size.width/5;
    NSInteger h = share.shareImage.size.width/5*(share.waterImage.size.height/share.waterImage.size.width);
    share.waterRect = CGRectMake(x,y,w,h);

    [share addWater];
    
    [share shareImageNews];
    
    
}


/**
 * @brief 分享早上选中的相片
 *
 */- (IBAction)shareMorning:(id)sender {
     
     UIImageView* imageData = [currentSelectDataSun objectForKey:@"image_data"];
     NSString* imageSentence = [currentSelectDataSun objectForKey:@"image_sentence"];
     
     ShareByShareSDR* share = [ShareByShareSDR alloc];
     share.shareTitle = @"天天更美丽";
     share.shareImage =imageData.image;
     share.shareMsg = imageSentence;
     share.shareMsgSignature = NSLocalizedString(@"FromUri", @"");
     share.shareMsgPreFix = @"晚安，送上我的阳光语录：";
     share.waterImage = [UIImage imageNamed:@"waterlogo.png"];
     NSInteger x = share.shareImage.size.width/4;
     NSInteger y = share.shareImage.size.width*3/4;
     NSInteger w = share.shareImage.size.width/5;
     NSInteger h = share.shareImage.size.width/5*(share.waterImage.size.height/share.waterImage.size.width);
     share.waterRect = CGRectMake(x,y,w,h);
     
     [share addWater];
     
     [share shareImageNews];
     
}

#pragma mark -
- (IBAction)DeleteMoonImage:(id)sender
{
    NSString* imageName = [currentSelectDataMoon objectForKey:@"image_name_time"];
    //查出包含此条的数据
    UserInfo* selectUserInfo = [userDB getUserDataByDateTime:imageName];
    
    if ([userDB getUserDataByDateTime:selectUserInfo.date_time]) {
        NSLog(@"DeleteNightImage, Datetime=%@， 此条存在，先删后插入新的一条!", selectUserInfo.date_time);
        [userDB deleteUserWithDataTime:selectUserInfo.date_time];
        //置空删除的相片
        selectUserInfo.moon_image = Nil;
        //重存此条数据
        [userDB saveUser:selectUserInfo];
    }else
    {
        NSLog(@"DeleteNightImage，错误，此条不存在!");
        [userDB saveUser:selectUserInfo];
    }
    
    NSLog(@"刷新 月光 数据");
    [self refreshScrollUserImageMoon];
    
}
- (IBAction)DeleteSunImage:(id)sender
{
    
    NSString* imageName = [currentSelectDataSun objectForKey:@"image_name_time"];
    //查出包含此条的数据
    UserInfo* selectUserInfo = [userDB getUserDataByDateTime:imageName];
    
    if (selectUserInfo) {
        NSLog(@"DeleteMorningImage, Datetime=%@， 此条存在，先删后插入新的一条!", selectUserInfo.date_time);
        [userDB deleteUserWithDataTime:selectUserInfo.date_time];
        //置空删除的相片
        selectUserInfo.sun_image = Nil;
        //重存此条数据
        [userDB saveUser:selectUserInfo];
    }else
    {
        NSLog(@"DeleteMorningImage，错误，此条不存在!");
        [userDB saveUser:selectUserInfo];
    }
    
    NSLog(@"刷新 阳光 数据");
    [self refreshScrollUserImageSun];
    
}

#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SetSunTime"]) {

        SunMoonAlertTime *destinationVC = (SunMoonAlertTime *)segue.destinationViewController;
        destinationVC.iSunORMoon = 1;
 
    }
    
    if ([[segue identifier] isEqualToString:@"SetMoonTime"]) {
        
        SunMoonAlertTime *destinationVC = (SunMoonAlertTime *)segue.destinationViewController;
        destinationVC.iSunORMoon = 2;
        
    }

}


- (IBAction)moonTimeCtl:(id)sender {
    
    [self.user updateMoonAlertTimeCtl:!self.user.moonAlertTimeCtl];

    if(self.user.moonAlertTimeCtl)
    {
        [moonTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟.png"] forState:UIControlStateNormal ];

    }else
    {
        [moonTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [moonTimeCtlBtn setImage:[UIImage imageNamed:@"alarm-暗.png"] forState:UIControlStateNormal ];
       
    }
    
}

- (IBAction)sunAlertCtl:(id)sender {
    
    [self.user updateSunAlertTimeCtl:!self.user.sunAlertTimeCtl];
   
    if(self.user.sunAlertTimeCtl)
    {
        [sunTimeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"小闹钟.png"] forState:UIControlStateNormal ];
    }else
    {
        [sunTimeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sunTimeCtlBtn setImage:[UIImage imageNamed:@"alarm-暗.png"] forState:UIControlStateNormal ];
        
    }
    
}

#pragma mark - InfiniteScrollPickerDelegate   
#pragma mark -  选择了其中一张照片
- (void)infiniteScrollPicker:(InfiniteScrollPicker *)infiniteScrollPicker didSelectAtImage:(UIImageView *)imageView
{
    //NSLog(@"selected index =%d", infiniteScrollPicker.selectedIndex);
    
    //太阳
    if (infiniteScrollPicker.mode == 0) {
        currentSelectDataSun =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
        
        //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
        
        NSString* imageSentence    = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_sentence"];
        sunWordShow.text       = imageSentence;
        
        sunTimeText.text =[(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_name_time"];
        [self.view bringSubviewToFront:sunTimeText];
    
        
        //将字摆到相片的中间对齐
//        UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
//        [sunTimeText setContentMode:UIViewContentModeRedraw];
//        [sunTimeText setNeedsDisplay];
//        [sunTimeText setFrame:CGRectMake(scrollPosition.frame.origin.x+imageView.frame.origin.x+imageView.frame.size.width/2, sunTimeText.frame.origin.y, sunTimeText.frame.size.width, sunTimeText.frame.size.height)];

  
//        NSLog(@"---sunTimeText (%f,%f,%f,%f)", sunTimeText.frame.origin.x,sunTimeText.frame.origin.y, sunTimeText.frame.size.width,sunTimeText.frame.size.height);
        
        
        
    }else if (infiniteScrollPicker.mode == 1)//月亮
    {
        currentSelectDataMoon =(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex];
        //UIImageView* imageData = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_data"];
        NSString* imageSentence    = [(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_sentence"];
        moonWordShow.text      = imageSentence;
        
        moonTimeText.text =[(NSDictionary*)[infiniteScrollPicker.imageStore objectAtIndex:infiniteScrollPicker.selectedIndex] objectForKey:@"image_name_time"];
        [self.view bringSubviewToFront:moonTimeText];
        
    }
    
    
}



- (void) InfiniteScrollViewWillBeginDragging:(InfiniteScrollPicker*)picker
{
    
    [UIView beginAnimations:@"TimeShowAnimationWhenDragging" context:(__bridge void *)(sunTimeText)];
    [UIView setAnimationDuration:0.3f];
    
    if (picker.mode == 0)
    {
        sunTimeText.alpha = 0.1;
        sunWordShow.alpha = 0.1;
    }else if (picker.mode == 1)
    {
        
        moonTimeText.alpha = 0.1;
        moonWordShow.alpha = 0.1;

    }
    
    [UIView commitAnimations];

}

- (void) InfiniteScrollViewDidEndScrollingAnimation:(InfiniteScrollPicker*)picker
{
    [UIView beginAnimations:@"TimeShowAnimationEndDragging" context:(__bridge void *)(sunTimeText)];
    [UIView setAnimationDuration:0.3f];

    
    if (picker.mode == 0)
    {
        sunTimeText.alpha = 1;
        sunWordShow.alpha = 1;
    }else if (picker.mode == 1)
    {
        
        moonTimeText.alpha = 1;
        moonWordShow.alpha = 1;
        
    }
    
    //[self.view bringSubviewToFront:sunTimeText];
    [UIView commitAnimations];
    
}
@end
