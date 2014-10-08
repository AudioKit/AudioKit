//
//  AKCompressor.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Compress, limit, expand, duck or gate an audio signal.
 
 This unit functions as an audio compressor, limiter, expander, or noise gate, using either
 soft-knee or hard-knee mapping, and with dynamically variable performance characteristics.
 It takes two audio input signals, affectedAudioSource and controllingAudioSource, the first of which is modified by a running
 analysis of the second. Both signals can be the same, or the first can be modified by a different
 controlling signal.
 
 This operation first examines the controllingAudioSource by performing envelope detection. This is directed
 by two control values attackTime and releaseTime, defining the attack and release time constants (in seconds)
 of the detector. The detector rides the peaks (not the RMS) of the control signal. Typical values
 are .01 and .1, the latter usually being similar to the optional lookAheadTime.
 
 The running envelope is next converted to decibels, then passed through a mapping function to
 determine what compresser action (if any) should be taken. The mapping function is defined by
 four decibel control values. These are given as positive values, where 0 db corresponds to an
 amplitude of 1, and 90 db corresponds to an amplitude of 32768.
 */

@interface AKCompressor : AKAudio

/// Instantiates the compressor
/// @param affectedAudioSource The audio signal that will be compressed.
/// @param controllingAudioSource The audio signal that defines the compression.
/// @param threshold Sets the lowest decibel level that will be allowed through. Normally 0 or less, but if higher the threshold will begin removing low-level signal energy such as background noise.
/// @param lowKnee Decibel break-points denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result.
/// @param highKnee Decibel break-points denoting where compression or expansion will begin. These set the boundaries of a soft-knee curve joining the low-amplitude 1:1 line and the higher-amplitude compression ratio line. Typical values are 48 and 60 db. If the two breakpoints are equal, a hard-knee (angled) map will result.
/// @param compressionRatio Ratio of compression when the signal level is above the knee. The value 2 will advance the output just one decibel for every input gain of two; 3 will advance just one in three; 20 just one in twenty, etc. Inverse ratios will cause signal expansion: .5 gives two for one, .25 four for one, etc. The value 1 will result in no change.
/// @param attackTime Attack time in seconds.
/// @param releaseTime Release time in seconds.
- (instancetype)initWithAffectedAudioSource:(AKAudio *)affectedAudioSource
                     controllingAudioSource:(AKAudio *)controllingAudioSource
                                  threshold:(AKControl *)threshold
                                    lowKnee:(AKControl *)lowKnee
                                   highKnee:(AKControl *)highKnee
                           compressionRatio:(AKControl *)compressionRatio
                                 attackTime:(AKControl *)attackTime
                                releaseTime:(AKControl *)releaseTime;


/// Set an optional look ahead time
/// @param lookAheadTime Look-ahead time in seconds, by which an internal envelope release can sense what is coming. This induces a delay between input and output, but a small amount of lookahead improves the performance of the envelope detector. Typical value is .05 seconds, sufficient to sense the peaks of the lowest frequency in the controllingAudioSource.
- (void)setOptionalLookAheadTime:(AKConstant *)lookAheadTime;


@end