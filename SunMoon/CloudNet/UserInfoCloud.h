//
//  UserInfoCloud.h
//  SunMoon
//
//  Created by songwei on 14-4-16.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

#define CLOUD_USER_INFO  @"http://115.28.36.43/cgi-bin/app_userinfo"
#define CLOUD_USER_IMAGE  @"http://115.28.36.43/cgi-bin/app_userphoto_upload"


@protocol UserInfoCloudDelegate;

@interface UserInfoCloud : NSObject


/**
 * @brief 云同步用户记录
 *
 * @param user 需要同步的用户数据
 */
-(BOOL)upateUserInfo:(UserInfo *) user;


/**
 * @brief 云同步用户IMAGE
 *
 * @param image 需要同步的用户IMAGE
 */
-(BOOL)updateUserImage:(NSData *) image;



/**
 * @brief 获取用户信息用user_name和sns_id
 *
 * @param snsID 用户名称
 * @param userName  用户社交ID
 */
-(void)getUserInfoBySnsId:(NSString *) snsID  userName:(NSString *) userName;



/**
 * @brief 获取用户相片用user_id
 *
 * @param userID 用户id
 */
-(void)getUserImageByUserID:(NSString *) userID;

//+ (NSURLSessionDataTask *)globalTimelinePostsWithBlock:(void (^)(NSArray *posts, NSError *error))block

@property(nonatomic) id<UserInfoCloudDelegate> userInfoCloudDelegate;


@end



//定义委托函数
@protocol UserInfoCloudDelegate <NSObject >

- (void) getUserInfoFinishReturn:(UserInfo*) userInfo;

- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo;
- (void) getUserInfoFinishFailed;


@end
