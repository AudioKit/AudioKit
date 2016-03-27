//
//  AKModalResonanceFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKModalResonanceFilterAudioUnit_h
#define AKModalResonanceFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKModalResonanceFilterAudioUnit : AUAudioUnit
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;

@property double rampTime;

@end

#endif /* AKModalResonanceFilterAudioUnit_h */
