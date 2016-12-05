//
//  AKPeakingParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPeakingParametricEqualizerFilterAudioUnit_h
#define AKPeakingParametricEqualizerFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKPeakingParametricEqualizerFilterAudioUnit : AKAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;
@end

#endif /* AKPeakingParametricEqualizerFilterAudioUnit_h */
