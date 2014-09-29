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
@synthesize guidInfo=_guidInfo, guidIntoCamera=_guidIntoCamera,guidTapLight=_guidTapLight,guid2SDelay=_guid2SDelay,guidPanToBring=_guidPanToBring, guidHaveTakePhoto = _guidHaveTakePhoto, guidHaveGiveLight = _guidHaveGiveLight;

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

    BOOL Rtemp = [_guidInfo boolForKey:KEY_GUID_FIRSTLY_OPEN];

    return Rtemp;
    

}


-(void) updateFirstlyOpenGuidCtl:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_FIRSTLY_OPEN];
    [_guidInfo synchronize];
    
    _fristlyOpenGuidCtl = isGuid;

    
}

- (BOOL)guidIntoCamera {
    
    return [_guidInfo boolForKey:KEY_GUID_INTO_CAMERA];
    
}

-(void) updateGuidIntoCamera:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_INTO_CAMERA];
    [_guidInfo synchronize];
    
    _guidIntoCamera = isGuid;
    
    
}

- (BOOL)guidTapLight {
    
    return [_guidInfo boolForKey:KEY_GUID_TAP_BRING_LIGHT];
    
}

-(void) updateGuidITapLight:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_TAP_BRING_LIGHT];
    [_guidInfo synchronize];
    
    _guidTapLight = isGuid;
    
    
}

- (BOOL)guid2SDelay {
    
    return [_guidInfo boolForKey:KEY_GUID_2S_DELAY];
    
}

-(void) updateGuid2sDelay:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_2S_DELAY];
    [_guidInfo synchronize];
    
    _guid2SDelay = isGuid;
    
    
}

- (BOOL)guidPanToBring {
    
    return [_guidInfo boolForKey:KEY_GUID_PAN_TO_BRING];
    
}

-(void) updateGuidPanToBring:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_PAN_TO_BRING];
    [_guidInfo synchronize];
    
    _guidPanToBring = isGuid;
    
    
}


- (BOOL)guidHaveTakePhoto {
    
    return [_guidInfo boolForKey:KEY_GUID_HAVE_TAKE_PHOTO];
    
}

-(void) updateGuidHaveTakePhoto:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_HAVE_TAKE_PHOTO];
    [_guidInfo synchronize];
    
    _guidHaveTakePhoto = isGuid;
    
    
}


- (BOOL)guidHaveGiveLight {
    
    return [_guidInfo boolForKey:KEY_GUID_HAVE_GIVEN_LIGHT];
    
}

-(void) updateGuidHaveGiveLight:(BOOL) isGuid
{
    [_guidInfo setBool:isGuid forKey:KEY_GUID_HAVE_GIVEN_LIGHT];
    [_guidInfo synchronize];
    
    _guidHaveGiveLight = isGuid;
    
    
}



@end
