//
//  AKThreePoleLowpassFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKThreePoleLowpassFilterAudioUnit_h
#define AKThreePoleLowpassFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKThreePoleLowpassFilterAudioUnit : AUAudioUnit
@property (nonatomic) float distortion;
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKThreePoleLowpassFilterAudioUnit_h */
