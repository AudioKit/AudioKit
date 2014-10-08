//
//  AKCombFilter.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/13/14
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Reverberates an input signal with a “colored” frequency response.
 
 This filter reiterates input with an echo density determined by loopTime. The attenuation rate is independent and is determined by reverbTime, the reverberation time (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude). Output from a comb filter will appear only after loopTime seconds.
 
 */

@interface AKCombFilter : AKAudio

/// Instantiates the comb filter
/// @param audioSource Input Audio Signal
/// @param reverbTime  The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude.
/// @param loopTime    Determines frequency response curve, loopTime * sr/2 peaks spaced evenly between 0 and sr/2.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                         reverbTime:(AKControl *)reverbTime
                           loopTime:(AKConstant *)loopTime;

/// Set an optional delay offset.
/// @param isFeedbackRetained Initial disposition of delay-loop data space. True retains previous information in feedback loop.
- (void)setOptionalRetainFeedbackFlag:(BOOL)isFeedbackRetained;

@end
