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
 audio-rate connecting delay to an oscillator output.
 */

#warning According to the docs, the delay must varied at a-rate, connected to an oscillator but the example given doesn't even do that.  If the most common case is to use an oscillator this should be bundled into the operation as an init case

@interface OCSFlanger : OCSAudio

/// Instantiates the flanger
/// @param sourceSignal Input signal.
/// @param delayTime Delay in seconds
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed)
- (instancetype)initWithSourceSignal:(OCSAudio *)sourceSignal
                           delayTime:(OCSAudio *)delayTime
                            feedback:(OCSControl *)feedback;

@end