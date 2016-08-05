//
//  AKKorgLowPassFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKKorgLowPassFilterAudioUnit_h
#define AKKorgLowPassFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKKorgLowPassFilterAudioUnit : AUAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@property (nonatomic) float saturation;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKKorgLowPassFilterAudioUnit_h */
