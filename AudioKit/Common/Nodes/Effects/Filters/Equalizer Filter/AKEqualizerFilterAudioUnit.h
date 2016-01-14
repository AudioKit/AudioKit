//
//  AKEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKEqualizerFilterAudioUnit_h
#define AKEqualizerFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKEqualizerFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKEqualizerFilterAudioUnit_h */
