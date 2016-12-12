//
//  AKAmplitudeTrackerAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAmplitudeTrackerAudioUnit_h
#define AKAmplitudeTrackerAudioUnit_h

#import "AKAudioUnit.h"

@interface AKAmplitudeTrackerAudioUnit : AKAudioUnit
@property (readonly) float amplitude;
@end

#endif /* AKAmplitudeTrackerAudioUnit_h */
