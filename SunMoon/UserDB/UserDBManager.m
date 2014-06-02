//
//  UserDBManager.m
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserDBManager.h"
#import "FMDatabase.h"


#define kDefaultDBName @"UserSunMoonDB.sqlite"


@implementation UserDBManager

static UserDBManager * _sharedDBManager;

+ (UserDBManager *) defaultDBManager {
	if (!_sharedDBManager) {
		_sharedDBManager = [[UserDBManager alloc] init];
	}
	return _sharedDBManager;
}

- (void) dealloc {
    [self close];
}

- (id) init {
    self = [super init];
    if (self) {
        int state = [self initializeDBWithName:kDefaultDBName];
        if (state == -1) {
            NSLog(@"数据库初始化失败");
        } else {
            NSLog(@"数据库初始化成功");
        }
    }
    return self;
}


/**
 * @brief 初始化数据库操作
 * @param name 数据库名称
 * @return 返回数据库初始化状态， 0 为 已经存在，1 为创建成功，-1 为创建失败
 */
- (int) initializeDBWithName : (NSString *) name {
    if (!name) {
		return -1;  // 返回数据库创建失败
	}
    // 沙盒Docu目录
    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
	_name = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
	NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    [self connect];
    if (!exist) {
        return 0;
    } else {
        return 1;          // 返回 数据库已经存在
        
	}
    
}

/**
 * @brief 获取数据库文件路径
 */
-(NSString*)getDBPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    if (!exist) {
        return NULL;
    }

    return _name;
}

/**
 * @brief 删除数据库文件
 */
-(void)deleteDBPathFile
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    if(exist)
    {
        [fileManager removeItemAtPath:_name error:NULL];
        
    }
    
    
}



/// 连接数据库
- (void) connect {
	if (!_dataBase) {
		_dataBase = [[FMDatabase alloc] initWithPath:_name];
	}
	if (![_dataBase open]) {
		NSLog(@"不能打开数据库");
	}
}
/// 关闭连接
- (void) close {
	[_dataBase close];
    _sharedDBManager = nil;
}



@end
