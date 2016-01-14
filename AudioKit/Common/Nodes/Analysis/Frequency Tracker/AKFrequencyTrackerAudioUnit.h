//
//  AKFrequencyTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFrequencyTrackerAudioUnit_h
#define AKFrequencyTrackerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKFrequencyTrackerAudioUnit : AUAudioUnit
- (float)getAmplitude;
- (float)getFrequency;
- (void)setFrequencyLimitsWithMinimum:(float)minimum maximum:(float)maximum;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKFrequencyTrackerAudioUnit_h */
