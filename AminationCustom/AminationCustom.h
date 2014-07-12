//
//  AminationCustom.h
//  SunMoon
//
//  Created by songwei on 14-6-28.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AminationCustomDelegate;
@interface AminationCustom : CAKeyframeAnimation

{
    id <AminationCustomDelegate> aminationCustomDelegate;

}

@property(nonatomic) id<AminationCustomDelegate> aminationCustomDelegate;

@property (nonatomic, copy      )CALayer *layer; 
@property (nonatomic    ) UIImageView * aminationImageView;

@property (nonatomic, ) CGPoint startPoint;
@property (nonatomic, ) CGPoint endpoint;

@property (nonatomic, ) CGPoint centerPoint; //贝塞尔曲线中间点


-(instancetype)initWithKey:(NSString*) key;


-(CALayer*)layerWithImageView:(UIImageView*) aminaView;
-(void)startBezierAmination:(NSString*) key;


@end


//定义为NSObject的协议，将能被所有的对像实现
@protocol AminationCustomDelegate <NSObject >

- (void) imageEditingFinishReturn;


@end
