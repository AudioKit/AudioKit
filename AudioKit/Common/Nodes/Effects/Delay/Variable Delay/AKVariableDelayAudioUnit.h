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
- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;

@property double rampTime;

@end

#endif /* AKVariableDelayAudioUnit_h */
