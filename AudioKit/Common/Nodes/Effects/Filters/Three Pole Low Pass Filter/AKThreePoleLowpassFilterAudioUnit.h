//
//  AKThreePoleLowpassFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKThreePoleLowpassFilterAudioUnit_h
#define AKThreePoleLowpassFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKThreePoleLowpassFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKThreePoleLowpassFilterAudioUnit_h */
