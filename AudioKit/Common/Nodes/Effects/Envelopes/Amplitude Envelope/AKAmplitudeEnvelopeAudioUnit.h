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
#import "AKAudioUnitType.h"

@interface AKAmplitudeEnvelopeAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float attackDuration;
@property (nonatomic) float decayDuration;
@property (nonatomic) float sustainLevel;
@property (nonatomic) float releaseDuration;

@property double rampTime;

@end

#endif /* AKAmplitudeEnvelopeAudioUnit_h */
