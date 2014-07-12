//
//  AminationCustom.m
//  SunMoon
//
//  Created by songwei on 14-6-28.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "AminationCustom.h"

@implementation AminationCustom
@synthesize layer = _layer,aminationCustomDelegate = _aminationCustomDelegate, aminationImageView = _aminationImageView, startPoint = _startPoint, endpoint = _endpoint, centerPoint = _centerPoint;


-(instancetype)initWithKey:(NSString*) key
{
    if (!self) {
        return nil;
    }
    
    self.keyPath = key;
     //_aminationImageView = [UIImageView alloc];
    
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
