//
//  AKOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOscillatorAudioUnit_h
#define AKOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKOscillatorAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKOscillatorAudioUnit_h */
