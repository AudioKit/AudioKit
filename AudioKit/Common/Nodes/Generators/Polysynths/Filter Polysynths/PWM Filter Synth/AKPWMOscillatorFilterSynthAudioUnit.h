//
//  AKPWMOscillatorFilterSynthAudioUnit.h
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthAudioUnit.h"

@interface AKPWMOscillatorFilterSynthAudioUnit : AKFilterSynthAudioUnit

@property (nonatomic) float pulseWidth;

@end

