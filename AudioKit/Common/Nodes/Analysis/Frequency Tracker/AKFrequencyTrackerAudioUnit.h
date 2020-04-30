// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKAudioUnit.h"

@interface AKFrequencyTrackerAudioUnit : AKAudioUnit
@property (readonly) float amplitude;
@property (readonly) float frequency;
- (void)setHopSize:(UInt32)hopSize;
- (void)setPeakCount:(UInt32)peakCount;

@end
