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

-(void)upateUserInfo:(UserInfo *) user
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置content-type
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    //[params setValue:user.user_id forKey:@"user_id"];
    
    ShareType  type = [user.sns_id substringFromIndex:0].integerValue;
    NSString* typeString = [NSString stringWithFormat:@"%d", type];
    
    [params setValue:user.name forKey:@"name"];
    [params setValue:user.sns_id forKey:@"sns_id"];
    [params setValue:typeString forKey:@"pf"];
    [params setValue:user.sun_value forKey:@"sun_value"];
    [params setValue:user.moon_value forKey:@"moon_value"];
    NSLog(@"upateUserInfo--params = %@", params.descriptionInStringsFileFormat);

    //NSDictionary *params1 = @{@"cmd":@"0", @"id":@"001"};

    [manager GET:@"http://115.28.36.43/app_userinfo.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"upateUserInfo--Succ JSON: %@", responseObject);
  
        NSDictionary *responseDic =(NSDictionary *)responseObject;

        NSLog(@"upateUserInfo--Syn NetWork Succ return all NSDictionary:%@", responseDic);

        NSNumber* codeReturn = [responseDic objectForKey:@"code"];
        
        if ([codeReturn isEqualToNumber:[NSNumber numberWithInteger:CLOUD_SUCC]]) {
            NSLog(@"upateUserInfo--Syn data succ return");
            [_userInfoCloudDelegate updateUserInfoSuccReturn];
        }else
        {
            //失败
            NSLog(@"upateUserInfo--Syn data failed return msg:%@", [responseDic objectForKey:@"msg"]);
            [_userInfoCloudDelegate updateUserInfoFailedReturn];

        }
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"upateUserInfo--Syn NetWork Failed return: %@", error);

        [_userInfoCloudDelegate updateUserInfoFailedReturnByNetWork];

    }];


}


-(void) GetCloudUserInfo:(UserInfo *) user
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //设置content-type
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    //[params setValue:user.user_id forKey:@"user_id"];
    
    ShareType  type = [user.sns_id substringFromIndex:0].integerValue;
    NSString* typeString = [NSString stringWithFormat:@"%d", type];
    
    [params setValue:user.name forKey:@"name"];
    [params setValue:user.sns_id forKey:@"sns_id"];
    [params setValue:typeString forKey:@"pf"];
    NSLog(@"GetCloudUserInfo--params = %@", params.descriptionInStringsFileFormat);
    
    
    [manager GET:@"http://115.28.36.43/app_userinfo.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetCloudUserInfo-- Succ JSON: %@", responseObject);
        
        NSDictionary *responseDic =(NSDictionary *)responseObject;
        
        NSLog(@"GetCloudUserInfo-- Syn NetWork Succ return all NSDictionary:%@", responseDic);
        
        NSNumber *codeReturn = [responseDic objectForKey:@"code"];

        if ([codeReturn isEqualToNumber:[NSNumber numberWithInteger:CLOUD_SUCC]]) {
            //成功
            NSDictionary *dataInfo = (NSDictionary *)[responseDic objectForKey:@"data"];
            if (!dataInfo) {
                NSLog(@"GetCloudUserInfo--dataInfo == null");
            }else
            {
                
                NSArray *strarray = [[responseDic objectForKey:@"data"] componentsSeparatedByString:@"\""];
                NSString *strTemp;
                NSMutableDictionary *dataInfo=[[NSMutableDictionary alloc] init];
                for(int i=0;i<strarray.count;i++)
                {
                    //NSLog(@"%@",[strarray objectAtIndex:i]);
                    NSString *str = [strarray objectAtIndex:i];
                    if([str isEqualToString:@"sun_value"])//最高温度
                    {
                        strTemp = [strarray objectAtIndex:i+2];
                        [dataInfo setValue:strTemp forKey:@"sun_value"];

                        
                    }else if ([str isEqualToString:@"moon_value"])
                    {
                        strTemp = [strarray objectAtIndex:i+2];
                        [dataInfo setValue:strTemp forKey:@"moon_value"];
                    }
                    
                }

                NSLog(@"GetCloudUserInfo--Syn data succ return data:%@", dataInfo);
                [_userInfoCloudDelegate getUserInfoFinishReturnDic:dataInfo];
            }

            
        }else if([codeReturn isEqualToNumber:[NSNumber numberWithInteger:CLOUD_ERR_QUERY_NORECORD]])
        {
            //失败
            NSLog(@"GetCloudUserInfo--Syn data failed return msg:%@", [responseDic objectForKey:@"msg"]);
            [_userInfoCloudDelegate getUserInfoFinishFailed];
            
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"GetCloudUserInfo--Syn NetWork Failed return: %@", error);
        
        [_userInfoCloudDelegate getUserInfoFinishFailedByNetWork];
        
    }];
    
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




-(void)getUserImageByUserID:(NSString *) userID
{
    
    
}

@end
