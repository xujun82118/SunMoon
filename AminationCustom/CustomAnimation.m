//
//  CustomAnimation.m
//  SunMoon
//
//  Created by xujun on 15-1-22.
//  Copyright (c) 2015年 xujun. All rights reserved.
//

#import "CustomAnimation.h"

@implementation CustomAnimation
@synthesize aniType = _aniType;
@synthesize bkLayer = _bkLayer;
@synthesize aniLayer = _aniLayer;
@synthesize aniImageView =_aniImageView;
@synthesize aniImage = _aniImage;
@synthesize aniStartSize = _aniStartSize;
@synthesize aniEndSize = _aniEndSize;
@synthesize aniStartPoint = _aniStartPoint;
@synthesize aniEndpoint = _aniEndpoint;
@synthesize aniRepeatCount = _aniRepeatCount;
@synthesize anikey = _anikey;
@synthesize aniDuration = _aniDuration;
@synthesize aniCurrentpoint=_aniCurrentpoint;

@synthesize aniBazierCenterPoint1 = _aniBazierCenterPoint1;
@synthesize aniBazierCenterPoint2 = _aniBazierCenterPoint2;


@synthesize aniKeyFrame = _aniKeyFrame;
@synthesize aniKeyframePointArray = _aniKeyframePointArray;
@synthesize aniKeyframePointCount = _aniKeyframePointCount;



//-(instancetype)initCustomAnimation
//{
//    
//    self = [super init];
//    if (!self) {
//        return nil;
//    }
//
//    _aniLayer=[[CALayer alloc]init];
//    
//    return self;
//    
//}

-(instancetype)initCustomAnimationWithSrcView:(UIImageView*) srcView
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _aniLayer=[[CALayer alloc]init];
    _aniImageView = srcView;
    
    return self;
}


- (void)setBkLayer:(CALayer *)layer
{
    _bkLayer = layer;
    NSAssert((_bkLayer), @"_bkLayer == nil, it must be set before _aniLayer");
    [_bkLayer addSublayer:_aniLayer];

}


-(void) startCustomAnimation
{
    
    //设置动画内容
    _aniLayer.position=_aniStartPoint;
    _aniLayer.anchorPoint=CGPointMake(0.5, 0.5);
    _aniLayer.contents=(id)_aniImage.CGImage;
    _aniLayer.opacity=1;
    _aniLayer.bounds=CGRectMake(0, 0, _aniStartSize.width,_aniStartSize.height);
    
    if (_aniType == BEZIER_ANI_TYPE) {
        [self bazierCustomAnimation];
    }
    
    
    if (_aniType == LINE_ANI_TYPE) {
        [self bazierCustomAnimation];
    }
    
    if (_aniType == KEY_FRAME_POSION_TYPE) {
        [self keyFramePostionAnimation];
    }
    
    
}


-(void) keyFramePostionAnimation
{
    //1.创建关键帧动画并设置动画属性
    _aniKeyFrame=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置关键帧
    //加入开始，与结束位置
    [_aniKeyframePointArray insertObject:[NSValue valueWithCGPoint:_aniStartPoint] atIndex:0];
    [_aniKeyframePointArray insertObject:[NSValue valueWithCGPoint:_aniEndpoint] atIndex:_aniKeyframePointArray.count];
    _aniKeyFrame.values=_aniKeyframePointArray;

    //设置其他属性
    _aniKeyFrame.duration=_aniDuration;
    
    NSValue* endValue = _aniKeyframePointArray.lastObject;
    [_aniKeyFrame setValue:endValue forKey:@"animation_coustom_end_point"];
    _aniKeyFrame.delegate = self;
    _aniKeyFrame.removedOnCompletion = YES;


    //设置随机帧时间
    NSMutableArray* keyFrameTimeArray =[NSMutableArray arrayWithCapacity:_aniKeyframePointCount];
    //第1帧时间
    [keyFrameTimeArray addObject:[NSNumber numberWithFloat:0.0]];
    //中间n-2帧时间，把0.0到0.9分成n-2份
    float sTimeAdd;
    NSInteger n =_aniKeyframePointCount-2;
    float everyTime = (0.9-0.0)/n;
    for (int i = 0; i<n; i++) {
        
        sTimeAdd = everyTime * (i+1);
        NSNumber *sTime = [NSNumber numberWithFloat:(sTimeAdd)];
        [keyFrameTimeArray addObject:sTime];
    }
    //最后一帧时间，保证设定总时间内完成
    [keyFrameTimeArray addObject:[NSNumber numberWithFloat:1.0]];
    _aniKeyFrame.keyTimes = keyFrameTimeArray;
    _aniKeyFrame.repeatCount = _aniRepeatCount;
    
    
    //3.添加动画到图层，添加动画后就会执行动画
    [_aniLayer addAnimation:_aniKeyFrame forKey:_anikey];
    
    
}

-(void)  setAniKeyframePoint:(CGPoint) setPoint
{
    if (!_aniKeyframePointArray) {
        _aniKeyframePointArray = [NSMutableArray arrayWithCapacity:_aniKeyframePointCount];

    }
    
    [_aniKeyframePointArray addObject:[NSValue valueWithCGPoint:setPoint]];
    
    
}

-(void) bazierCustomAnimation
{
    

    //1.创建关键帧动画并设置动画属性
    _aniKeyFrame=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置路径
    //绘制贝塞尔曲线
    CGMutablePathRef  path=CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, _aniStartPoint.x, _aniStartPoint.y);//移动到起始点

    if (CGPointEqualToPoint(_aniBazierCenterPoint2, CGPointZero)) {
        CGPathAddQuadCurveToPoint(path, NULL, _aniBazierCenterPoint1.x, _aniBazierCenterPoint1.y,_aniEndpoint.x, _aniEndpoint.y);
    }else
    {
        CGPathAddCurveToPoint(path, NULL, _aniBazierCenterPoint1.x, _aniBazierCenterPoint1.y,_aniBazierCenterPoint2.x, _aniBazierCenterPoint2.y,_aniEndpoint.x, _aniEndpoint.y);
    }
    

    
    _aniKeyFrame.path=path;//设置path属性
    CGPathRelease(path);//释放路径对象
    //设置其他属性
    _aniKeyFrame.duration=_aniDuration;
    //keyframeAnimation.beginTime=CACurrentMediaTime()+2;//设置延迟2秒执行
    _aniKeyFrame.repeatCount = _aniRepeatCount;
    _aniKeyFrame.delegate = self;
    _aniKeyFrame.removedOnCompletion = YES;

    
    [_aniKeyFrame setValue:[NSValue valueWithCGPoint:_aniEndpoint] forKey:@"animation_coustom_end_point"];
    
    //3.添加动画到图层，添加动画后就会执行动画
    [_aniLayer addAnimation:_aniKeyFrame forKey:_anikey];
    
    
}


-(void) lineCustomAnimation
{
    
    
    
}


-(void) getAniCurrentpoint
{
    
    _aniCurrentpoint = _aniLayer.position;
}

#pragma mark - 动画代理方法
#pragma mark 动画开始
-(void)animationDidStart:(CAAnimation *)anim
{
    //NSLog(@"animation(%@) start.\r_aniLayer.frame=%@",anim,NSStringFromCGRect(_aniLayer.frame));
    
    //通过前面的设置的key获得动画
    //NSLog(@"%@",[_aniLayer animationForKey:_anikey]);
    
    //隐藏原view
    _aniImageView.alpha =  0.0;

    
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //NSLog(@"%@",[_aniLayer animationForKey:_animationkey]);
    
    //开启事务
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
    _aniLayer.position=[[anim valueForKey:@"animation_coustom_end_point"] CGPointValue];
    
    //NSLog(@"_aniLayer.position  end = %@",NSStringFromCGPoint(_aniLayer.position));
    
    //移动原view到终点位置
    [_aniImageView setFrame:CGRectMake(_aniLayer.position.x-_aniEndSize.width/2, _aniLayer.position.y-_aniEndSize.height/2, _aniEndSize.width, _aniEndSize.height)];
    _aniImageView.alpha =  1.0;
    
    //提交事务
    [CATransaction commit];
    
    //显示的是_aniImageView，_aniLayer要移除
    [_aniLayer removeFromSuperlayer];
    
    [self.customAniDelegate customAnimationFinishedRuturn:_anikey srcView:_aniImageView];
    
    
}

@end
