//
//  AKCombFilterReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCombFilterReverbAudioUnit_h
#define AKCombFilterReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>
#import "AKAudioUnitType.h"

@interface AKCombFilterReverbAudioUnit : AUAudioUnit<AKAudioUnitType>
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;

@property double rampTime;

@end

#endif /* AKCombFilterReverbAudioUnit_h */
