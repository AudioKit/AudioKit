//
//  AKMetalBarAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKMetalBarAudioUnit : AKAudioUnit
@property (nonatomic) float leftBoundaryCondition;
@property (nonatomic) float rightBoundaryCondition;
@property (nonatomic) float decayDuration;
@property (nonatomic) float scanSpeed;
@property (nonatomic) float position;
@property (nonatomic) float strikeVelocity;
@property (nonatomic) float strikeWidth;

- (void)trigger;

@end


