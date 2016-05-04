//
//  AKStringResonatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKStringResonatorAudioUnit_h
#define AKStringResonatorAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKStringResonatorAudioUnit : AUAudioUnit
@property (nonatomic) float fundamentalFrequency;
@property (nonatomic) float feedback;

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKStringResonatorAudioUnit_h */
