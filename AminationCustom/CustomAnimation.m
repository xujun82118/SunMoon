//
//  CustomAnimation.m
//  SunMoon
//
//  Created by xujun on 15-1-22.
//  Copyright (c) 2015年 xujun. All rights reserved.
//

#import "CustomAnimation.h"

@implementation CustomAnimation
{
    int _index;
}
@synthesize aniType = _aniType;
@synthesize bkLayer = _bkLayer;
@synthesize aniLayer = _aniLayer;
@synthesize aniImageViewDic = _aniImageViewDic;
@synthesize aniImageView = _aniImageView;
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


@synthesize sipiriteArray=_sipiriteArray;
@synthesize sipiriteAnimationType=_sipiriteAnimationType;

@synthesize displayLink=_displayLink;
@synthesize displayLinkEnable=_displayLinkEnable;



-(instancetype)initCustomAnimation
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _aniLayer=[[CALayer alloc]init];
    
    _aniKeyframePointArray = [NSMutableArray arrayWithCapacity:0];

    
    _displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
    _displayLinkEnable = FALSE;
    
    return self;
}


- (void)setBkLayer:(CALayer *)layer
{
    _bkLayer = layer;
    NSAssert((_bkLayer), @"_bkLayer == nil, it must be set before _aniLayer");
    _bkLayerBelow =  _bkLayer;


}


-(void)setAniImageViewDic:(NSDictionary *)aniImageViewDic
{
    
    _aniImageViewDic = aniImageViewDic;
    _aniImageView = (UIImageView*)([_aniImageViewDic objectForKey:KEY_ANIMATION_VIEW]);
    aniImage = _aniImageView.image;
}

-(void) startCustomAnimation
{
    
    //设置动画内容
    _aniLayer.position=_aniStartPoint;
    _aniLayer.anchorPoint=CGPointMake(0.5, 0.5);
    _aniLayer.contents=(id)aniImage.CGImage;
    _aniLayer.opacity=1;
    _aniLayer.bounds=CGRectMake(0, 0, _aniStartSize.width,_aniStartSize.height);
    [self addAniLayer];


    
    if (_aniType == BEZIER_ANI_TYPE) {
        [self bazierCustomAnimation];
    }
    
    
    if (_aniType == LINE_ANI_TYPE) {
        [self bazierCustomAnimation];
    }
    
    if (_aniType == KEY_FRAME_POSION_TYPE) {
        [self keyFramePostionAnimation];
    }
    
    if (_aniType == KEY_FRAME_POSION_UIVIEW_TYPE) {
        [self keyFramePostionAnimationByUiew];
    }
    
}

/**
 *  关键帧动画，可设置任意多的关键帧位置
 */
-(void) keyFramePostionAnimation
{
    //1.创建关键帧动画并设置动画属性
    _aniKeyFrame=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //2.设置关键帧
    [self insertStartEndPointForKeyFrameArray];
    _aniKeyFrame.values=_aniKeyframePointArray;


    //设置其他属性
    _aniKeyFrame.duration=_aniDuration;
    
    NSValue* endValue = _aniKeyframePointArray.lastObject;
    [_aniKeyFrame setValue:endValue forKey:@"animation_coustom_end_point"];
    _aniKeyFrame.delegate = self;
    _aniKeyFrame.removedOnCompletion = YES;

    _aniKeyFrame.keyTimes = [self setKeyFrameTimes];
    _aniKeyFrame.repeatCount = _aniRepeatCount;
    
    
    //3.添加动画到图层，添加动画后就会执行动画
    [_aniLayer addAnimation:_aniKeyFrame forKey:_anikey];
    
    
}


-(void) insertStartEndPointForKeyFrameArray
{
    //加入开始，与结束位置
    [_aniKeyframePointArray insertObject:[NSValue valueWithCGPoint:_aniStartPoint] atIndex:0];
    [_aniKeyframePointArray insertObject:[NSValue valueWithCGPoint:_aniEndpoint] atIndex:_aniKeyframePointArray.count];
    
    if (_aniKeyframePointCount == 0)
    {
        //NSLog(@"Notify: No middle key frame is set, only start and end point!");
    }
    
    
}

/**
 *  计算关键帧时间,第一个是0.0，最后一个是1.0
 *
 *  @return 返回时间ARRAY
 */
-(NSMutableArray*)setKeyFrameTimes
{
    
    //设置随机帧时间
    NSMutableArray* keyFrameTimeArray =[NSMutableArray arrayWithCapacity:_aniKeyframePointCount];
    //第1帧时间
    [keyFrameTimeArray addObject:[NSNumber numberWithFloat:0.0]];
    //中间n-2帧时间，把0.0到0.9分成n-2份
    float sTimeAdd;
    if (_aniKeyframePointCount != 0) {
        
        float everyTime = (0.9-0.0)/_aniKeyframePointCount;
        for (int i = 0; i<_aniKeyframePointCount; i++) {
            
            sTimeAdd = everyTime * (i+1);
            NSNumber *sTime = [NSNumber numberWithFloat:(sTimeAdd)];
            [keyFrameTimeArray addObject:sTime];
        }
    }

    //最后一帧时间，保证设定总时间内完成
    [keyFrameTimeArray addObject:[NSNumber numberWithFloat:1.0]];
    
    return keyFrameTimeArray;
}

/**
 *  用UIview封装实现的关键帧动画，封装不支持关键帧路径的贝塞尔动画
 */
-(void) keyFramePostionAnimationByUiew
{
    
    [self insertStartEndPointForKeyFrameArray];

    NSMutableArray* keyFrameTimeArray = [self setKeyFrameTimes];
    
    [UIView animateKeyframesWithDuration:_aniDuration delay:0 options: UIViewAnimationOptionCurveLinear| UIViewAnimationOptionCurveLinear animations:^{
        
        NSInteger keyCount = _aniKeyframePointArray.count;
        for (int i = 0 ; i <keyCount-1; i++) {
            
            float keyTime = [[keyFrameTimeArray objectAtIndex:(i+1)] floatValue];
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:keyTime animations:^{
                _aniImageView.center= [[_aniKeyframePointArray objectAtIndex:(i+1)] CGPointValue];
            }];
        }
        
    } completion:^(BOOL finished) {
        
        
        [self.customAniDelegate customAnimationFinishedRuturn:_anikey srcViewDic:_aniImageViewDic];
        
        
    }];
    
}

-(void)  setAniKeyframePoint:(CGPoint) setPoint
{


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

    
    //先移动srcview的位置，否则结束时什么闪烁
    [self moveSrceViewToEndFrame:anim];
    
    //隐藏原view
    [self needHideSrcView];
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //NSLog(@"%@",[_aniLayer animationForKey:_animationkey]);


    //[self moveSrceViewToEndFrame:anim];
    
    //移除时钟对象到主运行循环
    if (_displayLinkEnable) {
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    [self specialCustomFinishHandle:anim];

    
    [self.customAniDelegate customAnimationFinishedRuturn:_anikey srcViewDic:_aniImageViewDic];
    

}

-(void)moveSrceViewToEndFrame:(CAAnimation *)anim
{
    
    [CATransaction begin];
    //禁用隐式动画
    [CATransaction setDisableActions:YES];
    _aniLayer.position=[[anim valueForKey:@"animation_coustom_end_point"] CGPointValue];
    
    //移动原view到终点位置,必须放到动画开始中，否则会在原位闪烁
    [_aniImageView setFrame:CGRectMake(_aniEndpoint.x-_aniEndSize.width/2, _aniEndpoint.y-_aniEndSize.height/2, _aniEndSize.width, _aniEndSize.height)];
    
    //提交事务
    [CATransaction commit];
}

/**
 *  某些特点动画流程，需要特别的处理
 */
-(void) specialCustomStartHandle:(CAAnimation *)anim
{
    

    
}

-(void) specialCustomFinishHandle:(CAAnimation *)anim
{
    
    if ((_sipiriteAnimationType == lightTypeYellowSpirte||_sipiriteAnimationType == lightTypeWhiteSpirite) && ([_anikey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_NEWSKY] || [_anikey isEqualToString:KEY_ANIMATION_SWIM_SPIRITE_OUT_FOR_REFRESH_ADD]||[_anikey isEqualToString:KEY_ANIMATION_SPIRITE_FLY_TRACE_TOUCH]))
    {
        //此种情况需要隐藏,因为它后面是连续动画
        _aniImageView.hidden =  YES;
    }else
    {
        //显示原view
        _aniImageView.hidden =  NO;
        
    }
    
    //显示的是aniImageView，_aniLayer要移除
    [self removeAniLayer];
}





#pragma mark - 精灵动画准备
-(void) setSipiriteAnimationType:(LightType) sipiriteType
{
    _sipiriteAnimationType = sipiriteType;
    _sipiriteArray=[NSMutableArray arrayWithCapacity:0];
    //默认为2个动画片段
    for (int i=1; i<3; i++) {
        
        NSString* spiTypeName = [CommonObject getImageNameByLightType:_sipiriteAnimationType];
        NSString *name=[NSString stringWithFormat:@"%@-%d",spiTypeName,i];
        UIImage *image=[UIImage imageNamed:name];
        
        NSAssert(image, @"GET image failed!, image name = %@", name);
        
        [_sipiriteArray addObject:image];
    }
    
}

-(void) displayLinkAnimationEnable
{
    //添加时钟对象到主运行循环
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLinkEnable = YES;
    
}


//每次屏幕刷新就会执行一次此方法(每秒接近60次)
-(void)step{
    //定义一个变量记录执行次数
    static int s=0;
    NSInteger imageCount = _sipiriteArray.count;
    //每秒执行6次
    if (++s%4==0) {
        UIImage *image=_sipiriteArray[_index];
        _aniLayer.contents=(id)image.CGImage;//更新图片
        _index=(_index+1)%imageCount;
    }
}

#pragma mark - 动画层，及原动画图片设置
//不同动画情况下，需要对动画层，及原动画图片进行设置
-(void) removeAniLayer
{
    [_aniLayer removeFromSuperlayer];
}

-(void) addAniLayer
{
    //[_bkLayer addSublayer:_aniLayer];
    [_bkLayer insertSublayer:_aniLayer above:_bkLayerBelow];

}

-(void)needHideSrcView
{
    _aniImageView.hidden = YES;
    
}

-(void)needShowSrcView
{
    _aniImageView.hidden = NO;
    
}


@end
