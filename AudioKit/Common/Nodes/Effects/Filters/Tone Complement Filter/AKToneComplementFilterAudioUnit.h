//
//  AKToneComplementFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneComplementFilterAudioUnit_h
#define AKToneComplementFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKToneComplementFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float halfPowerPoint;

@property double rampTime;

@end

#endif /* AKToneComplementFilterAudioUnit_h */
