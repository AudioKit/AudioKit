//
//  AKModalResonanceFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKModalResonanceFilterAudioUnit_h
#define AKModalResonanceFilterAudioUnit_h

#import "AKAudioUnit.h"

@interface AKModalResonanceFilterAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float qualityFactor;
@end

#endif /* AKModalResonanceFilterAudioUnit_h */
