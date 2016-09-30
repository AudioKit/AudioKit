//
//  AKToneComplementFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneComplementFilterAudioUnit_h
#define AKToneComplementFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKToneComplementFilterAudioUnit : AUAudioUnit
@property (nonatomic) float halfPowerPoint;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKToneComplementFilterAudioUnit_h */
