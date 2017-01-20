//
//  AKCostelloReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKCostelloReverbAudioUnit : AKAudioUnit
@property (nonatomic) float feedback;
@property (nonatomic) float cutoffFrequency;
@end

