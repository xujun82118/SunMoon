//
//  UserDB.m
//  SunMoon
//
//  Created by songwei on 14-4-12.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserDB.h"
#define kUserTableName @"UserInfo"


@implementation UserDB

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [UserDBManager defaultDBManager].dataBase;
        
    }
    return self;
}

/**
 * @brief 创建数据库
 */
- (void) createDataBase {
    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kUserTableName]];
    
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    
    BOOL existTable = !!count;
    
    if (existTable) {
        // TODO:是否更新数据库
        [MainSunMoonAppDelegate showStatusWithText:@"数据库已经存在" duration:2];
        NSLog(@"数据库已经存在!");

    } else {
        // TODO: 插入新的数据库
        NSString * sql = @"CREATE TABLE UserInfo (uid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, date_time DOUBLE, sun_value INTEGER,sun_image_name TEXT,sun_image_sentence,sun_image BLOB, moon_value INTEGER, moon_image_name TEXT,moon_image_sentence,moon_image BLOB)";
        BOOL res = [_db executeUpdate:sql];
        if (!res) {
            [MainSunMoonAppDelegate showStatusWithText:@"数据库创建失败" duration:2];
            NSLog(@"数据库创建失败");
        } else {
            [MainSunMoonAppDelegate showStatusWithText:@"数据库创建成功" duration:2];
             NSLog(@"数据库创建成功");
        }
    }
}

/**
 * @brief 删除数据库
 */
- (void) deleteDataBaseFile {
    
    
    [[UserDBManager defaultDBManager] deleteDBPathFile];
    
//    FMResultSet * set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",kUserTableName]];
//    
//    [set next];
//    
//    NSInteger count = [set intForColumnIndex:0];
//    
//    BOOL existTable = !!count;
//    
//    if (existTable) {
//        // TODO:是否更新数据库
//        [MainSunMoonAppDelegate showStatusWithText:@"数据库删除" duration:2];
//        NSString * sql = @"DELETE TABLE UserInfo ";
//        BOOL res = [_db executeUpdate:sql];
//        if (!res) {
//            [MainSunMoonAppDelegate showStatusWithText:@"数据库创建失败" duration:2];
//        } else {
//            [MainSunMoonAppDelegate showStatusWithText:@"数据库创建成功" duration:2];}
//        
//    } else {
//        // TODO: 插入新的数据库
//        [MainSunMoonAppDelegate showStatusWithText:@"数据库不存在" duration:2];
//
//    }
}


/**
 * @brief 获取数据库路径
 */
-(NSString*) getDBPath
{
    return [[UserDBManager defaultDBManager] getDBPath];    
}


/**
 * @brief 保存一条用户记录
 *
 * @param user 需要保存的用户数据
 */
- (void) saveUser:(UserInfo *) user {
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO UserInfo"];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:10];

    if (user.date_time) {
        [keys appendString:@"date_time,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSNumber numberWithDouble:[self getDoubleByTimeString:user.date_time]]];

    }
    if (user.sun_value) {
        [keys appendString:@"sun_value,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSNumber numberWithInteger:user.sun_value.integerValue]];
    }
    if (user.sun_image_name) {
        [keys appendString:@"sun_image_name,"];
        [values appendString:@"?,"];
        [arguments addObject:user.sun_image_name];
    }
    if (user.sun_image_sentence) {
        [keys appendString:@"sun_image_sentence,"];
        [values appendString:@"?,"];
        [arguments addObject:user.sun_image_sentence];
    }
    if (user.sun_image) {
        [keys appendString:@"sun_image,"];
        [values appendString:@"?,"];
        [arguments addObject:user.sun_image];
    }
    if (user.moon_value) {
        [keys appendString:@"moon_value,"];
        [values appendString:@"?,"];
        [arguments addObject:[NSNumber numberWithInteger:user.moon_value.integerValue]];
    }
    if (user.moon_image_name) {
        [keys appendString:@"moon_image_name,"];
        [values appendString:@"?,"];
        [arguments addObject:user.moon_image_name];
    }
    if (user.moon_image_sentence) {
        [keys appendString:@"moon_image_sentence,"];
        [values appendString:@"?,"];
        [arguments addObject:user.moon_image_sentence];
    }
    if (user.moon_image) {
        [keys appendString:@"moon_image,"];
        [values appendString:@"?,"];
        [arguments addObject:user.moon_image];
    }
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    NSLog(@"%@",query);
    [MainSunMoonAppDelegate showStatusWithText:@"插入一条数据" duration:2.0];
    if (![_db executeUpdate:query withArgumentsInArray:arguments]) {
        NSLog(@"save failed!");
    };

}


-(NSTimeInterval) getDoubleByTimeString:(NSString*) dateString
{
    //获取年
    NSDate *nowDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps;
    comps =[calendar components:(NSYearCalendarUnit)fromDate:nowDate];
    NSInteger year = [comps year];
    
    //构造double数据，存入库
    NSRange positon = [dateString rangeOfString:@"."];
    NSString* month = [dateString substringToIndex:positon.location];
    NSString* day = [dateString substringFromIndex:positon.location+1];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month.integerValue];
    [components setDay:day.integerValue];
    NSDate *nsdate = [calendar dateFromComponents:components];
    NSTimeInterval dateInter = [nsdate timeIntervalSince1970];

    
    //反向取得时间的方法
    //NSDate* dateInter1 = [NSDate dateWithTimeIntervalSince1970:dateInter];
    
    return dateInter;
    
}

-(NSString*) getDateTimeStringByDoubleDateTime:(NSTimeInterval) timeDouble
{
    
    NSDate* dateInter = [NSDate dateWithTimeIntervalSince1970:timeDouble];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM"];
    NSString *month = [[format stringFromDate:dateInter] substringToIndex:2];
    month = [month stringByReplacingOccurrencesOfString:@"0" withString:@"" options:0 range:NSMakeRange(0, 1)];
    [format setDateFormat:@"dd"];
    NSString *day = [[format stringFromDate:dateInter] substringToIndex:2];
    day = [day stringByReplacingOccurrencesOfString:@"0" withString:@"" options:0 range:NSMakeRange(0, 1)];
    
    NSString* dateTime = [NSString stringWithFormat:@"%@.%@", month, day];

    return dateTime;

}

/**
 * @brief 删除一条用户数据
 *
 * @param uid 需要删除的用户的id
 */
- (void) deleteUserWithId:(NSString *) uid {
    NSString * query = [NSString stringWithFormat:@"DELETE FROM UserInfo WHERE uid = '%@'",uid];
    [MainSunMoonAppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    [_db executeUpdate:query];
}


- (void) deleteUserWithDataTime:(NSString *) dateTime {
    
    NSNumber*  dateNumber = [NSNumber numberWithDouble:[self getDoubleByTimeString:dateTime]];
    
    NSString* dateString = [NSString stringWithFormat:@"%@", dateNumber];
    
    NSString * query = [NSString stringWithFormat:@"DELETE FROM UserInfo WHERE date_time = '%@'",dateString];
    
    
    
    [MainSunMoonAppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    [_db executeUpdate:query];
}


//- (void) deleteUserWithImageName:(NSString *) dateTime {
//    NSString * query = [NSString stringWithFormat:@"DELETE FROM UserInfo WHERE date_time = '%@'",dateTime];
//    [MainSunMoonAppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
//    [_db executeUpdate:query];
//}

/**
 * @brief 修改用户的信息
 *
 * @param user 需要修改的用户信息
 */
- (void) mergeWithUserByUID:(UserInfo *) user {
    if (!user.uid) {
        return;
    }
    NSString * query = @"UPDATE UserInfo SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:20];
    // xxx = xxx;
    if (user.date_time) {
        NSNumber*  dateNumber = [NSNumber numberWithDouble:[self getDoubleByTimeString:user.date_time]];
        NSString* dateString = [NSString stringWithFormat:@"%@", dateNumber];
        [temp appendFormat:@" date_time = '%@',",dateString];
    }
    if (user.sun_value) {
        [temp appendFormat:@" sun_value = '%@',",user.sun_value];
    }
    if (user.sun_image_name) {
        [temp appendFormat:@" sun_image_name = '%@',",user.sun_image_name];
    }
    if (user.sun_image_sentence) {
        [temp appendFormat:@" sun_image_sentence = '%@',",user.sun_image_sentence];
    }
    if (user.sun_image) {
        [temp appendFormat:@" sun_image = '%@',",user.sun_image];
    }
    
    
    if (user.moon_value) {
        [temp appendFormat:@" moon_value = '%@',",user.moon_value];
    }
    if (user.moon_image_name) {
        [temp appendFormat:@" moon_image_name = '%@',",user.moon_image_name];
    }
    if (user.moon_image_sentence) {
        [temp appendFormat:@" moon_image_sentence = '%@',",user.moon_image_sentence];
    }
    if (user.moon_image) {
        [temp appendFormat:@" moon_image = '%@',",user.moon_image];
    }

    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE uid = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],user.uid];
    //NSLog(@"%@",query);
    
    [MainSunMoonAppDelegate showStatusWithText:@"修改一条数据" duration:2.0];
    [_db executeUpdate:query];
}

/**
 * @brief 修改用户的信息
 *
 * @param user 需要修改的用户信息
 */
//有错误，导致存入后数据乱，原因不明，暂时用先删后存的方法
- (void) mergeWithUserByDateTime:(UserInfo *) user {
    if (!user.date_time) {
        return;
    }
    
//    [self mergeWithUserByUID:[self getUserDataByDateTime:user.date_time]];
//    
//    UserInfo * user1 = [self getUserDataByDateTime:user.date_time];
    
    NSString * query = @"UPDATE UserInfo SET";
    NSMutableString * temp = [NSMutableString stringWithCapacity:20];
    // xxx = xxx;
    if (user.uid) {
        [temp appendFormat:@" uid = '%@',",user.uid];
    }
    if (user.date_time) {
        NSNumber*  dateNumber = [NSNumber numberWithDouble:[self getDoubleByTimeString:user.date_time]];
        NSString* dateString = [NSString stringWithFormat:@"%@", dateNumber];
        [temp appendFormat:@" date_time = '%@',",dateString];
    }
    if (user.sun_value) {
        [temp appendFormat:@" sun_value = '%@',",user.sun_value];
    }
    if (user.sun_image_name) {
        [temp appendFormat:@" sun_image_name = '%@',",user.sun_image_name];
    }
    if (user.sun_image_sentence) {
        [temp appendFormat:@" sun_image_sentence = '%@',",user.sun_image_sentence];
    }
    if (user.sun_image) {
        [temp appendFormat:@" sun_image = '%@',",user.sun_image];
    }
    
    if (user.moon_value) {
        [temp appendFormat:@" moon_value = '%@',",user.moon_value];
    }
    if (user.moon_image_name) {
        [temp appendFormat:@" moon_image_name = '%@',",user.moon_image_name];
    }
    if (user.moon_image_sentence) {
        [temp appendFormat:@" moon_image_sentence = '%@',",user.moon_image_sentence];
    }
    if (user.moon_image) {
        [temp appendFormat:@" moon_image = '%@',",user.moon_image];
    }
    
    [temp appendString:@")"];
    query = [query stringByAppendingFormat:@"%@ WHERE date_time = '%@'",[temp stringByReplacingOccurrencesOfString:@",)" withString:@""],user.date_time];
    //NSLog(@"%@",query);
    [MainSunMoonAppDelegate showStatusWithText:@"修改一条数据" duration:2.0];
    if(![_db executeUpdate:query])
    {
        NSLog(@"ERROR: mergeWithUserByDateTime executeUpdate return NO!");
        
    }
    
}

/**
 * @brief 模拟分页查找数据。取uid大于某个值以后的limit个数据
 *
 * @param uid
 * @param limit 每页取多少个
 */
- (NSArray *) findWithUid:(NSString *) uid limit:(int) limit {
    NSString * query = @"SELECT uid,date_time, sun_value,sun_image,sun_image_name, moon_value, moon_image, moon_image_name FROM UserInfo";
    if (!uid) {
        query = [query stringByAppendingFormat:@" ORDER BY uid DESC limit %d",limit];
    } else {
        query = [query stringByAppendingFormat:@" WHERE uid > %@ ORDER BY uid DESC limit %d",uid,limit];
    }
    
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
	while ([rs next]) {
        UserInfo * user = [UserInfo new];
        
        user.uid = [rs stringForColumn:@"uid"];
        user.date_time = [self getDateTimeStringByDoubleDateTime:[rs doubleForColumn:@"date_time"]];
        user.sun_value = [rs stringForColumn:@"sun_value"];
        user.sun_image_name = [rs stringForColumn:@"sun_image_name"];
        user.sun_image_sentence = [rs stringForColumn:@"sun_image_sentence"];
        user.sun_image = [rs dataForColumn:@"sun_image"];
        
        user.moon_value = [rs stringForColumn:@"moon_value"];
        user.moon_image_name = [rs stringForColumn:@"moon_image_name"];
        user.moon_image_sentence = [rs stringForColumn:@"moon_image_sentence"];
        user.moon_image = [rs dataForColumn:@"moon_image"];
        [array addObject:user];
	}
	[rs close];
    return array;
}


- (UserInfo *) findMaxByField:(NSString *) field
{
    NSString * query = @"SELECT uid,date_time, sun_value,sun_image,sun_image_name,sun_image_sentence, moon_value, moon_image, moon_image_name,moon_image_sentence FROM UserInfo ";
    
    query = [query stringByAppendingFormat:@" ORDER BY %@ DESC",field];

    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
	while ([rs next]) {
        UserInfo * user = [UserInfo new];
        
        user.uid = [rs stringForColumn:@"uid"];
        user.date_time = [self getDateTimeStringByDoubleDateTime:[rs doubleForColumn:@"date_time"]];
        user.sun_value = [rs stringForColumn:@"sun_value"];
        user.sun_image_name = [rs stringForColumn:@"sun_image_name"];
        user.sun_image_sentence = [rs stringForColumn:@"sun_image_sentence"];
        user.sun_image = [rs dataForColumn:@"sun_image"];
        
        user.moon_value = [rs stringForColumn:@"moon_value"];
        user.moon_image_name = [rs stringForColumn:@"moon_image_name"];
        user.moon_image_sentence = [rs stringForColumn:@"moon_image_sentence"];
        user.moon_image = [rs dataForColumn:@"moon_image"];
        
        [array addObject:user];
	}
	[rs close];
    

    if ([array count] == 0) {
        return  Nil;
    }
    
    //第一条为最大的一条
    return [array objectAtIndex:0];

}


-(UserInfo*) getUserDataByDateTime: (NSString*) dateTime
{
   // NSString * query = @"SELECT uid,date_time, sun_value,sun_image,sun_image_name,sun_image_sentence, moon_value, moon_image, moon_image_name,moon_image_sentence FROM UserInfo ";
    
    NSNumber*  dateNumber = [NSNumber numberWithDouble:[self getDoubleByTimeString:dateTime]];
    
    NSString * query = @"SELECT * FROM UserInfo ";
    
    if (dateTime.length == 0) {
        return nil;
    }else
    {
        query = [query stringByAppendingFormat:@"WHERE date_time = %@ ", dateNumber];
    }
    
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
	while ([rs next]) {
        UserInfo * user = [UserInfo new];
        
        user.uid = [rs stringForColumn:@"uid"];
        user.date_time = [self getDateTimeStringByDoubleDateTime:[rs doubleForColumn:@"date_time"]];
        user.sun_value = [rs stringForColumn:@"sun_value"];
        user.sun_image_name = [rs stringForColumn:@"sun_image_name"];
        user.sun_image_sentence = [rs stringForColumn:@"sun_image_sentence"];
        user.sun_image = [rs dataForColumn:@"sun_image"];
        
        user.moon_value = [rs stringForColumn:@"moon_value"];
        user.moon_image_name = [rs stringForColumn:@"moon_image_name"];
        user.moon_image_sentence = [rs stringForColumn:@"moon_image_sentence"];
        user.moon_image = [rs dataForColumn:@"moon_image"];
        [array addObject:user];
	}
	[rs close];
    
    if ([array count]>1) {
        NSLog(@"ERROR: date_time =%@, count is %d", dateTime, [array count]);
    }
    
    if ([array count] == 0) {
        return  Nil;
    }
    
    //只能查出一条
    return [array objectAtIndex:0];
        
}


-(NSArray*) getUserImageLimite:(int) limit
{
    NSString * query = @"SELECT uid,date_time, sun_value,sun_image,sun_image_name,sun_image_sentence, moon_value, moon_image, moon_image_name,moon_image_sentence FROM UserInfo ";
    
    if (limit == 0) {
        query = [query stringByAppendingFormat:@"ORDER BY uid"];
    }else
    {
        query = [query stringByAppendingFormat:@"ORDER BY uid DESC limit %d", limit];
    }
    
    FMResultSet * rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[rs columnCount]];
	while ([rs next]) {
        UserInfo * user = [UserInfo new];
        
        user.uid = [rs stringForColumn:@"uid"];
        user.date_time = [self getDateTimeStringByDoubleDateTime:[rs doubleForColumn:@"date_time"]];
        user.sun_value = [rs stringForColumn:@"sun_value"];
        user.sun_image_name = [rs stringForColumn:@"sun_image_name"];
        user.sun_image_sentence = [rs stringForColumn:@"sun_image_sentence"];
        user.sun_image = [rs dataForColumn:@"sun_image"];
        
        user.moon_value = [rs stringForColumn:@"moon_value"];
        user.moon_image_name = [rs stringForColumn:@"moon_image_name"];
        user.moon_image_sentence = [rs stringForColumn:@"moon_image_sentence"];
        user.moon_image = [rs dataForColumn:@"moon_image"];
        [array addObject:user];
	}
	[rs close];
    
    return array;
    
    
    
}

@end
