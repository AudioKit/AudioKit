//
//  AKCompressor.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Compress, limit, expand, duck or gate an audio signal.

 This unit functions as an audio compressor, limiter, expander, or noise gate, using either soft-knee or hard-knee mapping, and with dynamically variable performance characteristics. It takes two audio input signals, affectedAudioSource and controllingAudioSource, the first of which is modified by a running analysis of the second. Both signals can be the same, or the first can be modified by a different controlling signal.
This operation first examines the controllingAudioSource by performing envelope detection. This is directed by two control values attackTime and releaseTime, defining the attack and release time constants (in seconds) of the detector. The detector rides the peaks (not the RMS) of the control signal. Typical values are .01 and .1, the latter usually being similar to lookAheadTime.
The running envelope is next converted to decibels, then passed through a mapping function to determine what compresser action (if any) should be taken. The mapping function is defined by four decibel control values. These are given as positive values, where 0 db corresponds to an amplitude of 1, and 90 db corresponds to an amplitude of 32768.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKCompressor : AKAudio
/// Instantiates the compressor with all values
/// @param input The input signal that will be compressed.
/// @param controllingInput The signal that defines the compression. 
/// @param threshold Sets the lowest decibel level that will be allowed through. Normally 0 or less, but if higher the threshold will begin removing low-level signal energy such as background noise. Updated at Control-rate. [Default Value: 0]
/// @param lowKnee Decibel break-point denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. Updated at Control-rate. [Default Value: 48]
/// @param highKnee Decibel break-points denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. Updated at Control-rate. [Default Value: 60]
/// @param compressionRatio Ratio of compression when the signal level is above the knee. The value 2 will advance the output just one decibel for every input gain of two; 3 will advance just one in three; 20 just one in twenty, etc. Inverse ratios will cause signal expansion: .5 gives two for one, .25 four for one, etc. The value 1 will result in no change. Updated at Control-rate. [Default Value: 1]
/// @param attackTime Attack time in seconds. Updated at Control-rate. [Default Value: 0.1]
/// @param releaseTime Release time in seconds. Updated at Control-rate. [Default Value: 1]
/// @param lookAheadTime Look-ahead time in seconds, by which an internal envelope release can sense what is coming. This induces a delay between input and output, but a small amount of lookahead improves the performance of the envelope detector. Typical value is .05 seconds, sufficient to sense the peaks of the lowest frequency in the controllingAudioSource. [Default Value: 0.05]
- (instancetype)initWithInput:(AKParameter *)input
             controllingInput:(AKParameter *)controllingInput
                    threshold:(AKParameter *)threshold
                      lowKnee:(AKParameter *)lowKnee
                     highKnee:(AKParameter *)highKnee
             compressionRatio:(AKParameter *)compressionRatio
                   attackTime:(AKParameter *)attackTime
                  releaseTime:(AKParameter *)releaseTime
                lookAheadTime:(AKConstant *)lookAheadTime;

/// Instantiates the compressor with default values
/// @param input The input signal that will be compressed.
/// @param controllingInput The signal that defines the compression.
- (instancetype)initWithInput:(AKParameter *)input
             controllingInput:(AKParameter *)controllingInput;

/// Instantiates the compressor with default values
/// @param input The input signal that will be compressed.
/// @param controllingInput The signal that defines the compression.
+ (instancetype)compressorWithInput:(AKParameter *)input
                   controllingInput:(AKParameter *)controllingInput;

/// Sets the lowest decibel level that will be allowed through. Normally 0 or less, but if higher the threshold will begin removing low-level signal energy such as background noise. [Default Value: 0]
@property (nonatomic) AKParameter *threshold;

/// Set an optional threshold
/// @param threshold Sets the lowest decibel level that will be allowed through. Normally 0 or less, but if higher the threshold will begin removing low-level signal energy such as background noise. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalThreshold:(AKParameter *)threshold;

/// Decibel break-point denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. [Default Value: 48]
@property (nonatomic) AKParameter *lowKnee;

/// Set an optional low knee
/// @param lowKnee Decibel break-point denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. Updated at Control-rate. [Default Value: 48]
- (void)setOptionalLowKnee:(AKParameter *)lowKnee;

/// Decibel break-points denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. [Default Value: 60]
@property (nonatomic) AKParameter *highKnee;

/// Set an optional high knee
/// @param highKnee Decibel break-points denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result. Updated at Control-rate. [Default Value: 60]
- (void)setOptionalHighKnee:(AKParameter *)highKnee;

/// Ratio of compression when the signal level is above the knee. The value 2 will advance the output just one decibel for every input gain of two; 3 will advance just one in three; 20 just one in twenty, etc. Inverse ratios will cause signal expansion: .5 gives two for one, .25 four for one, etc. The value 1 will result in no change. [Default Value: 1]
@property (nonatomic) AKParameter *compressionRatio;

/// Set an optional compression ratio
/// @param compressionRatio Ratio of compression when the signal level is above the knee. The value 2 will advance the output just one decibel for every input gain of two; 3 will advance just one in three; 20 just one in twenty, etc. Inverse ratios will cause signal expansion: .5 gives two for one, .25 four for one, etc. The value 1 will result in no change. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalCompressionRatio:(AKParameter *)compressionRatio;

/// Attack time in seconds. [Default Value: 0.1]
@property (nonatomic) AKParameter *attackTime;

/// Set an optional attack time
/// @param attackTime Attack time in seconds. Updated at Control-rate. [Default Value: 0.1]
- (void)setOptionalAttackTime:(AKParameter *)attackTime;

/// Release time in seconds. [Default Value: 1]
@property (nonatomic) AKParameter *releaseTime;

/// Set an optional release time
/// @param releaseTime Release time in seconds. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalReleaseTime:(AKParameter *)releaseTime;

/// Look-ahead time in seconds, by which an internal envelope release can sense what is coming. This induces a delay between input and output, but a small amount of lookahead improves the performance of the envelope detector. Typical value is .05 seconds, sufficient to sense the peaks of the lowest frequency in the controllingAudioSource. [Default Value: 0.05]
@property (nonatomic) AKConstant *lookAheadTime;

/// Set an optional look ahead time
/// @param lookAheadTime Look-ahead time in seconds, by which an internal envelope release can sense what is coming. This induces a delay between input and output, but a small amount of lookahead improves the performance of the envelope detector. Typical value is .05 seconds, sufficient to sense the peaks of the lowest frequency in the controllingAudioSource. [Default Value: 0.05]
- (void)setOptionalLookAheadTime:(AKConstant *)lookAheadTime;



@end
NS_ASSUME_NONNULL_END
