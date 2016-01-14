//
//  AKModalResonanceFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKModalResonanceFilterAudioUnit_h
#define AKModalResonanceFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKModalResonanceFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKModalResonanceFilterAudioUnit_h */
