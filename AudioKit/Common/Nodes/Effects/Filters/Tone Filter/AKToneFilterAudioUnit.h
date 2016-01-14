//
//  AKToneFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneFilterAudioUnit_h
#define AKToneFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKToneFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKToneFilterAudioUnit_h */
