//
//  VoicePressedHold.h
//  SunMoon
//
//  Created by songwei on 14-6-23.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "F3BarGauge.h"


@protocol pitchDelegate;


@interface VoicePressedHold : NSObject <UIGestureRecognizerDelegate,AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    int recordEncoding;
    enum
    {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
    
    float Pitch;
    NSTimer *timerForPitch;
    
    id<pitchDelegate> getPitchDelegate;

    
}
@property(nonatomic)id<pitchDelegate> getPitchDelegate;

@property (weak, nonatomic)  UIImageView *imageView;
@property (weak, nonatomic)  UIProgressView *progressView;
@property (weak, nonatomic)  UIButton *touchbutton;
@property (weak, nonatomic)  UIView *viewForWave;
@property (weak, nonatomic)  UIView *viewForWave2;
@property (nonatomic) CFTimeInterval firstTimestamp;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong)  UILabel *statusLabel;
@property (weak, nonatomic)  F3BarGauge *customRangeBar;
@property (nonatomic) NSUInteger loopCount;
@property (nonatomic) float Pitch;

@property (nonatomic, strong) NSString *voiceName;


-(void) startRecording;
-(void) stopRecording;
-(void) playRecording;
-(void) stopPlaying;
-(void)deleteVoiceFile;
-(BOOL)checkVoiceFile;

- (void) myButtonLongPressed:(UILongPressGestureRecognizer *)gesture;

@end


@protocol pitchDelegate <NSObject>

- (void)setNewPith:(float)pitchValue;
- (void)pitchAudioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

@end

