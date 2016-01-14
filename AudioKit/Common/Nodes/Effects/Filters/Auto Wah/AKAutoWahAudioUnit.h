//
//  AKAutoWahAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAutoWahAudioUnit_h
#define AKAutoWahAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKAutoWahAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKAutoWahAudioUnit_h */
