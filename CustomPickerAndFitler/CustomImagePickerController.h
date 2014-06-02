//
//  CustomImagePickerController.h
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDB.h"
#import "AFPickerView.h"

@protocol CustomImagePickerControllerDelegate;

@interface CustomImagePickerController : UIImagePickerController
<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPickerViewDataSource, AFPickerViewDelegate>
{
    id<CustomImagePickerControllerDelegate> _customDelegate;
     AFPickerView *defaultPickerView;
    
    NSDictionary* imagePickerData;
}

@property(nonatomic)BOOL isSingle;
@property(nonatomic) NSInteger iSunORMoon; //1:太阳，2：月亮
@property(nonatomic)id<CustomImagePickerControllerDelegate> customDelegate;
@property (nonatomic, strong) NSDictionary* imagePickerData;

@property(nonatomic,copy) NSArray* userData;
@property (nonatomic, strong) UserInfo * user;



@end

//定义协议，一个统一的处理接口
@protocol CustomImagePickerControllerDelegate <NSObject>

- (void)cameraPhoto:(NSDictionary *)imagePickerDataReturn;

- (void)cancelCamera;
@end
