//
//  AKFrequencyTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKAudioUnit.h"

@interface AKFrequencyTrackerAudioUnit : AKAudioUnit
@property (readonly) float amplitude;
@property (readonly) float frequency;
- (void)setHopSize:(UInt32)hopSize;
- (void)setPeakCount:(UInt32)peakCount;

@end
