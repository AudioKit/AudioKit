//
//  OCSPluckString.h
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Produces a naturally decaying string sound based on the Karplus-Strong algorithms.

 An internal audio buffer,, is continually resampled at the Resampling Frequency and the resulting output is multiplied by the amplitude. Parallel with the sampling, the buffer is smoothed to simulate the effect of natural decay.
 
 This is an implementation of the string portion of "pluck"
 http://www.csounds.com/manual/html/pluck.html
 
 */

@interface OCSPluckString : OCSOpcode

/// Audio output of the string.
@property (nonatomic, strong) OCSParam *output;

/// Initializes the string with simple averaging smoothing process.
/// @param amplitude           The output amplitude.
/// @param resamplingFrequency The resampling frequency in cycles-per-second.
/// @param pitchDecayFrequency Intended pitch value in Hz, used to set up a buffer of 1 cycle of audio samples which will be smoothed over time by a chosen decay method.  Normally anticipates the resampling frequency, but may be set artificially high or low to influence the size of the sample buffer.
/// @param audioBuffer        The output of a function table used to initialize the cyclic decay buffer. If set to zero, a random sequence will be used instead.
- (id) initWithSimpleAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                            ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                            PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    AudioBuffer:(OCSParamConstant *)audioBuffer;

/// Initializes the string with a stretched averaging.
/// @param amplitude           The output amplitude.
/// @param resamplingFrequency The resampling frequency in cycles-per-second.
/// @param pitchDecayFrequency Intended pitch value in Hz, used to set up a buffer of 1 cycle of audio samples which will be smoothed over time by a chosen decay method.  Normally anticipates the resampling frequency, but may be set artificially high or low to influence the size of the sample buffer.
/// @param audioBuffer        The output of a function table used to initialize the cyclic decay buffer. If set to zero, a random sequence will be used instead.
/// @param stretchFactor     Must be greater than or equal to 1.
- (id) initWithStretchedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                               ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                               PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                       AudioBuffer:(OCSParamConstant *)audioBuffer
                                     StretchFactor:(OCSParamConstant *)stretchFactor;

/// Initializes the string with weighted averaging.
/// @param amplitude           The output amplitude.
/// @param resamplingFrequency The resampling frequency in cycles-per-second.
/// @param pitchDecayFrequency Intended pitch value in Hz, used to set up a buffer of 1 cycle of audio samples which will be smoothed over time by a chosen decay method.  Normally anticipates the resampling frequency, but may be set artificially high or low to influence the size of the sample buffer.
/// @param audioBuffer        The output of a function table used to initialize the cyclic decay buffer. If set to zero, a random sequence will be used instead.
/// @param currentWeight      Weighting the current sample (the status quo).
/// @param previousWeight     Weighting the previous sample.  Sum of current and previous wiehgt must less than or equal to 1.
- (id) initWithWeightedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                              ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                              PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                      AudioBuffer:(OCSParamConstant *)audioBuffer
                                    CurrentWeight:(OCSParamConstant *)currentWeight
                                   PreviousWeight:(OCSParamConstant *)previousWeight;

/// Initializes the string with first order recursive filter with coefficients of 0.5.
/// @param amplitude           The output amplitude.
/// @param resamplingFrequency The resampling frequency in cycles-per-second.
/// @param pitchDecayFrequency Intended pitch value in Hz, used to set up a buffer of 1 cycle of audio samples which will be smoothed over time by a chosen decay method.  Normally anticipates the resampling frequency, but may be set artificially high or low to influence the size of the sample buffer.
/// @param audioBuffer        The output of a function table used to initialize the cyclic decay buffer. If set to zero, a random sequence will be used instead.
- (id) initWithRecursiveFilterDecayAndAmplitude:(OCSParamControl *)amplitude
                            ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                            PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    AudioBuffer:(OCSParamConstant *)audioBuffer;

;@end
