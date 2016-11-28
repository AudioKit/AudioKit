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
#import "AKAudioUnitType.h"

@interface AKThreePoleLowpassFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float distortion;
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;

@property double rampTime;

@end

#endif /* AKThreePoleLowpassFilterAudioUnit_h */
