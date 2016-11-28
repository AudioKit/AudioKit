//
//  AKLowShelfParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowShelfParametricEqualizerFilterAudioUnit_h
#define AKLowShelfParametricEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKLowShelfParametricEqualizerFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float cornerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;

@property double rampTime;

@end

#endif /* AKLowShelfParametricEqualizerFilterAudioUnit_h */
