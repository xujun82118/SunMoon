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

/*
 错误码：
 -1：用户名或id未输入
 
 查询用户记录
 -11：未连上数据库
 -12：未查到对应记录
 -13：查询数据库失败
 
 新增用户记录
 -20：未连上数据库
 -21：查询数据库失败
 -22：插入数据库失败
 -23：更新数据库失败
 */
typedef enum
{
    CLOUD_SUCC = 0,
    CLOUD_ERR_NO_NAMEID  = 1,
    CLOUD_ERR_QUERY_UNCONNECT        =   -11,
    CLOUD_ERR_QUERY_NORECORD         =   -12,
    CLOUD_ERR_QUERY_FAILED           =   -13,
    CLOUD_ERR_INSERT_UNCONNECT       =   -20,
    CLOUD_ERR_INSERT_QUERY_FAILED    =   -21,
    CLOUD_ERR_INSERT_FAILED          =   -22,
    CLOUD_ERR_UPDATE_FAILED          =   -23
    
}cloudSynchronizeCode;





@protocol UserInfoCloudDelegate;

@interface UserInfoCloud : NSObject


/**
 * @brief 云同步用户记录
 *
 * @param user 需要同步的用户数据
 */
-(void)upateUserInfo:(UserInfo *) user;


/**
 * @brief 获取用户信息用user_name和sns_id
 *
 */
-(void) GetCloudUserInfo:(UserInfo *) user;


/**
 * @brief 云同步用户IMAGE
 *
 * @param image 需要同步的用户IMAGE
 */
-(BOOL)updateUserImage:(NSData *) image;





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


- (void) updateUserInfoSuccReturn;
- (void) updateUserInfoFailedReturn;
- (void) updateUserInfoFailedReturnByNetWork;


- (void) getUserInfoFinishReturnDic:(NSDictionary*) userInfo;
- (void) getUserInfoFinishFailed;
- (void) getUserInfoFinishFailedByNetWork;



@end
