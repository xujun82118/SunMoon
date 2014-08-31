//
//  UserInfoCloud.m
//  SunMoon
//
//  Created by songwei on 14-4-16.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "UserInfoCloud.h"
#import<SystemConfiguration/SystemConfiguration.h>
#import<netdb.h>
#import "AFNetworking.h"

@implementation UserInfoCloud

- (id) init {
    self = [super init];
    if (self) {

        //[self connectedToNetwork];
    }
    return self;
}

-(BOOL)upateUserInfo:(UserInfo *) user
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置content-type
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:user.user_id forKey:@"user_id"];
    [params setValue:user.name forKey:@"name"];
    [params setValue:user.sns_id forKey:@"sns_id"];
    [params setValue:user.sun_value forKey:@"sun_value"];
    [params setValue:user.moon_value forKey:@"moon_value"];
    NSLog(@"upateUserInfo--params = %@", params.descriptionInStringsFileFormat);

    //NSDictionary *params1 = @{@"cmd":@"0", @"id":@"001"};

    [manager GET:@"http://115.28.36.43/app_userinfo.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Succ JSON: %@", responseObject);
  
        NSDictionary *responseDic =(NSDictionary *)responseObject;

        NSLog(@"Syn Succ return msg:%@", [responseDic objectForKey:@"msg"]);

        NSDictionary *dataInfo = [responseDic objectForKey:@"data"];
        
        [_userInfoCloudDelegate getUserInfoFinishReturnDic:dataInfo];

        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        
        [_userInfoCloudDelegate getUserInfoFinishFailed];

    }];

    return TRUE;

}



/**
 * @brief 云同步用户IMAGE
 *
 * @param image 需要同步的用户IMAGE
 */
-(BOOL)updateUserImage:(NSData *) image
{
    UIImage *upImage = [UIImage imageNamed:@"082134130b4b7550a73542.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(upImage,0.5);
    
    
    //一般方法
    NSURL *url=[NSURL URLWithString:@"http://115.28.36.43/cgi-bin/app_userphoto_upload"];//创建URL
   url=[NSURL URLWithString:[[NSURL URLWithString:@"?user_id=123" relativeToURL:url]absoluteString]];
    
    NSLog(@"upimage url=%@\n", url.absoluteString);
   
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:5];//请求这个地址， timeoutInterval:10 设置为10s超时：请求时间超过10s会被认为连接不上，连接超时
    
    [request2 setHTTPMethod:@"POST"];//POST请求
    [request2 setHTTPBody:imageData];//body 数据
    [request2 setValue:@"application/octet-stream" forHTTPHeaderField:@"content-type"];//请求头
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error:nil];
    NSString *str=[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"updateUserImage----\n string:%@\n",str);
    
    return TRUE;

}


-(void)getUserInfoBySnsId:(NSString *) snsID  userName:(NSString *) userName
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置content-type
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:snsID forKey:@"name"];
    [params setValue:userName forKey:@"sns_id"];
    NSLog(@"getUserInfoBySnsId--params = %@", params.descriptionInStringsFileFormat);
    
    
    [manager GET:@"http://115.28.36.43/cgi-bin/app_userinfo" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSArray *postsFromResponse = [responseObject valueForKeyPath:@"data"];
        UserInfo* userPost = [[UserInfo alloc] initWithArray:postsFromResponse];
        [_userInfoCloudDelegate getUserInfoFinishReturn:userPost];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_userInfoCloudDelegate getUserInfoFinishReturn:nil];

        
    }];
    
    
}

-(void)getUserImageByUserID:(NSString *) userID
{
    
    
}

@end
