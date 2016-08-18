//
//  AKBoosterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBoosterAudioUnit_h
#define AKBoosterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKBoosterAudioUnit : AUAudioUnit
@property (nonatomic) float gain;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKBoosterAudioUnit_h */
