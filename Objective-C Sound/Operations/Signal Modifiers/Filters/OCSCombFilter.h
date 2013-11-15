//
//  OCSCombFilter.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 4/10/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Comb Filter
 
 Reverberates an input signal with a “colored” frequency response.
 
 This filter reiterates input with an echo density determined by loopTime. The attenuation rate is independent and is determined by reverbTime, the reverberation time (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude). Output from a comb filter will appear only after loopTime seconds.
 
*/

@interface OCSCombFilter : OCSAudio

/// Instantiates the comb filter
/// @param audioSource Input Signal
/// @param reverbTime The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude.
/// @param loopTime Determines frequency response curve, loopTime * sr/2 peaks spaced evenly between 0 and sr/2.
-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
              reverbTime:(OCSControl *)reverbTime
                loopTime:(OCSConstant *)loopTime;

/// Instantiates the comb filter
/// @param audioSource Input Signal
/// @param reverbTime The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude.
/// @param loopTime Determines frequency response curve, loopTime * sr/2 peaks spaced evenly between 0 and sr/2.
/// @param delayAmount Delay amount, in samples.
/// @param isFeedbackRetained Initial disposition of delay-loop data space. True retains previous information in feedback loop.
-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
              reverbTime:(OCSControl *)reverbTime
                loopTime:(OCSConstant *)loopTime
               delayAmount:(OCSConstant *)delayAmount
             isFeedbackRetained:(BOOL)isFeedbackRetained;

/// Set an optional delay amount.
/// @param delayAmount Delay amount, in samples.
-(void)setOptionalDelayAmount:(OCSConstant *)delayAmount;

/// Set an optional delay offset.
/// @param isFeedbackRetained Initial disposition of delay-loop data space. True retains previous information in feedback loop.
-(void)setOptionalRetainFeedbackFlag:(BOOL)isFeedbackRetained;

@end
