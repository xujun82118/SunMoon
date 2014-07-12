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

@implementation ShareByShareSDR

@synthesize shareImage, shareMsg,shareMsgSignature,shareMsgPreFix,shareTitle,shareUrl,logImage,waterImage,logRect,waterRect;



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

    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:msg
                                       defaultContent:@"没有分享内容"
                                                image:[ShareSDK jpegImageWithImage:shareImage
                                                                           quality:CGFLOAT_DEFINED]
                                                title:shareTitle
                                                  url:shareUrl
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
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
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
    
    NSLog(@"shareImageNews return!");
    
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
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
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
                                                title:@"天天更美丽"
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
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"星星汰1982"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    nil]];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    //[container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    
    NSArray *oneKeyShareList = [ShareSDK getShareListWithType:
                                ShareTypeSinaWeibo,
                                nil];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:oneKeyShareList
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
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
    
    
}

-(void) addWater;
{
    AddWaterMask* addWaterMask = [AddWaterMask alloc];
    [addWaterMask setWaterRect:waterRect];
    shareImage =[addWaterMask addImage:shareImage addMsakImage:waterImage];
    
}



-(void) addLog
{
    
    
}


@end
