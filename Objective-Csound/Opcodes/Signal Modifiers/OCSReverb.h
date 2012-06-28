//
//  OCSReverb.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** 8 delay line stereo FDN reverb, with feedback matrix based upon physical 
 modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.

 @warning *Completion*  This is not a complete port of the Csound opcode "reverbsc":
 http://www.csounds.com/manual/html/reverbsc.html
 */

@interface OCSReverb : OCSOpcode 

/// The output to the left channel.
@property (nonatomic, strong) OCSParam *outputLeft;
/// The output to the right channel.
@property (nonatomic, strong) OCSParam *outputRight;

/// Apply reverb to a mono signal
/// @param monoInput       Input to both channels.
/// @param feedbackLevel   Degree of feedback, in the range 0 to 1. 0.6 gives a good small "live" room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
/// @param cutoffFrequency Cutoff frequency of simple first order lowpass filters in the feedback loop of delay lines, in Hz.  A lower value means faster decay in the high frequency range.

- (id)initWithMonoInput:(OCSParam *)monoInput
          FeedbackLevel:(OCSParamControl *)feedbackLevel
        CutoffFrequency:(OCSParamControl *)cutoffFrequency;

/// Apply reverb to a stereo signal
/// @param leftInput       Input to the left channel.
/// @param rightInput      Input to the right channel.
/// @param feedbackLevel   Degree of feedback, in the range 0 to 1. 0.6 gives a good small "live" room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
/// @param cutoffFrequency Cutoff frequency of simple first order lowpass filters in the feedback loop of delay lines, in Hz.  A lower value means faster decay in the high frequency range.
- (id)initWithLeftInput:(OCSParam *)leftInput
             RightInput:(OCSParam *)rightInput
          FeedbackLevel:(OCSParamControl *)feedbackLevel
        CutoffFrequency:(OCSParamControl *)cutoffFrequency;

@end
