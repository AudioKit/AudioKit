//
//  AKFrequencyTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFrequencyTrackerAudioUnit_h
#define AKFrequencyTrackerAudioUnit_h

#import "AKAudioUnit.h"

@interface AKFrequencyTrackerAudioUnit : AKAudioUnit
@property (readonly) float amplitude;
@property (readonly) float frequency;
@end

#endif /* AKFrequencyTrackerAudioUnit_h */
