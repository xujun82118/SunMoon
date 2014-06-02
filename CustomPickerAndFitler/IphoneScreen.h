//
//  IphoneScreen.h
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-5-25.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import <Foundation/Foundation.h>
#define IS_IPHONE5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//#define ScreenHeight (IS_IPHONE5 ? 540.0 : 460.0)

#define ScreenHeight  ([[UIScreen mainScreen]bounds].size.height)
#define ScreenWidth ([[UIScreen mainScreen]bounds].size.width)

@interface IphoneScreen : NSObject
 
@end
