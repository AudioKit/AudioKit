//
//  AKMoogLadderAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMoogLadderAudioUnit_h
#define AKMoogLadderAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKMoogLadderAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;

@property double rampTime;

@end

#endif /* AKMoogLadderAudioUnit_h */
