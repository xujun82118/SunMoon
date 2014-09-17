//
//  CustomAlertView.h
//  SunMoon
//
//  Created by songwei on 14-8-10.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

//*******示例代码******
/*后续可增加对字体等的定义
 customAlertAutoDis = [[CustomAlertView alloc] InitCustomAlertViewWithSuperView:self.view bkImageName:@"天空对话-蓝.png"  yesBtnImageName:@"ok.png" posionShowMode:userSet];
 [customAlertAutoDis setStartCenterPoint:_showBringLightBtn.center];
 [customAlertAutoDis setEndCenterPoint:self.view.center];
 [customAlertAutoDis setStartAlpha:0.1];
 [customAlertAutoDis setEndAlpha:1.0];
 [customAlertAutoDis setStartHeight:0];
 [customAlertAutoDis setStartWidth:0];
 [customAlertAutoDis setEndWidth:SCREEN_WIDTH/5*2];
 [customAlertAutoDis setEndHeight:customAlertAutoDis.endWidth];
 [customAlertAutoDis setDelayDisappearTime:5.0];
 [customAlertAutoDis setMsgFrontSize:30];
 [customAlertAutoDis setAlertMsg:@"首次登录，奖励一个阳光，或月光, 点击光"];
 [customAlertAutoDis RunCumstomAlert];
*/
//*******************

#import <Foundation/Foundation.h>


typedef enum {
    userSet                   = 1,
    viewCenterBig             = 2,
    commonYesAlertViewCenter  = 3,

} CustomAlertShowMode;

@protocol CustomAlertDelegate;
@interface CustomAlertView : NSObject
{
    
    id <CustomAlertDelegate> customAlertDelegate;

}
@property(nonatomic) id<CustomAlertDelegate> customAlertDelegate;

@property (nonatomic) CustomAlertShowMode selfMode;

@property (nonatomic,strong) UIView * superView;

@property (nonatomic) UILabel* msgLabel;

@property (nonatomic,strong) NSString* alertMsg;

@property (nonatomic) NSInteger  MsgFrontSize;



@property (nonatomic,strong) UIImageView * viewBkImageView;
@property (nonatomic) UIButton * yesBtn;

@property (nonatomic, ) CGFloat delayDisappearTime;

@property (nonatomic, ) CGFloat startAlpha ;
@property (nonatomic, ) CGFloat endAlpha ;

@property (nonatomic, ) CGPoint startCenterPoint;
@property (nonatomic, ) CGPoint endCenterPoint;

@property (nonatomic, ) NSInteger startWidth ;
@property (nonatomic, ) NSInteger startHeight ;

@property (nonatomic, ) NSInteger endWidth ;
@property (nonatomic, ) NSInteger endHeight ;


-(instancetype) InitCustomAlertViewWithSuperView:(UIView*) superView  bkImageName:(NSString*) bkImage yesBtnImageName:(NSString*) btnImage  posionShowMode:(CustomAlertShowMode) mode;

-(void) RunCumstomAlert;

@end

@protocol CustomAlertDelegate <NSObject >

- (void) CustomAlertOkReturn;


@end

