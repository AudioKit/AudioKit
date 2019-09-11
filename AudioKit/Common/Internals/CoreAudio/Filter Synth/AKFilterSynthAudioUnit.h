//
//  AKFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Colin Hallett, revision history on GitHub.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKFilterSynthAudioUnit : AKAudioUnit

@property AUParameter *attackDurationAUParameter;
@property AUParameter *decayDurationAUParameter;
@property AUParameter *sustainLevelAUParameter;
@property AUParameter *releaseDurationAUParameter;
@property AUParameter *pitchBendAUParameter;
@property AUParameter *vibratoDepthAUParameter;
@property AUParameter *vibratoRateAUParameter;
@property AUParameter *filterCutoffFrequencyAUParameter;
@property AUParameter *filterResonanceAUParameter;
@property AUParameter *filterAttackDurationAUParameter;
@property AUParameter *filterDecayDurationAUParameter;
@property AUParameter *filterSustainLevelAUParameter;
@property AUParameter *filterReleaseDurationAUParameter;
@property AUParameter *filterEnvelopeStrengthAUParameter;
@property AUParameter *filterLFODepthAUParameter;
@property AUParameter *filterLFORateAUParameter;

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float pitchBend;
@property (nonatomic) float vibratoDepth;
@property (nonatomic) float vibratoRate;
@property (nonatomic) float filterCutoffFrequency;
@property (nonatomic) float filterResonance;
@property (nonatomic) float filterAttackDuration;
@property (nonatomic) float filterDecayDuration;
@property (nonatomic) float filterSustainLevel;
@property (nonatomic) float filterReleaseDuration;
@property (nonatomic) float filterEnvelopeStrength;
@property (nonatomic) float filterLFODepth;
@property (nonatomic) float filterLFORate;

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
- (void)stopNote:(uint8_t)note;

- (NSArray *)standardParameters;
- (void)setKernelPtr:(void *)ptr;

@end
