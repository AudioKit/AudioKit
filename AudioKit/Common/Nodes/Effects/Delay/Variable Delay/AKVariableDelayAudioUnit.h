//
//  AKVariableDelayAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVariableDelayAudioUnit_h
#define AKVariableDelayAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKVariableDelayAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float time;
@property (nonatomic) float feedback;

@property double rampTime;

@end

#endif /* AKVariableDelayAudioUnit_h */
