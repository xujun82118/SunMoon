//
//  CustomAnimation.h
//  SunMoon
//
//  Created by xujun on 15-1-22.
//  Copyright (c) 2015年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    BEZIER_ANI_TYPE = 0,  //贝塞尔曲线动画
    LINE_ANI_TYPE  = 1,   //直线动画
    KEY_FRAME_POSION_TYPE = 2, //关键帧动画
}aniCustomType;


@protocol CustomAnimationDelegate;

@interface CustomAnimation : NSObject
{
    
    
}

@property(nonatomic) id<CustomAnimationDelegate> customAniDelegate;

@property (nonatomic,) aniCustomType  aniType; //动画类型
@property (nonatomic, ) NSString* anikey; //动画的名称

@property (nonatomic)CALayer * bkLayer; //被添加的根图层
@property (nonatomic)CALayer * aniLayer; //被创建的动画图层


@property (nonatomic) UIImageView* aniImageView; //动画的原view，用于动画后对其操作
@property (nonatomic    ) UIImage * aniImage; //使用的动画图片

@property(nonatomic) CGSize   aniStartSize;
@property(nonatomic) CGSize   aniEndSize;

@property (nonatomic, ) CGPoint aniStartPoint;
@property (nonatomic, ) CGPoint aniEndpoint;


@property (nonatomic, )  NSInteger aniRepeatCount;
@property (nonatomic, )  NSInteger aniDuration;

@property (nonatomic, ) CGPoint aniCurrentpoint;


/**
 *  用户贝塞尔 和 关键帧动画
 */
@property (nonatomic,)  CAKeyframeAnimation * aniKeyFrame;;

/**
 *  贝塞尔  动画参数
 */
@property (nonatomic, ) CGPoint aniBazierCenterPoint1; //贝塞尔曲线中间点1
@property (nonatomic, ) CGPoint aniBazierCenterPoint2; //贝塞尔曲线中间点2
-(void) bazierCustomAnimation;


/**
 *  关键帧动画点
 */
@property (nonatomic, ) NSMutableArray* aniKeyframePointArray;
@property (nonatomic, ) NSInteger aniKeyframePointCount;
-(void)  setAniKeyframePoint:(CGPoint) setPoint;
-(void) keyFramePostionAnimation;



@property (nonatomic, ) NSValue* aniKeyframePoint1; //关键帧点1
@property (nonatomic, ) NSValue* aniKeyframePoint2; //关键帧点2
@property (nonatomic, ) NSValue* aniKeyframePoint3; //关键帧点3
@property (nonatomic, ) NSValue* aniKeyframePoint4; //关键帧点4
@property (nonatomic, ) NSValue* aniKeyframePoint5; //关键帧点5



//-(instancetype)initCustomAnimation;
-(instancetype)initCustomAnimationWithSrcView:(UIImageView*) srcView;

-(void) startCustomAnimation;


-(void) lineCustomAnimation;



@end


@protocol CustomAnimationDelegate <NSObject >

- (void) customAnimationFinishedRuturn:(NSString*) aniKey  srcView:(UIImageView*) srcView;


@end
