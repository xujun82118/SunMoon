//
//  GuidController.h
//  SunMoon
//
//  Created by songwei on 14-8-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuidController : NSObject

@property(nonatomic)  NSUserDefaults* guidInfo;

@property(nonatomic) BOOL  fristlyOpenGuidCtl;
@property(nonatomic) BOOL  guidIntoCamera;
//@property(nonatomic) BOOL  guid



+ (GuidController *)sharedSingleUserInfo;

-(instancetype) initDefaultInfoAtFirstOpen:(BOOL) isGuid;

-(void) updateFirstlyOpenGuidCtl:(BOOL) isGuid;




@end
