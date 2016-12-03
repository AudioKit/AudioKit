//
//  AKKorgLowPassFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKKorgLowPassFilterAudioUnit_h
#define AKKorgLowPassFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKKorgLowPassFilterAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@property (nonatomic) float saturation;
@end

#endif /* AKKorgLowPassFilterAudioUnit_h */
