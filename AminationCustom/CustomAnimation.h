//
//  CustomAnimation.h
//  SunMoon
//
//  Created by xujun on 15-1-22.
//  Copyright (c) 2015年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 示例请看本页最后
 */
typedef enum
{
    BEZIER_ANI_TYPE = 0,  //贝塞尔曲线动画
    LINE_ANI_TYPE  = 1,   //直线动画
    KEY_FRAME_POSION_TYPE = 2, //关键帧动画
    KEY_FRAME_POSION_UIVIEW_TYPE = 3, //关键帧动画,UIVIEW封装

}aniCustomType;


@protocol CustomAnimationDelegate;

@interface CustomAnimation : NSObject
{
    
    UIImage * aniImage; //使用的动画图片

}

@property(nonatomic,weak) id<CustomAnimationDelegate> customAniDelegate;

@property (nonatomic, assign) aniCustomType  aniType; //动画类型
@property (nonatomic, copy) NSString* anikey; //动画的名称

@property (nonatomic, strong)CALayer * bkLayer; //被添加的根图层
@property (nonatomic, strong)CALayer * aniLayer; //被创建的动画图层
@property (nonatomic,assign)CALayer * bkLayerBelow; //被添加在此图层之上, 处理弹出后，被新加图层覆盖问题,默认为bkLayer



@property (nonatomic, strong) NSDictionary* aniImageViewDic; //动画的原view信息，用于动画后对其操作
@property (nonatomic,strong) UIImageView* aniImageView; //动画的原view,不用初始化


@property(nonatomic,assign) CGSize   aniStartSize;
@property(nonatomic,assign) CGSize   aniEndSize;

@property (nonatomic, assign) CGPoint aniStartPoint;
@property (nonatomic, assign) CGPoint aniEndpoint;


@property (nonatomic, assign)  NSInteger aniRepeatCount;
@property (nonatomic, assign)  float aniDuration;

@property (nonatomic, assign) CGPoint aniCurrentpoint;


/**
 *  用户贝塞尔 和 关键帧动画
 */
@property (nonatomic,strong)  CAKeyframeAnimation * aniKeyFrame;;

/**
 *  贝塞尔  动画参数
 */
@property (nonatomic, assign) CGPoint aniBazierCenterPoint1; //贝塞尔曲线中间点1
@property (nonatomic, assign) CGPoint aniBazierCenterPoint2; //贝塞尔曲线中间点2
-(void) bazierCustomAnimation;


/**
 *  关键帧动画点
 */
@property (nonatomic, strong) NSMutableArray* aniKeyframePointArray;
@property (nonatomic, assign) NSInteger aniKeyframePointCount;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL displayLinkEnable;


-(void)  setAniKeyframePoint:(CGPoint) setPoint;
-(void) displayLinkAnimationEnable;



@property (nonatomic, strong) NSValue* aniKeyframePoint1; //关键帧点1
@property (nonatomic, strong) NSValue* aniKeyframePoint2; //关键帧点2
@property (nonatomic, strong) NSValue* aniKeyframePoint3; //关键帧点3
@property (nonatomic, strong) NSValue* aniKeyframePoint4; //关键帧点4
@property (nonatomic, strong) NSValue* aniKeyframePoint5; //关键帧点5


/**
 *  精灵动画资源加载
 */
@property (nonatomic, strong) NSMutableArray *sipiriteArray; //精灵动画组
@property (nonatomic, assign) LightType sipiriteAnimationType; //精灵类型


/**
 通用动画资源加载
 */
@property (nonatomic, strong) NSMutableArray *aniImageArray;
@property (nonatomic, assign) NSInteger aniImageArrayType;
@property (nonatomic, assign) NSInteger aniImageFrameCount;



//-(instancetype)initCustomAnimation;
-(instancetype)initCustomAnimation;

-(void) startCustomAnimation;

-(void) lineCustomAnimation;

-(void) removeAniLayer;


@end


@protocol CustomAnimationDelegate <NSObject >

- (void) customAnimationFinishedRuturn:(NSString*) aniKey  srcViewDic:(NSDictionary*) srcViewDic;


@end



/* KEY_FRAME_POSION_UIVIEW_TYPE
 
 CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:srcAni.aniImageView];
 
 CGPoint startPoint = srcAni.aniImageView.center;
 CGPoint endPoint = _skySunorMoonImage.center;
 
 [customAnimation setAniType:KEY_FRAME_POSION_UIVIEW_TYPE];
 [customAnimation setAniImageView:srcAni.aniImageView];
 [customAnimation setAniStartSize:CGSizeMake(30, 30)];
 [customAnimation setAniEndSize:CGSizeMake(30, 30)];
 [customAnimation setAniStartPoint:startPoint];
 [customAnimation setAniEndpoint:endPoint];
 [customAnimation setAniImage:srcAni.aniImageView.image];
 [customAnimation setCustomAniDelegate:self];
 [customAnimation setAnikey:@"animation_swim_back"];
 [customAnimation setAniRepeatCount:1];
 [customAnimation setAniDuration:[CommonObject getRandomNumber:1 to:POP_BACK_ANIMATION_LIGHT_TIME]];
 
 
 NSInteger keyCount = 2;
 NSMutableArray* posionArry = [self getRadomPosionWithSize:CGSizeMake(15, 15) inFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-300) exceptFrame:_skySunorMoonImage.frame Count:keyCount];
 if (!posionArry) {
 return;
 }
 
 //开始点,结束点也算一帧
 [customAnimation setAniKeyframePointCount:keyCount+2];
 
 for (int i=0; i<keyCount; i++) {
 
 //关键帧点
 CGRect rectSrc =[[posionArry objectAtIndex:i] CGRectValue];
 CGPoint pointKey = CGPointMake(rectSrc.origin.x, rectSrc.origin.y);
 [customAnimation setAniKeyframePoint:pointKey];
 
 }
 
 
 [customAnimation startCustomAnimation];
 
 
 */



/* BEZIER_ANI_TYPE
 
 UIImageView* srcView = [[UIImageView alloc] initWithImage:[CommonObject getLightImageByLightType:lightTypeYellow]];
 [self.view addSubview:srcView];
 
 CustomAnimation* customAnimation = [[CustomAnimation alloc] initCustomAnimationWithSrcView:srcView];
 
 CGPoint startPoint = _intoCameraBtn.center;
 CGPoint endPoint = _userHeaderImageView.center;
 
 float disX = endPoint.x - startPoint.x;
 float disY = endPoint.y - startPoint.y;
 
 CGPoint bazierPoint_1 = CGPointMake(startPoint.x+(disX/3)+20, startPoint.y + (disY/3) +20);
 
 [customAnimation setAniBazierCenterPoint1:bazierPoint_1];
 
 CGPoint bazierPoint_2 = CGPointMake(startPoint.x+(disX/3*2)+20, startPoint.y + (disY/3*2) +20);
 [customAnimation setAniBazierCenterPoint2:bazierPoint_2];
 
 [customAnimation setAniType:BEZIER_ANI_TYPE];
 [customAnimation setAniImageView:srcView];
 [customAnimation setBkLayer:self.view.layer];
 [customAnimation setAniStartSize:CGSizeMake(30, 30)];
 [customAnimation setAniEndSize:CGSizeMake(30, 30)];
 [customAnimation setAniStartPoint:startPoint];
 [customAnimation setAniEndpoint:endPoint];
 [customAnimation setAniImage:srcView.image];
 [customAnimation setCustomAniDelegate:self];
 [customAnimation setAnikey:@"animation_bazier_give_one_light"];
 [customAnimation setAniRepeatCount:1];
 [customAnimation setAniDuration:2];
 
 [customAnimation startCustomAnimation];
 */
