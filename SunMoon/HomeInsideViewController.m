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


@interface HomeInsideViewController ()

@end

@implementation HomeInsideViewController

@synthesize user,userData,sunWordShow,moonWordShow,currentSelectDataSun,currentSelectDataMoon;
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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.opaque = YES; 
    //self.navigationController.toolbarHidden = NO;
    //self.navigationController.toolbar.barStyle =UIBarStyleDefault;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"HomeInside_0000s_0002_上部-底图.png"] forBarMetrics:UIBarMetricsDefault];
//   
//  [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"HomeInside_0000s_0002_上部-底图.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    
//    UIImage *toolBarIMG = [UIImage imageNamed: @"HomeInside_0000s_0002_上部-底图.png"];
//    
//    if ([self.navigationController.toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)]) {
//        [self.navigationController.toolbar setBackgroundImage:toolBarIMG forToolbarPosition:0 barMetrics:0];
//    }

    
    //获取单例用户数据
    self.user= [UserInfo  sharedSingleUserInfo];
    self.userData  = self.user.userDataBase;
    

    

    //[self.navigationItem setNewTitle:@"测试"];
    [self.navigationItem setRightItemWithTarget:self  action:@selector(back) image:@"HomeInside_0000s_0001_设置.png"];
    
    [self.navigationItem setLeftItemWithTarget:self  action:@selector(back) image:@"HomeInside_0000s_0000_返回.png"];

    
    NSInteger count = [userData count];
    NSMutableArray *setSun = [[NSMutableArray alloc] init];
    NSMutableArray *setMoon = [[NSMutableArray alloc] init];
    if (count>0) {
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            //构造带时间的照片
            //UIImage* addImageBk = [self addTimeToImage:[UIImage imageNamed:@"相框.png"] withTime:userInfo.sun_image_name];
            //UIImage* addImage = [self addToImage:[UIImage imageWithData:userInfo.sun_image] withBkImage:addImageBk];
            //传入dictionary，以携带更多信息
            UIImage* addImage = [UIImage imageWithData:userInfo.sun_image];
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               addImage,@"image_data",
                               userInfo.sun_image_name,@"image_name_time",//name 即为时间
                               userInfo.current_sun_sentence,@"image_sentence",
                               nil]];
            
        }
        
        for (int i = 0; i < count; i++) {
            UserInfo* userInfo = nil;
            userInfo = [userData objectAtIndex:i];
            UIImage* addImage = [UIImage imageWithData:userInfo.moon_image];
            //传入dictionary，以携带更多信息
            [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               addImage,@"image_data",
                               userInfo.moon_image_name,@"image_name_time",//name 即为时间
                               userInfo.current_moon_sentence,@"image_sentence",
                               nil]];

        }
        
    }

    
    //目前最多支持8张相片，超过8张的用默认图片填充
    if (count<8) {
        int temp = 1, temp1=1;
        for (int i = count; i<8; i++) {
            [setSun addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                               [UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",temp++]],@"image_data",
                               @"NULL",@"image_name_time",
                               @"等你",@"image_sentence",
                               nil]];
            [setMoon addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageNamed:[NSString stringWithFormat:@"scroll-%d.png",temp1++]],@"image_data",
                                @"NULL",@"image_name_time",
                                @"等你",@"image_sentence",
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


    //取得时间轴的相对位置
    UIImageView* scrollPosition = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_SUN];
    //如果时间轴高度小于相片的高度，则缩小相片,使时间轴包进相片
//    if (scrollPosition.frame.size.height<=size.height) {
//        float rat = size.width/size.height;
//        size.height = scrollPosition.frame.size.height -5;
//        size.width = size.height*rat;
//        
//    }
    imageScrollSun = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition.frame.origin.y-15, SREEN_WIDTH, 100)];
    [imageScrollSun setImageAry:setSun];
    [imageScrollSun setItemSize:size];
    [imageScrollSun setHeightOffset:30];
    [imageScrollSun setPositionRatio:2];
    [imageScrollSun setAlphaOfobjs:0.8];
    [imageScrollSun setMode:0];
    [imageScrollSun setScrollDelegate:self];
    [self.view addSubview:imageScrollSun];
    
    
    NSLog(@"imageview (%f,%f,%f,%f)", imageScrollSun.frame.origin.x,imageScrollSun.frame.origin.y, imageScrollSun.frame.size.width,imageScrollSun.frame.size.height);
    
    UIImageView* scrollPosition1 = (UIImageView*)[self.view viewWithTag:TAG_TIME_SCROLL_MOON];
    imageScrollMoon = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, scrollPosition1.frame.origin.y-15, SREEN_WIDTH, 100)];
    [imageScrollMoon setImageAry:setMoon];
    [imageScrollMoon setItemSize:size];
    [imageScrollMoon setHeightOffset:30];
    [imageScrollMoon setPositionRatio:2];
    [imageScrollMoon setAlphaOfobjs:0.8];
    [imageScrollMoon setMode:1];
    [imageScrollMoon setScrollDelegate:self];
    [self.view addSubview:imageScrollMoon];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    
    
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
    
    NSString* shareMsg;
  
    UIImageView* imageData = [currentSelectDataMoon objectForKey:@"image_data"];
    NSString* imageName = [currentSelectDataMoon objectForKey:@"image_name"];
    
    NSString * preString = NSLocalizedString(@"FromUri", @"");
    shareMsg = [imageName stringByAppendingString:preString];
    
    
    shareMsg =[@"晚安，送上我的月光语录：" stringByAppendingString:shareMsg];
    
    NSInteger contentType;
    if (imageData.image && shareMsg) {
        contentType = SSPublishContentMediaTypeNews;
        
        //加水印LOG
        AddWaterMask* addWaterMask = [AddWaterMask alloc];
        imageData.image =[addWaterMask addImage:imageData.image addMsakImage:[UIImage imageNamed:@"waterlogo.png"]];
        
    }else{
        contentType = SSPublishContentMediaTypeText;
    }
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareMsg
                                       defaultContent:@"没有分享内容"
                                                image:[ShareSDK jpegImageWithImage:imageData.image
                                                                           quality:CGFLOAT_DEFINED]
                                                title:@"天天更美丽"
                                                  url:@"null"
                                          description:nil
                                            mediaType:contentType];
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
                          ShareTypeSinaWeibo,
                          ShareTypeTencentWeibo,
                          ShareTypeQQ,
                          ShareTypeCopy,
                          nil];
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}


/**
 * @brief 分享晚上选中的相片
 *
 */- (IBAction)shareMorning:(id)sender {
     
     NSString* shareMsg;
     
     UIImageView* imageData = [currentSelectDataSun objectForKey:@"image_data"];
     NSString* imageName = [currentSelectDataSun objectForKey:@"image_name"];
     
     NSString * preString = NSLocalizedString(@"FromUri", @"");
     shareMsg = [imageName stringByAppendingString:preString];
     
     
     shareMsg =[@"早安，送上我的阳光语录：" stringByAppendingString:shareMsg];
     
     NSInteger contentType;
     if (imageData.image && shareMsg) {
         contentType = SSPublishContentMediaTypeNews;
         
         //加水印LOG
         AddWaterMask* addWaterMask = [AddWaterMask alloc];
         imageData.image =[addWaterMask addImage:imageData.image addMsakImage:[UIImage imageNamed:@"waterlogo.png"]];
         
     }else{
         contentType = SSPublishContentMediaTypeText;
     }
     
     //构造分享内容
     id<ISSContent> publishContent = [ShareSDK content:shareMsg
                                        defaultContent:@"没有分享内容"
                                                 image:[ShareSDK jpegImageWithImage:imageData.image
                                                                            quality:CGFLOAT_DEFINED]
                                                 title:@"天天更美丽"
                                                   url:@"null"
                                           description:nil
                                             mediaType:contentType];
     NSArray *shareList = [ShareSDK getShareListWithType:
                           ShareTypeWeixiSession,
                           ShareTypeWeixiTimeline,
                           ShareTypeSinaWeibo,
                           ShareTypeTencentWeibo,
                           ShareTypeQQ,
                           ShareTypeCopy,
                           nil];
     [ShareSDK showShareActionSheet:nil
                          shareList:shareList
                            content:publishContent
                      statusBarTips:YES
                        authOptions:nil
                       shareOptions: nil
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 if (state == SSResponseStateSuccess)
                                 {
                                     NSLog(@"分享成功");
                                 }
                                 else if (state == SSResponseStateFail)
                                 {
                                     NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                 }
                             }];
     
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

#pragma mark - 选择了其中一张照片
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



#pragma mark - InfiniteScrollPickerDelegate
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
