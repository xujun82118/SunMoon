//
//  ShareByShareSDR.h
//  SunMoon
//
//  Created by songwei on 14-6-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareByShareSDRDelegate;


@interface ShareByShareSDR : NSObject
{
    id<ShareByShareSDRDelegate> _customDelegate;

}

@property(nonatomic)id<ShareByShareSDRDelegate> customDelegate;


@property (nonatomic, copy      ) UIImage * shareImage;
@property (nonatomic, copy      ) NSString * shareMsg;
@property (nonatomic, copy      ) NSString * shareMsgSignature;
@property (nonatomic, copy      ) NSString * shareMsgPreFix;


@property (nonatomic, copy      ) NSString * shareTitle;
@property (nonatomic, copy      ) NSString * shareUrl;


@property (nonatomic, copy      ) NSString * timeString;
@property (nonatomic, copy      ) NSString * lightCount;
@property (nonatomic, copy      ) NSString * senttence;


@property (nonatomic, copy      ) UIImage * logImage;
@property (nonatomic, copy      ) UIImage * waterImage;
//相对于分享图片的frame
@property (nonatomic      ) CGRect  logRect;
@property (nonatomic      ) CGRect  waterRect;
@property (nonatomic      ) CGRect  textRect;


-(BOOL) shareImageNews;
-(BOOL) shareTexts;

-(void)  WeiBoMe;

-(void) addWater;
-(void) addLog;
-(void) addTimeText:(NSString*) imageName;
-(void) addLightCounText;
-(void) addSentenceText;


@end

@protocol ShareByShareSDRDelegate <NSObject>

-(void) ShareStart;
-(void) ShareCancel;
-(void) ShareReturnSucc;
-(void) ShareReturnFailed;

@end
