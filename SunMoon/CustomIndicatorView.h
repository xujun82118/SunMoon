//
//  CustomIndicatorView.h
//  SunMoon
//
//  Created by songwei on 14-9-15.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomIndicatorView : UIView



@property (nonatomic,assign) NSUInteger numOfObjects;
@property (nonatomic,assign) CGSize objectSize;
@property (nonatomic,retain) UIColor *color;


-(void)startAnimating;
-(void)stopAnimating;

@end
