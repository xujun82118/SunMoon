//
//  UserDB.h
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDBManager.h"
#import "UserInfo.h"


@interface UserDB : NSObject
{
    FMDatabase * _db;
    
}
/**
 * @brief 创建数据库
 */
- (void) createDataBase;

/**
 * @brief 删除数据库
 */
- (void) deleteDataBaseFile;
/**
 * @brief 保存一条用户记录
 *
 * @param user 需要保存的用户数据
 */
- (void) saveUser:(UserInfo *)user;

/**
 * @brief 获取数据库路径
 */
-(NSString*) getDBPath;

/**
 * @brief 删除一条用户数据
 *
 * @param uid 需要删除的用户的id
 */
- (void) deleteUserWithId:(NSString *) uid;

/**
 * @brief 修改用户的信息By UID
 *
 * @param user 需要修改的用户信息
 */
- (void) mergeWithUserByUID:(UserInfo *) user;

/**
 * @brief 修改用户的信息By 时间
 *
 * @param user 需要修改的用户信息
 */
- (void) mergeWithUserByDateTime:(UserInfo *) user;

/**
 * @brief 模拟分页查找数据。取uid大于某个值以后的limit个数据
 *
 * @param uid
 * @param limit 每页取多少个
 */
- (NSArray *) findWithUid:(NSString *) uid limit:(int) limit;

/**
 * @brief 用指定时间 查询用户的数据
 *
 * @param dateTime 指定的时间
 */
-(UserInfo*) getUserImageByDateTime: (NSString*) dateTime;

/**
 * @brief 查询用户的数据 限制个数
 *
 * @param limit 查询的结果个数
 */
-(NSArray*) getUserImageLimite:(int) limit;

@end
