//
//  AminationCustom.m
//  SunMoon
//
//  Created by songwei on 14-6-28.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "AminationCustom.h"

@implementation AminationCustom

BOOL isStartAnimation;

@synthesize layer = _layer,aminationCustomDelegate = _aminationCustomDelegate, aminationImageView = _aminationImageView, startPoint = _startPoint, endpoint = _endpoint, centerPoint = _centerPoint, useRepeatCount=_useRepeatCount,bkView=_bkView, animationkey=_animationkey, imageName=_imageName, aminationImageViewframe=_aminationImageViewframe;




-(void) moveLightWithIsUseRepeatCount:(BOOL) isUseRepeatCount
{
    NSLog(@"移动 %d 个月光", _useRepeatCount);

    _aminationImageView.image =[UIImage imageNamed:_imageName];
    [_aminationImageView setCenter:_startPoint];
    _aminationImageView.alpha = 1.0;
    _aminationImageView.hidden =  YES;
    
    _layer.contents=_aminationImageView.layer.contents;
    _layer.frame=_aminationImageViewframe;
    _layer.opacity=1;
    [_bkView.layer addSublayer:_layer];
    //动画 终点 都以sel.view为参考系
    CGPoint endpoint=[_bkView convertPoint:_endpoint fromView:nil];
    UIBezierPath *path=[UIBezierPath bezierPath];
    //动画起点
    CGPoint startPoint=[_bkView convertPoint:_startPoint fromView:nil];
    [path moveToPoint:startPoint];
    //贝塞尔曲线中间点
    float sx=startPoint.x;
    float sy=startPoint.y;
    float ex=endpoint.x;
    float ey=endpoint.y;
    float x=sx+(ex-sx)/3;
    float y=sy+(ey-sy)*0.5-100;
    CGPoint centerPoint=CGPointMake(x,y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration=1.0;
    animation.delegate=self;
    animation.repeatCount = _useRepeatCount;
    animation.repeatDuration = 1;
    animation.autoreverses= NO;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    if (_useRepeatCount>10) {
        animation.repeatDuration = 5*0.6;
        
    }
    [_layer addAnimation:animation forKey:_animationkey];
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _layer.hidden = YES;
    [self.aminationCustomDelegate animationFinishedRuturn];
    
}


-(instancetype)initWithKey:(NSString*) key
{
    if (!self) {
        return nil;
    }
    
    _animationkey = key;
    _layer=[[CALayer alloc]init];
    _aminationImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"空白图"]];
    
    return self;
}




-(CALayer*)layerWithImageView:(UIImageView*) aminaView
{

    _layer =[[CALayer alloc]init];

    aminaView.contentMode=UIViewContentModeScaleToFill;
    aminaView.hidden=YES;
    aminaView.center=_startPoint;
    _layer.contents=aminaView.layer.contents;
    _layer.frame=aminaView.frame;
    _layer.opacity=1;
    
    return  _layer;
    
}

-(void)startBezierAmination:(NSString*) key
{
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:_startPoint];
    [path addQuadCurveToPoint:_endpoint controlPoint:_centerPoint];
    

    self.path = path.CGPath;
    self.removedOnCompletion = YES;
    self.fillMode = kCAFillModeForwards;
    self.autoreverses= NO;
    self.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_layer addAnimation:self forKey:key];
    
    
}

@end
