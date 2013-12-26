//
//  OCSFlanger.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Flange effect
 
 This is useful for generating choruses and flangers. The delay must be varied at
 audio-rate.
 */

#warning Should consider replacing this with an OCSSimpleWaveGuideModel (wguide1) implementation since it allows for more flexibility.

@interface OCSFlanger : OCSAudio

/// Instantiates the flanger
/// @param sourceSignal Input signal.
/// @param delayTime Delay in seconds
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed)
- (instancetype)initWithSourceSignal:(OCSAudio *)sourceSignal
                           delayTime:(OCSAudio *)delayTime
                            feedback:(OCSControl *)feedback;

@end