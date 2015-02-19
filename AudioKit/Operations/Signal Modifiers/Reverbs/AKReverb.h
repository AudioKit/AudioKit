//
//  AKReverb.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** 8 delay line stereo FDN reverb

 8 delay line stereo FDN reverb, with feedback matrix based upon physical modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.
 */

@interface AKReverb : AKStereoAudio
/// Instantiates the reverb with all values
/// @param input Audio input
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (instancetype)initWithInput:(AKParameter *)input
                     feedback:(AKParameter *)feedback
              cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the reverb with default values
/// @param input Audio input
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the reverb with default values
/// @param input Input for the left channel
+ (instancetype)reverbWithInput:(AKParameter *)input;

/// Instantiates the reverb with all values
/// @param input Stereo input to the reverberator.
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (instancetype)initWithStereoInput:(AKStereoAudio *)input
                           feedback:(AKParameter *)feedback
                    cutoffFrequency:(AKParameter *)cutoffFrequency;

/// Instantiates the reverb with default values
/// @param input Input to the reverberator.
- (instancetype)initWithStereoInput:(AKStereoAudio *)input;

/// Instantiates the reverb with default values
/// @param input Input to the reverberator.
+ (instancetype)reverbWithStereoInput:(AKStereoAudio *)input;


/// Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. [Default Value: 0.6]
@property (nonatomic) AKParameter *feedback;

/// Set an optional feedback
/// @param feedback Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable. Updated at Control-rate. [Default Value: 0.6]
- (void)setOptionalFeedback:(AKParameter *)feedback;

/// comment [Default Value: 4000]
@property (nonatomic) AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency comment Updated at Control-rate. [Default Value: 4000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;



@end
