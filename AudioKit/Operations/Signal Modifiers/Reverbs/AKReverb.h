//
//  AKReverb.h
//  AudioKit
//
//  Auto-generated on 12/24/14.
//  Customized by Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** 8 delay line stereo FDN reverb

 8 delay line stereo FDN reverb, with feedback matrix based upon physical modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.
 */

@interface AKReverb : AKStereoAudio
/// Instantiates the reverb with all values
/// @param audioSourceLeftChannel Input for the left channel [Default Value: ]
/// @param audioSourceRightChannel Input for the right channel [Default Value: ]
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (instancetype)initWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                       audioSourceRightChannel:(AKParameter *)audioSourceRightChannel
                                      feedback:(AKParameter *)feedback
                               cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the reverb with default values
/// @param audioSourceLeftChannel Input for the left channel
/// @param audioSourceRightChannel Input for the right channel
- (instancetype)initWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                       audioSourceRightChannel:(AKParameter *)audioSourceRightChannel;

/// Instantiates the reverb with default values
/// @param audioSourceLeftChannel Input for the left channel
/// @param audioSourceRightChannel Input for the right channel
+ (instancetype)stereoAudioWithAudioSourceLeftChannel:(AKParameter *)audioSourceLeftChannel
                              audioSourceRightChannel:(AKParameter *)audioSourceRightChannel;

/// Instantiates the reverb with all values
/// @param audioSource Input to the reverberator.
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)audioSource
                                 feedback:(AKParameter *)feedback
                          cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the reverb with default values
/// @param audioSource Input to the reverberator.
- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)audioSource;

/// Instantiates the reverb with default values
/// @param audioSource Input to the reverberator.
+ (instancetype)stereoAudioWithStereoAudioSource:(AKStereoAudio *)audioSource;

/// Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. [Default Value: 0.6]
@property AKParameter *feedback;

/// Set an optional feedback
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
- (void)setOptionalFeedback:(AKParameter *)feedback;

/// comment [Default Value: 4000]
@property AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;



@end
