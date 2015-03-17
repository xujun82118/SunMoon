//
//  PulsingHaloLayer.h
//  https://github.com/shu223/PulsingHalo
//
//  Created by shuichi on 12/5/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//
//  Inspired by https://github.com/samvermette/SVPulsingAnnotationView


#import <QuartzCore/QuartzCore.h>

@protocol PulsingHaloLayerAnimationDelegate;

@interface PulsingHaloLayer : CALayer


@property (nonatomic, assign) CALayer* superLayer;                  
@property (nonatomic, assign) CGFloat radius;                   // default:60pt
@property (nonatomic, assign) NSTimeInterval animationDuration; // default:3s
@property (nonatomic, assign) NSTimeInterval pulseInterval; // default is 0s

@property (nonatomic, assign) NSInteger eerepeatCount; // default is 1

@property (nonatomic, assign) NSString* anikey; //动画的名称

@property(nonatomic,assign) id<PulsingHaloLayerAnimationDelegate> AniDelegate;


@end


@protocol PulsingHaloLayerAnimationDelegate <NSObject >

- (void) pulsingHaloLayerAnimationFinishedRuturn:(NSString*) aniKey  object:(PulsingHaloLayer*) selfObject;


@end

