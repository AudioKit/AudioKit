//
//  AKPinkNoiseAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPinkNoiseAudioUnit_h
#define AKPinkNoiseAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKPinkNoiseAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float amplitude;

@property double rampTime;

@end

#endif /* AKPinkNoiseAudioUnit_h */
