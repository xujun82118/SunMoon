//
//  ImageFilterProcessViewController.h
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImagePickerController.h"
#import "CommonObject.h"
#import "ShareByShareSDR.h"
#import "CustomAnimation.h"
#import "CustomAlertView.h"



@protocol ImageFitlerProcessDelegate;
@interface ImageFilterProcessViewController : UIViewController<CustomImagePickerControllerDelegate,CustomAnimationDelegate,ShareByShareSDRDelegate,CustomAlertDelegate>
{
    UIScrollView *scrollerView;
    UIImage *currentImage;
    id <ImageFitlerProcessDelegate> delegate;
    
    NSDictionary* imagePickerData;
    
    bool isHaveSavePhoto;

    
}
@property(nonatomic) id<ImageFitlerProcessDelegate> delegate;
@property(nonatomic)UIImage *currentImage;
@property(nonatomic)NSString *currentSentence; //当前语录
@property (nonatomic, strong) NSDictionary* imagePickerData;
@property(nonatomic) NSInteger iSunORMoon; //1:太阳，2：月亮

@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * userInfo;

- (void)reDoPhoto:(id)sender;
- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn;
-(void)chooseOldImage;

@end

@protocol ImageFitlerProcessDelegate <NSObject>

- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData;
@end
