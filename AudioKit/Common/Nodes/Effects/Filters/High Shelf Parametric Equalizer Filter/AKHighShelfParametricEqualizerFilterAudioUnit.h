//
//  AKHighShelfParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKHighShelfParametricEqualizerFilterAudioUnit_h
#define AKHighShelfParametricEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKHighShelfParametricEqualizerFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float centerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;

@property double rampTime;

@end

#endif /* AKHighShelfParametricEqualizerFilterAudioUnit_h */
