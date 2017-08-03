//
//  AKLowShelfParametricEqualizerFilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKLowShelfParametricEqualizerFilterAudioUnit : AKAudioUnit
@property (nonatomic) float cornerFrequency;
@property (nonatomic) float gain;
@property (nonatomic) float q;
@end

