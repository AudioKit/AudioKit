//
//  AKSawtoothOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKSawtoothOscillatorAudioUnit_h
#define AKSawtoothOscillatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKSawtoothOscillatorAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
@end

#endif /* AKSawtoothOscillatorAudioUnit_h */
