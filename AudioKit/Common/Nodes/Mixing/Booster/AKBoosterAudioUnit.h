//
//  AKBoosterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBoosterAudioUnit_h
#define AKBoosterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKBoosterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float gain;

@property double rampTime;

@end

#endif /* AKBoosterAudioUnit_h */
