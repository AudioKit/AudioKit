//
//  AKStringResonatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKStringResonatorAudioUnit_h
#define AKStringResonatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKStringResonatorAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float fundamentalFrequency;
@property (nonatomic) float feedback;

@property double rampTime;

@end

#endif /* AKStringResonatorAudioUnit_h */
