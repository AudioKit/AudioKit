//
//  AKToneFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneFilterAudioUnit_h
#define AKToneFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKToneFilterAudioUnit : AUAudioUnit
@property (nonatomic) float halfPowerPoint;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKToneFilterAudioUnit_h */
