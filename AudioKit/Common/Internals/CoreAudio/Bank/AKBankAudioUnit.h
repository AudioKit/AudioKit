//
//  AKBankAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKBankAudioUnit : AKAudioUnit

@property AUParameter *attackDurationAUParameter;
@property AUParameter *decayDurationAUParameter;
@property AUParameter *sustainLevelAUParameter;
@property AUParameter *releaseDurationAUParameter;
@property AUParameter *pitchBendAUParameter;
@property AUParameter *vibratoDepthAUParameter;
@property AUParameter *vibratoRateAUParameter;
@property AUParameter *detuningOffsetAUParameter;

@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;
@property (nonatomic) float pitchBend;
@property (nonatomic) float vibratoDepth;
@property (nonatomic) float vibratoRate;
@property (nonatomic) float detuningOffset;

- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity;
- (void)startNote:(uint8_t)note velocity:(uint8_t)velocity frequency:(float)frequency;
- (void)stopNote:(uint8_t)note;

- (NSArray *)standardParameters;
- (void)setKernelPtr:(void *)ptr;

@end
