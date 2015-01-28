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
    
    //_layer.contents=_aminationImageView.layer.contents;
    _layer.contents=(id)_aminationImageView.image.CGImage;

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

/*
-(void) moveLightWithIsUseRepeatCountWith:(BOOL) isUseRepeatCount
{
    NSLog(@"移动 %d 个月光", _useRepeatCount);
    
    if (!_aminationImageView.image) {
        _aminationImageView.image =[UIImage imageNamed:_imageName];
        
    }
    [_aminationImageView setCenter:_startPoint];
    _aminationImageView.alpha = 1.0;
    _aminationImageView.hidden =  YES;
    
    
    _layer.position=_startPoint;
    _layer.anchorPoint=CGPointMake(0.5, 0.5);
    _layer.contents=(id)_aminationImageView.image;
    _layer.opacity=1;
    _layer.bounds=CGRectMake(0, 0, _aminationImageViewframe.size.width, _aminationImageViewframe.size.height);
    
    //_layer.contents=_aminationImageView.layer.contents;
    
    //    if (CGRectEqualToRect(_layer.frame, CGRectZero))
    //    {
    //        _layer.frame=_aminationImageViewframe;
    //    }
    
    //添加动画图层到根图层
    [_bkView.layer addSublayer:_layer];
    
    //创建关键帧动画并设置动画属性
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //设置路径,绘制贝塞尔曲线
    //动画 终点 都以sel.view为参考系
    UIBezierPath *path=[UIBezierPath bezierPath];
    CGPoint endpoint=[_bkView convertPoint:_endpoint fromView:nil];
    //动画起点
    CGPoint startPoint=[_bkView convertPoint:_startPoint fromView:nil];
    [path moveToPoint:startPoint];
    //贝塞尔曲线中间点
    float sx=startPoint.x;
    float sy=startPoint.y;
    float ex=endpoint.x;
    float ey=endpoint.y;
    float x=sx+(ex-sx)/3;
    float y=sy+(ey-sy)*0.5;
    CGPoint centerPoint=CGPointMake(x,y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    
    
    animation.path = path.CGPath;
    //animation.removedOnCompletion = NO;
    //animation.fillMode = kCAFillModeForwards;
    animation.duration=1.0;
    animation.delegate=self;
    animation.repeatCount = _useRepeatCount;
    animation.repeatDuration = 1;
    animation.autoreverses= NO;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.beginTime=CACurrentMediaTime()+2;//设置延迟2秒执行
    
    if (_useRepeatCount>10) {
        animation.repeatDuration = 5*0.6;
        
    }
    
    [animation setValue:[NSValue valueWithCGPoint:endpoint] forKey:@"animation_coustom_end_point"];
    
    
    [_layer addAnimation:animation forKey:_animationkey];
    
}
*/

#pragma mark - 动画代理方法
#pragma mark 动画开始
-(void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"animation(%@) start.\r_layer.frame=%@",anim,NSStringFromCGRect(_layer.frame));
    
    //通过前面的设置的key获得动画
    NSLog(@"%@",[_layer animationForKey:_animationkey]);
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //NSLog(@"%@",[_layer animationForKey:_animationkey]);
    
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
    _layer.position=[[anim valueForKey:@"animation_coustom_end_point"] CGPointValue];
    //提交事务
    [CATransaction commit];
    
    //重置view到动画结束的位置
    _aminationImageView.frame = CGRectMake(_endpoint.x-_aminationImageView.frame.size.width/2, _endpoint.y-_aminationImageView.frame.size.height/2, _aminationImageView.frame.size.width, _aminationImageView.frame.size.height);
    _aminationImageView.hidden =  NO;

    
    [self.aminationCustomDelegate animationFinishedRuturn:_animationkey aniView:_aminationImageView];
    
    
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

-(instancetype)initWithKey:(NSString*) key withAnimationView:(UIImageView*) aniView
{
    
    self = [super init];
    if (!self) {
        return nil;
    }

    
    if (!aniView) {
        return nil;
    }
    
    _animationkey = key;
    _layer=[[CALayer alloc]init];
    _layer.frame=aniView.frame;
    _aminationImageView =aniView;
    
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
