//
//  AKCombFilterReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKCombFilterReverbAudioUnit_h
#define AKCombFilterReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKCombFilterReverbAudioUnit : AUAudioUnit
- (void)setLoopDuration:(float)duration;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKCombFilterReverbAudioUnit_h */
