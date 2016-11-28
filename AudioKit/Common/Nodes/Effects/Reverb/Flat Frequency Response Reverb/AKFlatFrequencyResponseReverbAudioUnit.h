//
//  AKFlatFrequencyResponseReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbAudioUnit_h
#define AKFlatFrequencyResponseReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKFlatFrequencyResponseReverbAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;

@property double rampTime;

@end

#endif /* AKFlatFrequencyResponseReverbAudioUnit_h */
