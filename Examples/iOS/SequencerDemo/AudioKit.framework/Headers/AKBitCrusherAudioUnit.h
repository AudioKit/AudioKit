//
//  AKBitCrusherAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBitCrusherAudioUnit_h
#define AKBitCrusherAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBitCrusherAudioUnit : AUAudioUnit
@property (nonatomic) float bitDepth;
@property (nonatomic) float sampleRate;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKBitCrusherAudioUnit_h */
