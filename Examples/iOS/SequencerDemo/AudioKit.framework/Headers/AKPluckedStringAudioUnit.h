//
//  AKPluckedStringAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPluckedStringAudioUnit_h
#define AKPluckedStringAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKPluckedStringAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;

- (void)triggerFrequency:(float)frequency amplitude:(float)amplitude;
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKPluckedStringAudioUnit_h */
