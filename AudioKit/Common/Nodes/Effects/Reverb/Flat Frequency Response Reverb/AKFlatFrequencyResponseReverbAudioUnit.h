//
//  AKFlatFrequencyResponseReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbAudioUnit_h
#define AKFlatFrequencyResponseReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFlatFrequencyResponseReverbAudioUnit : AUAudioUnit
- (void)setLoopDuration:(float)duration;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKFlatFrequencyResponseReverbAudioUnit_h */
