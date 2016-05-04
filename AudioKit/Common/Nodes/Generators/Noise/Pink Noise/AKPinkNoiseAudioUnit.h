//
//  AKPinkNoiseAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPinkNoiseAudioUnit_h
#define AKPinkNoiseAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPinkNoiseAudioUnit : AUAudioUnit
@property (nonatomic) float amplitude;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKPinkNoiseAudioUnit_h */
