//
//  AKModalResonanceFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKModalResonanceFilterAudioUnit_h
#define AKModalResonanceFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKModalResonanceFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float frequency;
@property (nonatomic) float qualityFactor;

@property double rampTime;

@end

#endif /* AKModalResonanceFilterAudioUnit_h */
