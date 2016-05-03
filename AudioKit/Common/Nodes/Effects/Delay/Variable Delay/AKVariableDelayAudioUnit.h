//
//  AKVariableDelayAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVariableDelayAudioUnit_h
#define AKVariableDelayAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKVariableDelayAudioUnit : AUAudioUnit
@property (nonatomic) float time;
@property (nonatomic) float feedback;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKVariableDelayAudioUnit_h */
