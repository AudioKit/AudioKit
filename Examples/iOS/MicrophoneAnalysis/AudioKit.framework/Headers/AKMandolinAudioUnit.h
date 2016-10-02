//
//  AKMandolinAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMandolinAudioUnit_h
#define AKMandolinAudioUnit_h

#import <AudioToolbox/AudioToolbox.h>

@interface AKMandolinAudioUnit : AUAudioUnit
@property (nonatomic) float detune;
@property (nonatomic) float bodySize;

- (void)setFrequency:(float)frequency course:(int)course;
- (void)pluckCourse:(int)course position:(float)position velocity:(int)velocity;
- (void)muteCourse:(int)course;

//- (void)startNote:(int)note velocity:(int)velocity;
//- (void)stopNote:(int)note;
- (void)setUpParameterRamp;
- (BOOL)isSetUp;

@property double rampTime;

@end

#endif /* AKMandolinAudioUnit_h */
