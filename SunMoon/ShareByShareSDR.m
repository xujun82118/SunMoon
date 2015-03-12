//
//  ShareByShareSDR.m
//  SunMoon
//
//  Created by songwei on 14-6-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "ShareByShareSDR.h"
#import "AddWaterMask.h"
#import <ShareSDK/ShareSDK.h>
#import "CustomAlertView.h"


@implementation ShareByShareSDR
{
    //CustomAlertView* customAlertAutoDis;
    //CustomAlertView* customAlertAutoDisYes;

}


@synthesize customDelegate,shareImage, shareMsg,shareMsgSignature,shareMsgPreFix,shareTitle,shareUrl,logImage,waterImage,logRect,waterRect,textRect,timeString,lightCount,senttence;


-(BOOL) shareImageNews
{

    
    if (!shareImage||!shareMsg) {
        NSLog(@"ERROR: shareImageNews without image or text!");
        return FALSE;
    }
    
    NSString*  msg = Nil;
    if (shareMsgSignature) {
        msg = [shareMsg stringByAppendingString:shareMsgSignature];
    }else
    {
        msg = shareMsg;
    }

    msg = [shareMsgPreFix stringByAppendingString:msg];

    shareTitle = NSLocalizedString(@"appName", @"");
    shareUrl = NSLocalizedString(@"appUrl", @"");
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:msg
                                       defaultContent:@"没有分享内容"
                                                image:[ShareSDK jpegImageWithImage:shareImage
                                                                           quality:CGFLOAT_DEFINED]
                                                title:shareTitle
                                                  url:shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeImage];

    UIImage* temp =[ShareSDK jpegImageWithImage:shareImage
                                        quality:CGFLOAT_DEFINED];
    
    
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
                          ShareTypeSinaWeibo,
                          ShareTypeTencentWeibo,
                          ShareTypeQQ,
                          ShareTypeCopy,
                          nil];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:nil
                                                           qqButtonHidden:YES
                                                    wxSessionButtonHidden:YES
                                                   wxTimelineButtonHidden:YES
                                                     showKeyboardOnAppear:YES
                                                        shareViewDelegate:nil
                                                      friendsViewDelegate:nil
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    [self.customDelegate ShareReturnSucc];

                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                    
                                    [self.customDelegate ShareReturnFailed];

                                }
                                
                                if (state == SSResponseStateBegan) {
                                    NSLog(@"开始分享");
                                    [self.customDelegate ShareStart];

                                }
                                
                                if (state == SSResponseStateCancel) {
                                    NSLog(@"取消分享");
                                    [self.customDelegate ShareCancel];
                                    
                                }
                                
                            }];
    
    
    
    return  TRUE;
}


-(BOOL) shareOnlyImage
{
    

    
    return  TRUE;
}


-(BOOL) shareTexts
{
    if (!shareMsg) {
        NSLog(@"ERROR: shareTexts without text!");
        return FALSE;
    }
    
    NSString*  msg = Nil;
    if (shareMsgSignature) {
        msg = [shareMsg stringByAppendingString:shareMsgSignature];
    }else
    {
        msg = shareMsg;
    }
    
    msg = [shareMsgPreFix stringByAppendingString:msg];

    shareTitle = NSLocalizedString(@"appName", @"");
    shareUrl =NSLocalizedString(@"appUrl", @"");
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:msg
                                       defaultContent:@"没有分享内容"
                                                image:[ShareSDK jpegImageWithImage:Nil
                                                                           quality:CGFLOAT_DEFINED]
                                                title:shareTitle
                                                  url:shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    NSArray *shareList = [ShareSDK getShareListWithType:
                          ShareTypeWeixiSession,
                          ShareTypeWeixiTimeline,
                          ShareTypeSinaWeibo,
                          ShareTypeTencentWeibo,
                          ShareTypeQQ,
                          ShareTypeCopy,
                          nil];
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    
                                    [self.customDelegate ShareReturnSucc];
                                    
                                    //[CommonObject showAlert:@"分享成功" titleMsg:nil DelegateObject:nil];
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                    [self.customDelegate ShareReturnFailed];

                                    //[CommonObject showAlert:@"分享失败" titleMsg:nil DelegateObject:nil];
                                }
                            }];
    
    
    NSLog(@"shareTexts return!");

    
    return  TRUE;
}



-(void)  WeiBoMe
{
    NSString*  shareMsg = @"@星星汰:";
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:shareMsg
                                       defaultContent:@"没有分享内容"
                                                image:nil
                                                title:NSLocalizedString(@"appName", @"")
                                                  url:@"null"
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"星星汰"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    nil]];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    //[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    
    //NSArray *oneKeyShareList = [ShareSDK getShareListWithType:
        //                        ShareTypeSinaWeibo,
      //                          nil];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:YES
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(@"发表成功");
                                    [self.customDelegate ShareReturnSucc];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                    [self.customDelegate ShareReturnFailed];
                                 }
                                 
                                 
                                 if (state == SSResponseStateBegan) {
                                     NSLog(@"开始分享");
                                     [self.customDelegate ShareStart];
                                     
                                 }
                                 
                                 if (state == SSResponseStateCancel) {
                                     NSLog(@"取消分享");
                                     [self.customDelegate ShareCancel];
                                     
                                 }
                                 
                             }];
    
    
}

-(void) addWater
{
    AddWaterMask* addWaterMask = [AddWaterMask alloc];
    [addWaterMask setWaterRect:waterRect];
    shareImage =[addWaterMask addImage:shareImage addMsakImage:waterImage];
    
}

-(void) addTimeText:(NSString*) imageName
{
    AddWaterMask* addWaterMask = [AddWaterMask alloc];
    //构造日期Text图,相对于底图的位置
    UIImage* textImageBk = [UIImage imageNamed:imageName];
    CGFloat w = textImageBk.size.width;
    CGFloat h = textImageBk.size.height;
    CGFloat x = textImageBk.size.width/2-w/2;
    CGFloat y = textImageBk.size.height/2-h/2;
    [addWaterMask setTextRect:CGRectMake(x,y, w, h)];
    [addWaterMask setTextFrontSize:30];
    UIImage*  textImageWater =[addWaterMask addText:textImageBk text:timeString];
    
    //放置日期水印图
    [addWaterMask setWaterRect:textRect];
    shareImage =[addWaterMask addImage:shareImage addMsakImage:textImageWater];

    
}


-(void) addLightCounText
{
    AddWaterMask* addWaterMask = [AddWaterMask alloc];
    [addWaterMask setTextRect:textRect];
    [addWaterMask setTextFrontSize:12];
    shareImage =[addWaterMask addText:shareImage text:lightCount];
    
}


-(void) addSentenceText
{
    AddWaterMask* addWaterMask = [AddWaterMask alloc];
    [addWaterMask setTextRect:textRect];
    [addWaterMask setTextFrontSize:15];
    shareImage =[addWaterMask addText:shareImage text:senttence];
    
}

-(void) addLog
{
    
    
}




@end
