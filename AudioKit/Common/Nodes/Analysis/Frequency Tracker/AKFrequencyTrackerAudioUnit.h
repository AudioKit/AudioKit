//
//  AKFrequencyTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFrequencyTrackerAudioUnit_h
#define AKFrequencyTrackerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFrequencyTrackerAudioUnit : AUAudioUnit
- (float)getAmplitude;
- (float)getFrequency;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKFrequencyTrackerAudioUnit_h */
