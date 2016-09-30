//
//  AKDripAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKDripAudioUnit_h
#define AKDripAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKDripAudioUnit : AUAudioUnit
@property (nonatomic) float intensity;
@property (nonatomic) float dampingFactor;
@property (nonatomic) float energyReturn;
@property (nonatomic) float mainResonantFrequency;
@property (nonatomic) float firstResonantFrequency;
@property (nonatomic) float secondResonantFrequency;
@property (nonatomic) float amplitude;

- (void)trigger;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKDripAudioUnit_h */
