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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // AFHTTPResponseSerializer就是正常的HTTP请求响应结果:NSData
    // 当请求的返回数据不是JSON,XML,PList,UIImage之外,使用AFHTTPResponseSerializer
    // 例如返回一个html,text...
    //
    // 实际上就是AFN没有对响应数据做任何处理的情况
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc] init];
    [params setValue:@"徐军_2_86BC8853A38BF3E012960D48F12A7B5F" forKey:@"user_id"];
    
   // NSDictionary *dict = @{@"user_id": @"徐军_2_86BC8853A38BF3E012960D48F12A7B5F"};
    NSDictionary *dict = @{@"user_id": @"abc123"};


    // formData是遵守了AFMultipartFormData的对象
    [manager POST:@"http://115.28.36.43/app_userphoto_upload.php?user_id=abc123" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        UIImage *upImage = [UIImage imageNamed:@"延时提示框.png"];
        //NSData *imageData = UIImageJPEGRepresentation(upImage,0.5);
        
        NSData *imageData = UIImagePNGRepresentation(upImage);

        //[formData appendPartWithFormData:imageData name:@"imagefile"];
        [formData appendPartWithFileData:imageData name:@"userpic"
                                fileName:@"img.png" mimeType:@"image/png"];
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"完成 %@", result);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"错误 %@", error.localizedDescription);
        
    }];

    return true;

}


/*
{
    UIImage *upImage = [UIImage imageNamed:@"延时提示框.png"];
    //NSData *imageData = UIImageJPEGRepresentation(upImage,0.5);
    
    NSData *imageData = UIImagePNGRepresentation(upImage);

    NSLog(@"imageData.length = %d",imageData.length);
    //一般方法
    NSString *url = [NSString stringWithFormat:@"http://115.28.36.43/app_userphoto_upload.php?user_id=abc123"];
    NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *weburl = [NSURL URLWithString:webStringURL];

    
    //weburl=[NSURL URLWithString:[[NSURL URLWithString:[[NSString stringWithFormat:@"?user_id=徐军_2_86BC8853A38BF3E012960D48F12A7B5F"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:weburl]absoluteString]];
   
    //weburl=[NSURL URLWithString:[[NSURL URLWithString:[[NSString stringWithFormat:@"?user_id=960D48F12A7B5F"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] relativeToURL:weburl]absoluteString]];

    
    
    NSLog(@"upimage url=%@\n", weburl.absoluteString);
   
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:weburl
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:5];//请求这个地址， timeoutInterval:10 设置为10s超时：请求时间超过10s会被认为连接不上，连接超时
    
    [request2 setHTTPMethod:@"POST"];//POST请求
    [request2 setHTTPBody:imageData];//body 数据
    [request2 setValue:@"application/octet-stream" forHTTPHeaderField:@"content-type"];//请求头
    [request2 setValue:@"userpic" forHTTPHeaderField:@"content-type"];//请求头
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error:nil];
    NSString *str=[[NSString alloc]initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"updateUserImage----\n string:%@\n",str);
    
    return TRUE;

}
*/


-(void)getUserImageByUserID:(NSString *) userID
{
    
    
}

@end
