//
//  AKEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKEqualizerFilterAudioUnit_h
#define AKEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKEqualizerFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;
@property (nonatomic) float gain;

@property double rampTime;

@end

#endif /* AKEqualizerFilterAudioUnit_h */
