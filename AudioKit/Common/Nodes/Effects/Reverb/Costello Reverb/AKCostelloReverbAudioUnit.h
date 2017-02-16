//
//  AKCostelloReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKCostelloReverbAudioUnit : AKAudioUnit
@property (nonatomic) float feedback;
@property (nonatomic) float cutoffFrequency;
@end

