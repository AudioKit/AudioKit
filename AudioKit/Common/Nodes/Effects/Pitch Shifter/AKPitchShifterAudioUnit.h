//
//  AKPitchShifterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPitchShifterAudioUnit_h
#define AKPitchShifterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKPitchShifterAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float shift;
@property (nonatomic) float windowSize;
@property (nonatomic) float crossfade;

@property double rampTime;

@end

#endif /* AKPitchShifterAudioUnit_h */
