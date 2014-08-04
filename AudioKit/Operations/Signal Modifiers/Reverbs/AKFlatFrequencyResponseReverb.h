//
//  AKFlatFrequencyResponseReverb.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Reverberates an input signal with a flat frequency response.
 
 This filter reiterates the input with an echo density determined by loop time. The attenuation rate is independent and is determined by the reverberation time (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude).  Output will begin to appear immediately.
 */

@interface AKFlatFrequencyResponseReverb : AKAudio

/// Instantiates the lat frequency response reverb
/// @param audioSource The input signal to be reverberated.
/// @param reverberationTime The time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
/// @param loopTime The loop time in seconds, which determines the “echo density” of the reverberation. This in turn characterizes the “color” of the filter whose frequency response curve will contain ilpt * sr/2 peaks spaced evenly between 0 and sr/2 (the Nyquist frequency). Loop time can be as large as available memory will permit. The space required for an n second loop is 4n*sr bytes.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                  reverberationTime:(AKControl *)reverberationTime
                           loopTime:(AKConstant *)loopTime;

@end