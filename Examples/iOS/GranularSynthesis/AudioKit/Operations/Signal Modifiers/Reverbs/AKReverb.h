//
//  AKReverb.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"
#import "AKControl.h"

/** 8 delay line stereo FDN reverb, with feedback matrix based upon physical
 modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.
 */

@interface AKReverb : AKStereoAudio

/// Apply reverb to a stereo signal
/// @param sourceStereo    Input to the left and right channel.
/// @param feedbackLevel   Degree of feedback, in the range 0 to 1. 0.6 gives a good small "live" room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
/// @param cutoffFrequency Cutoff frequency of simple first order lowpass filters in the feedback loop of delay lines, in Hz.  A lower value means faster decay in the high frequency range.
- (instancetype)initWithSourceStereoAudio:(AKStereoAudio *)sourceStereo
                            feedbackLevel:(AKControl *)feedbackLevel
                          cutoffFrequency:(AKControl *)cutoffFrequency;

/// Apply reverb to a mono signal
/// @param audioSource       Input to both channels.
/// @param feedbackLevel   Degree of feedback, in the range 0 to 1. 0.6 gives a good small "live" room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
/// @param cutoffFrequency Cutoff frequency of simple first order lowpass filters in the feedback loop of delay lines, in Hz.  A lower value means faster decay in the high frequency range.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                      feedbackLevel:(AKControl *)feedbackLevel
                    cutoffFrequency:(AKControl *)cutoffFrequency;



@end
