//
//  ShareByShareSDR.h
//  SunMoon
//
//  Created by songwei on 14-6-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareByShareSDR : NSObject


@property (nonatomic, copy      ) UIImage * shareImage;
@property (nonatomic, copy      ) NSString * shareMsg;
@property (nonatomic, copy      ) NSString * shareMsgSignature;
@property (nonatomic, copy      ) NSString * shareMsgPreFix;


@property (nonatomic, copy      ) NSString * shareTitle;
@property (nonatomic, copy      ) NSString * shareUrl;



@property (nonatomic, copy      ) UIImage * logImage;
@property (nonatomic, copy      ) UIImage * waterImage;
@property (nonatomic      ) CGRect  logRect;
@property (nonatomic      ) CGRect  waterRect;





-(BOOL) shareImageNews;
-(BOOL) shareTexts;

-(void)  WeiBoMe;

-(void) addWater;
-(void) addLog;



@end
