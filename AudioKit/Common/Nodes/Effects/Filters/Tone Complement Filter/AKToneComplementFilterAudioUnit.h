//
//  AKToneComplementFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKToneComplementFilterAudioUnit_h
#define AKToneComplementFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKToneComplementFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKToneComplementFilterAudioUnit_h */
