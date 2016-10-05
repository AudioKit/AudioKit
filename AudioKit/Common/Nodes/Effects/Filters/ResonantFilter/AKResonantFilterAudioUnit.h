//
//  AKResonantFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKResonantFilterAudioUnit_h
#define AKResonantFilterAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKResonantFilterAudioUnit : AUAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float bandwidth;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKResonantFilterAudioUnit_h */
