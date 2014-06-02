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

@protocol ImageFitlerProcessDelegate;
@interface ImageFilterProcessViewController : UIViewController<CustomImagePickerControllerDelegate>
{
    UIImageView *rootImageView;
    UIScrollView *scrollerView;
    UIImage *currentImage;
    id <ImageFitlerProcessDelegate> delegate;
    
    NSDictionary* imagePickerData;

    
}
@property(nonatomic) id<ImageFitlerProcessDelegate> delegate;
@property(nonatomic)UIImage *currentImage;
@property (nonatomic, strong) NSDictionary* imagePickerData;
@property(nonatomic) NSInteger iSunORMoon; //1:太阳，2：月亮


- (void)reDoPhoto:(id)sender;
- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn;

@end

@protocol ImageFitlerProcessDelegate <NSObject>

- (void)imageFitlerProcessDone:(NSDictionary*) imageFilterData;
@end
