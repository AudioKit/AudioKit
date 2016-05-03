//
//  AKAmplitudeEnvelopeAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAmplitudeEnvelopeAudioUnit_h
#define AKAmplitudeEnvelopeAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKAmplitudeEnvelopeAudioUnit : AUAudioUnit
@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKAmplitudeEnvelopeAudioUnit_h */
