//
//  AKFlatFrequencyResponseReverbAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "AKAudioUnit.h"

@interface AKFlatFrequencyResponseReverbAudioUnit : AKAudioUnit
@property (nonatomic) float reverbDuration;
- (void)setLoopDuration:(float)duration;
@end

