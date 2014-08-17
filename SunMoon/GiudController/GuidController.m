//
//  GuidController.m
//  SunMoon
//
//  Created by songwei on 14-8-17.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "GuidController.h"


@implementation GuidController
@synthesize fristlyOpenGuidCtl=_fristlyOpenGuidCtl;
@synthesize guidInfo=_guidInfo;

static GuidController *sharedGuidCtl;

+ (GuidController *)sharedSingleUserInfo
{
    
    @synchronized(self)
    {
        if (!sharedGuidCtl)
        {
            sharedGuidCtl = [[GuidController alloc] init];
        }
        
        return sharedGuidCtl;
    }
}


- (id) init {
    self = [super init];
    
    _guidInfo = [NSUserDefaults standardUserDefaults];

    return self;
}

- (BOOL)fristlyOpenGuidCtl {

    return [_guidInfo boolForKey:KEY_OPEN_GUID];

}

-(instancetype) initDefaultInfoAtFirstOpen:(BOOL) isGuid
{
    //_guidInfo = [NSUserDefaults standardUserDefaults];
    [_guidInfo setBool:isGuid forKey:KEY_OPEN_GUID];
    [_guidInfo synchronize];
    
    _fristlyOpenGuidCtl = isGuid;
    
    
    return self;
    
}

-(void) updateFirstlyOpenGuidCtl:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_OPEN_GUID];
    [_guidInfo synchronize];
    
    _fristlyOpenGuidCtl = isGuid;

    
}



@end
