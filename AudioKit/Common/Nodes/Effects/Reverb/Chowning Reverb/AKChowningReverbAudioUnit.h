//
//  AKChowningReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
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
