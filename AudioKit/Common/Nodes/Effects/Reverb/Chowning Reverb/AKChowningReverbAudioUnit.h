//
//  AKChowningReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKChowningReverbAudioUnit_h
#define AKChowningReverbAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKChowningReverbAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKChowningReverbAudioUnit_h */
