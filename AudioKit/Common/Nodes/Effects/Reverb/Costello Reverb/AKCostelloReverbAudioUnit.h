//
//  AKCostelloReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCostelloReverbAudioUnit_h
#define AKCostelloReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKCostelloReverbAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float feedback;
@property (nonatomic) float cutoffFrequency;

@property double rampTime;

@end

#endif /* AKCostelloReverbAudioUnit_h */
