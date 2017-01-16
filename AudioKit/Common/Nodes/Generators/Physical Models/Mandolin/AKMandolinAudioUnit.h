//
//  AKMandolinAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKMandolinAudioUnit : AKAudioUnit
@property (nonatomic) float detune;
@property (nonatomic) float bodySize;

- (void)setFrequency:(float)frequency course:(int)course;
- (void)pluckCourse:(int)course position:(float)position velocity:(int)velocity;
- (void)muteCourse:(int)course;

@end

