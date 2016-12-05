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
- (float)getAmplitude;
- (float)getFrequency;
@end

#endif /* AKFrequencyTrackerAudioUnit_h */
