//
//  AKPWMOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKPWMOscillatorAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;
@property (nonatomic) float pulseWidth;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;
@end


