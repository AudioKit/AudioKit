//
//  AKHighShelfParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKHighShelfParametricEqualizerFilterAudioUnit_h
#define AKHighShelfParametricEqualizerFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKHighShelfParametricEqualizerFilterAudioUnit : AKAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;
@end

#endif /* AKHighShelfParametricEqualizerFilterAudioUnit_h */
