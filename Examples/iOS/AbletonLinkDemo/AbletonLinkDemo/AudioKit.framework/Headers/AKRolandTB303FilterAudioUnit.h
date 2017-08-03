//
//  AKRolandTB303FilterAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKRolandTB303FilterAudioUnit : AKAudioUnit
@property (nonatomic) float cutoffFrequency;
@property (nonatomic) float resonance;
@property (nonatomic) float distortion;
@property (nonatomic) float resonanceAsymmetry;
@end
