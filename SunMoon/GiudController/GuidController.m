//
//  GuidController.m
//  SunMoon
//
//  Created by songwei on 14-8-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "GuidController.h"


@implementation GuidController
{
    UIView* superView;
    UIImageView* touchView;
    
}


@synthesize guidStepNumber=_guidStepNumber;
@synthesize guidInfo=_guidInfo;
@synthesize guidStart=_guidStart;
@synthesize guidFinishIntroStartFirstOpen=_guidFinishIntroStartFirstOpen;
@synthesize guidFirstlyGiveLight=_guidFirstlyGiveLight;
@synthesize guidPanToBring=_guidPanToBring;
@synthesize guidPanToBring_waitForPan=_guidPanToBring_waitForPan;
@synthesize guidIntoCamera=_guidIntoCamera;
@synthesize guidIntoCamera_waitForTouch=_guidIntoCamera_waitForTouch;
@synthesize mainView_End=_mainView_End;
@synthesize camera_start=_camera_start;
@synthesize camera_End=_camera_End;

@synthesize guidHaveTakePhoto=_guidHaveTakePhoto;


static GuidController *sharedGuidCtl;

+ (GuidController *)sharedSingleUserInfo
{
    
    @synchronized(self)
    {
        if (!sharedGuidCtl)
        {
            sharedGuidCtl = [[GuidController alloc] init];
        }
        
        return sharedGuidCtl;
    }
}


- (id) init {
    self = [super init];
    
    _guidInfo = [NSUserDefaults standardUserDefaults];

    return self;
}




- (NSInteger)guidStepNumber {
    
    
    return [_guidInfo integerForKey:KEY_GUID_STEP_NUMBER];
    
}

//100:依次增1步, 1000:清0步开始
//其它指定步
-(void) setGuidStepNumber:(GuidStepNum) guidNum
{
    if (guidNum == guid_oneByOne) {
        
        NSInteger temp = ++_guidStepNumber;
        [_guidInfo setInteger:temp  forKey:KEY_GUID_STEP_NUMBER];
        _guidStepNumber = temp;

    }else if(guidNum == guid_backToStar)
    {
        [_guidInfo setInteger:guid_Start  forKey:KEY_GUID_STEP_NUMBER];
        _guidStepNumber = guid_Start;

    }else if(guidNum == guid_setNumber)
    {
        //指定为当前应执行的步
        [_guidInfo setInteger:_guidStepNumber  forKey:KEY_GUID_STEP_NUMBER];
        _guidStepNumber = _guidStepNumber;

    }
    
    [_guidInfo synchronize];
    
    NSLog(@"Guid Step current = %lu", _guidStepNumber);

    
}


- (BOOL)guidStart {
    
    return [_guidInfo boolForKey:KEY_GUID_START];
    
}

-(void) setGuidStart:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_START];
    [_guidInfo synchronize];
    
    _guidStart = isGuid;
    
    
}

- (BOOL)guidFinishIntroStartFirstOpen {
    
    return [_guidInfo boolForKey:KEY_GUID_finishIntro_Start_firstOpen];
    
}

-(void) setGuidFinishIntroStartFirstOpen:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_finishIntro_Start_firstOpen];
    [_guidInfo synchronize];
    
    _guidFinishIntroStartFirstOpen = isGuid;
    
    
}

- (BOOL)guidFirstlyGiveLight {
    
    return [_guidInfo boolForKey:KEY_GUID_giudStep_guidFirstlyGiveLight];
    
}

-(void) setGuidFirstlyGiveLight:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_giudStep_guidFirstlyGiveLight];
    [_guidInfo synchronize];
    
    _guidFirstlyGiveLight = isGuid;
    
    
}

- (BOOL)guidPanToBring {
    
    return [_guidInfo boolForKey:KEY_GUID_giudStep_guidPanToBring];
    
}

-(void) setGuidPanToBring:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_giudStep_guidPanToBring];
    [_guidInfo synchronize];
    
    _guidPanToBring = isGuid;
    
    
}

- (BOOL)guidPanToBring_waitForPan {
    
    return [_guidInfo boolForKey:KEY_GUID_guidPanToBring_waitForPan];
    
}

-(void) setGuidPanToBring_waitForPan:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_guidPanToBring_waitForPan];
    [_guidInfo synchronize];
    
    _guidPanToBring_waitForPan = isGuid;
    
    
}


- (BOOL)guidIntoCamera {
    
    return [_guidInfo boolForKey:KEY_GUID_guidIntoCamera];
    
}

-(void) setGuidIntoCamera:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_guidIntoCamera];
    [_guidInfo synchronize];
    
    _guidIntoCamera = isGuid;
    
    
}


- (BOOL)guidIntoCamera_waitForTouch {
    
    return [_guidInfo boolForKey:KEY_GUID_guidIntoCamera_waitForTouch];
    
}

-(void) setGuidIntoCamera_waitForTouch:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_guidIntoCamera_waitForTouch];
    [_guidInfo synchronize];
    
    _guidIntoCamera_waitForTouch = isGuid;
    
    
}

- (BOOL)mainView_End {
    
    return [_guidInfo boolForKey:KEY_GUID_mainView_End];
    
}

-(void) setMainView_End:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_mainView_End];
    [_guidInfo synchronize];
    
    _mainView_End = isGuid;
    
    
}

- (BOOL)camera_start {
    
    return [_guidInfo boolForKey:KEY_GUID_camera_start];
    
}

-(void) setCamera_start:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_camera_start];
    [_guidInfo synchronize];
    
    _camera_start = isGuid;
    
    
}


- (BOOL)camera_End {
    
    return [_guidInfo boolForKey:KEY_GUID_camera_End];
    
}

-(void) setCamera_End:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_camera_End];
    [_guidInfo synchronize];
    
    _camera_End = isGuid;
    
    
}

- (BOOL)guidHaveTakePhoto {
    
    return [_guidInfo boolForKey:KEY_GUID_HAVE_TAKE_PHOTO];
    
}

-(void) setGuidHaveTakePhoto:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_HAVE_TAKE_PHOTO];
    [_guidInfo synchronize];
    
    _guidHaveTakePhoto = isGuid;
    
    
}




-(void) AddTouchIndication:(UIView*) intoSuperView  TouchImageName:(NSString*) touchImageName  TouchFrame:(CGRect) touchedFrame
{
    superView = intoSuperView;
    
    CGFloat bigger = 25;
    
    CGRect biggerFrame = CGRectMake(touchedFrame.origin.x-bigger, touchedFrame.origin.y-bigger, touchedFrame.size.width+bigger*2, touchedFrame.size.height+bigger*2);
    if (!touchView) {
        touchView = [[UIImageView alloc] initWithFrame:biggerFrame];
    }else
    {
        touchView.frame =biggerFrame;
    }
    
    touchView.image = [UIImage imageNamed:touchImageName];
    touchView.alpha = 0.8;
    [superView addSubview:touchView];
    
}

-(void) RemoveTouchIndication
{
    
    [touchView removeFromSuperview];
}


@end
