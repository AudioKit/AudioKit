//
//  AKAmplitudeTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAmplitudeTrackerAudioUnit_h
#define AKAmplitudeTrackerAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKAmplitudeTrackerAudioUnit : AUAudioUnit
- (float)getAmplitude;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKAmplitudeTrackerAudioUnit_h */
