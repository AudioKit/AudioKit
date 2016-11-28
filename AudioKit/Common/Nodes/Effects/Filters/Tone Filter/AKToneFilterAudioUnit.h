//
//  AKToneFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneFilterAudioUnit_h
#define AKToneFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKToneFilterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float halfPowerPoint;

@property double rampTime;

@end

#endif /* AKToneFilterAudioUnit_h */
