//
//  CustomAlertView.m
//  SunMoon
//
//  Created by songwei on 14-8-10.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "CustomAlertView.h"
#import "AddWaterMask.h"

@implementation CustomAlertView
@synthesize selfMode=_selfMode;
@synthesize customAlertDelegate=_customAlertDelegate;
@synthesize viewBkImageView=_viewBkImageView, yesBtn=_yesBtn;
@synthesize msgLabel=_msgLabel,alertKey=_alertKey;
@synthesize alertMsg=_alertMsg;
@synthesize MsgFrontSize=_MsgFrontSize;
@synthesize delayDisappearTime = _delayDisappearTime, startAlpha=_startAlpha,endAlpha=_endAlpha,startCenterPoint=_startCenterPoint,endCenterPoint=_endCenterPoint,startWidth=_startWidth,startHeight=_startHeight,endWidth=_endWidth, endHeight=_endHeight;


-(instancetype) InitCustomAlertViewWithSuperView:(UIView*) superView  taget:(id) superSelf  bkImageName:(NSString*) bkImage yesBtnImageName:(NSString*) btnImage  posionShowMode:(CustomAlertShowMode) mode AlertKey:alertKey;

{
    
    _superView = superView;
    _alertKey = alertKey;
    
    //初始化，此时大小等未指定
    UIImage *tempImage = [UIImage imageNamed:bkImage];
    _viewBkImageView = [[UIImageView alloc] initWithImage:tempImage];
    _viewBkImageView.hidden = YES;
    [_superView addSubview:_viewBkImageView];
    
    //初始化默认值
    NSInteger msgLabelWidth = _endWidth;
    NSInteger msgLabelHeigth =80;
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(_superView.center.x-msgLabelWidth/2, _superView.center.y-msgLabelHeigth/2, msgLabelWidth, msgLabelHeigth)];
    _msgLabel = [[UILabel alloc] init];
    _msgLabel.font = [UIFont fontWithName:@"Arial" size:35];
    _msgLabel.textColor = [UIColor blackColor];
    _msgLabel.backgroundColor = [UIColor redColor];
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    _msgLabel.adjustsFontSizeToFitWidth = YES;
    _msgLabel.numberOfLines = 3;
    _msgLabel.hidden = YES;
    [_superView addSubview:_msgLabel];
    
    if (btnImage) {
        NSInteger yesW =_viewBkImageView.frame.size.width/5*4;
        NSInteger yesH =_viewBkImageView.frame.size.height/5*1;
        UIImage *tempImage1 = [UIImage imageNamed:btnImage];
        //需先初始化frame, 否则动时就立刻显示，原因不明？？
        _yesBtn = [[UIButton alloc] initWithFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH, yesW, yesH)];
        //_yesBtn = [[UIButton alloc] init];
        [_yesBtn setImage:tempImage1 forState:UIControlStateNormal];
        
        [_yesBtn addTarget:superSelf action:@selector(yesButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        _yesBtn.hidden = YES;
        _yesBtn.tag = TAG_CUSTOM_ALER_BTN;
        [_superView addSubview:_yesBtn];

    }

    //显示模式设置
    _selfMode = mode;
 
    return self;
    
}


- (void)yesButtonHandler:(id)sender
{
   
    //回到原位
    [UIView beginAnimations:@"cutomeAlert_backPostion" context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
    [_viewBkImageView setFrame:CGRectMake(_startCenterPoint.x-_startWidth/2, _startCenterPoint.y-_startHeight/2, _startWidth, _startHeight)];
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/6*5;
        NSInteger yesH =0;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH, yesW, yesH)];
    }
    
    [UIView commitAnimations];

    //打开消息
    [self EnableUserInteractionInView:_superView];
    

    
}


-(void) RunCumstomAlert
{

    //将msg以水印形式加上，把label变成图片
    //先构造结束态的底图
    [_viewBkImageView setFrame:CGRectMake(_endCenterPoint.x-_endWidth/2, _endCenterPoint.y-_endHeight/2, _endWidth, _endHeight)];
    //在结束态的底图上加上label水印
    _msgLabel.frame = CGRectMake(0,0, _viewBkImageView.frame.size.width, _endHeight);
    _msgLabel.text =  _alertMsg;
    _msgLabel.font = [UIFont fontWithName:@"Arial" size:_MsgFrontSize];

    //构造水印图
    NSInteger x = 40;
    NSInteger w = _viewBkImageView.image.size.width-x*2;
    NSInteger h = _viewBkImageView.image.size.height/7*6;
    //NSInteger h = _endHeight*5;
    NSInteger y = _viewBkImageView.image.size.height/2-h/2;

    UIGraphicsBeginImageContext(CGSizeMake(_viewBkImageView.image.size.width, _viewBkImageView.image.size.height));
    [_viewBkImageView.image drawInRect:CGRectMake(0, 0, _viewBkImageView.image.size.width,_viewBkImageView.image.size.height)];
    
    [_msgLabel drawTextInRect:CGRectMake(x,y,w,h)];
    _viewBkImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //动画起点frame
    [_viewBkImageView setFrame:CGRectMake(_startCenterPoint.x-_startWidth/2, _startCenterPoint.y-_startHeight/2, _startWidth, _startHeight)];
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/6*5;
        NSInteger yesH =0;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH-_viewBkImageView.frame.size.height/8, yesW, yesH)];

    }
    
    //开始动画
    [UIView beginAnimations:@"cutomeAlert" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
    NSLog(@"Show alert custom!");
    [_viewBkImageView setFrame:CGRectMake(_endCenterPoint.x-_endWidth/2, _endCenterPoint.y-_endHeight/2, _endWidth, _endHeight)];
    _viewBkImageView.hidden = NO;
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/6*5;
        NSInteger yesH =_viewBkImageView.frame.size.height/5;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH-_viewBkImageView.frame.size.height/10, yesW, yesH)];
        _yesBtn.hidden = NO;
    }
    
    [UIView commitAnimations];
    
    
    //有按钮时，禁消息
    if (_yesBtn) {
        
        [self DisableUserInteractionInView:_superView exceptViewWithTag:_yesBtn.tag];

    }

    
}

- (void)animationCustomAlert:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    
    if ([animationID isEqualToString:@"cutomeAlert_backPostion"])
    {
        _viewBkImageView.hidden = YES;
        _yesBtn.hidden = YES;
        [_viewBkImageView removeFromSuperview];
        [_yesBtn removeFromSuperview];
        
        if (_yesBtn) {
            //动画完成后，再回调
            if ([_customAlertDelegate respondsToSelector:@selector(CustomAlertOkAnimationFinish:)]) {
                //test
                [_customAlertDelegate CustomAlertOkAnimationFinish:_alertKey];
            }
        }
        
    }
    
    if ([animationID isEqualToString:@"cutomeAlert"])
    {
        
        if (_yesBtn) {
            
            
        }else
        {
            
            
            
            //延迟消失
            [UIView beginAnimations:@"cutomeAlert_Dis" context:nil];
            [UIView setAnimationDuration:_delayDisappearTime];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
            NSLog(@"Show alert custom for cutomeAlert_Dis!");
            _viewBkImageView.alpha = 0.0;
            _msgLabel.alpha = 0.0;
            [UIView commitAnimations];
            
        }
        
        
//        NSInteger msgLabelWidth = _endWidth;
//        NSInteger msgLabelHeigth =80;
//        [_msgLabel setFrame:CGRectMake(_superView.center.x-msgLabelWidth/2, _superView.center.y-msgLabelHeigth/2, msgLabelWidth, msgLabelHeigth)];
//        _msgLabel.text =  _alertMsg;
//        _msgLabel.alpha = 0.0;
//        [UIView beginAnimations:@"msgShow" context:nil];
//        [UIView setAnimationDuration:0.8f];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
//        _msgLabel.alpha = 1.0;
//        [UIView commitAnimations];
        
        
    }
    
    
    if ([animationID isEqualToString:@"msgShow"])
    {

        
    }
    
}

-(void) SetSelAction:(id)sender
{
    
    
}

#pragma mark get/show the UIView we want
- (UIView *)findView:(UIView *)aView withName:(NSString *)name {
	Class cl = [aView class];
	NSString *desc = [cl description];
    NSLog(@"---%@", desc);
	
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


- (void)DisableUserInteractionInView:(UIView *)superView exceptViewWithTag:(NSInteger)enableViewTag
{
	
	for (NSUInteger i = 0; i < [superView.subviews count]; i++) {
		UIView *subView = [superView.subviews objectAtIndex:i];
        if (subView.tag != enableViewTag) {
            [subView setUserInteractionEnabled:NO];
            //NSLog(@"Disable userinteraction with view tag: %d of view:%@", subView.tag, [[subView class] description]);
        }else
        {
            [subView setUserInteractionEnabled:YES];
            //NSLog(@"Enable userinteraction with view tag: %d of view:%@", subView.tag, [[subView class] description]);

        }
	}

}

- (void)EnableUserInteractionInView:(UIView *)superView
{
	
	for (NSUInteger i = 0; i < [superView.subviews count]; i++) {
		UIView *subView = [superView.subviews objectAtIndex:i];
        [subView setUserInteractionEnabled:YES];
	}
    

}

@end
