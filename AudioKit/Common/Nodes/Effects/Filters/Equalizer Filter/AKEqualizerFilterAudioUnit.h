//
//  AKEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKEqualizerFilterAudioUnit_h
#define AKEqualizerFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKEqualizerFilterAudioUnit : AKAudioUnit
@property (nonatomic) float centerFrequency;
@property (nonatomic) float bandwidth;
@property (nonatomic) float gain;
@end

#endif /* AKEqualizerFilterAudioUnit_h */
