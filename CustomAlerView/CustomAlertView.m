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
@synthesize msgLabel=_msgLabel;
@synthesize alertMsg=_alertMsg;
@synthesize MsgFrontSize=_MsgFrontSize;
@synthesize delayDisappearTime = _delayDisappearTime, startAlpha=_startAlpha,endAlpha=_endAlpha,startCenterPoint=_startCenterPoint,endCenterPoint=_endCenterPoint,startWidth=_startWidth,startHeight=_startHeight,endWidth=_endWidth, endHeight=_endHeight;


-(instancetype) InitCustomAlertViewWithSuperView:(UIView*) superView  bkImageName:(NSString*) bkImage yesBtnImageName:(NSString*) btnImage posionShowMode:(CustomAlertShowMode) mode
{
    
    _superView = superView;
    
    UIImage *tempImage = [UIImage imageNamed:bkImage];
    _viewBkImageView = [[UIImageView alloc] initWithImage:tempImage];
    _viewBkImageView.hidden = YES;
    [_superView addSubview:_viewBkImageView];
    
    
    NSInteger msgLabelWidth = _endWidth;
    NSInteger msgLabelHeigth =80;
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(_superView.center.x-msgLabelWidth/2, _superView.center.y-msgLabelHeigth/2, msgLabelWidth, msgLabelHeigth)];
    //设置标签文本字体和字体大小
    _msgLabel.font = [UIFont fontWithName:@"Arial" size:25];
    _msgLabel.textColor = [UIColor blackColor];
    _msgLabel.backgroundColor = [UIColor redColor];
    
    //设置文本对其方式
    _msgLabel.textAlignment = NSTextAlignmentCenter;
    //设置字体大小适应label宽度
    _msgLabel.adjustsFontSizeToFitWidth = YES;
    _msgLabel.numberOfLines = 3;
    _msgLabel.hidden = YES;
    [_superView addSubview:_msgLabel];
    
    if (btnImage) {
        NSInteger yesW =_viewBkImageView.frame.size.width/5*2;
        NSInteger yesH =yesW;
        UIImage *tempImage1 = [UIImage imageNamed:btnImage];
        _yesBtn = [[UIButton alloc] initWithFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH, yesW, yesH)];
        [_yesBtn setImage:tempImage1 forState:UIControlStateNormal];
        
        [_yesBtn addTarget:self action:@selector(yesButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        _yesBtn.hidden = YES;
        [_superView addSubview:_yesBtn];

    }

    //显示模式设置
    _selfMode = mode;
    if (mode == viewCenterBig) {
        _startCenterPoint = _superView.center;
        _endCenterPoint = _superView.center;
        _startWidth = 0;
        _startHeight = 0;
        _endWidth = SCREEN_WIDTH/5*4;
        _endHeight =_endWidth;
        _startAlpha = 0.0;
        _endAlpha = 1.0;
        _MsgFrontSize = 25;
        _delayDisappearTime = 5.0;
    }

    
    return self;
    
}

- (void)yesButtonHandler:(id)sender
{
   
    //回到原位
    [UIView beginAnimations:@"cutomeAlert_backPostion" context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
    [_viewBkImageView setFrame:CGRectMake(_startCenterPoint.x-_startWidth/2, _startCenterPoint.y-_startHeight/2, _startWidth, _startHeight)];
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/8;
        NSInteger yesH =yesW;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH, yesW, yesH)];
    }
    
    [UIView commitAnimations];

    
    if ([_customAlertDelegate respondsToSelector:@selector(CustomAlertOkReturn)]) {
        //test
        [_customAlertDelegate CustomAlertOkReturn];
    }
    
}


-(void) RunCumstomAlert
{
    
    
    //将msg以水印形式加上，把label变成图片
    //显示消息
    _msgLabel.frame = CGRectMake(0,0, _viewBkImageView.frame.size.width, 40);
    _msgLabel.text =  _alertMsg;
    _msgLabel.font = [UIFont fontWithName:@"Arial" size:_MsgFrontSize];


    //构造水印图
    NSInteger w = _viewBkImageView.frame.size.width;
    NSInteger h = _viewBkImageView.frame.size.height/5*2;
    NSInteger x = 0;
    NSInteger y = _viewBkImageView.frame.size.height/2-h/2;

    UIGraphicsBeginImageContext(_viewBkImageView.image.size);
    [_viewBkImageView.image drawInRect:CGRectMake(0, 0, _viewBkImageView.image.size.width,_viewBkImageView.image.size.height)];
    
    [_msgLabel drawTextInRect:CGRectMake(x,y,w,h)];
    _viewBkImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    

    
    //动画起点frame
    [_viewBkImageView setFrame:CGRectMake(_startCenterPoint.x-_startWidth/2, _startCenterPoint.y-_startHeight/2, _startWidth, _startHeight)];
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/8;
        NSInteger yesH =yesW;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH, yesW, yesH)];
    }
    
    //开始动画
    [UIView beginAnimations:@"cutomeAlert" context:nil];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationCustomAlert:finished:context:)];
    NSLog(@"Show alert custom!");
    [_viewBkImageView setFrame:CGRectMake(_endCenterPoint.x-_endWidth/2, _endCenterPoint.y-_endHeight/2, _endWidth, _endHeight)];
    _viewBkImageView.hidden = NO;
    
    if (_yesBtn) {
        NSInteger yesW =_viewBkImageView.frame.size.width/6*1;
        NSInteger yesH =yesW;
        [_yesBtn setFrame:CGRectMake(_viewBkImageView.frame.origin.x+_viewBkImageView.frame.size.width/2-yesW/2, _viewBkImageView.frame.origin.y+_viewBkImageView.frame.size.height-yesH-_viewBkImageView.frame.size.height/8, yesW, yesH)];
        _yesBtn.hidden = NO;
    }
    
    [UIView commitAnimations];
    
}

- (void)animationCustomAlert:(NSString *)animationID finished:(NSNumber *)finished context:(void *) contextImage
{
    
    if ([animationID isEqualToString:@"cutomeAlert_backPostion"])
    {
        _viewBkImageView.hidden = YES;
        _yesBtn.hidden = YES;
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


@end
