//
//  AKFSignalFromMonoWithAttackAnalysis.h
//  AudioKit
//
//  Created by Adam Boulanger on 2/13/13.
//  Copyright (c) 2013 Adam Boulanger. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKFSignal.h"
#import "AKAudio.h"

/* TODO: This file needs to be ported to modern AudioKit naming and commenting standards including removing optional flags from initialization */

/**  Phase vocoder analysis processing with onset detection/processing.
 
 Implements phase vocoder analysis by reading function tables containing sampled-sound
 sources and will accept deferred allocation tables.
 
 This operation allows for time and frequency-independent scaling. Time is advanced
 internally, but controlled by a tempo scaling parameter; when an onset is detected,
 timescaling is momentarily stopped to avoid smearing of attacks. The quality of the
 effect is generally improved with phase locking switched on.
 
 This operation will also scale pitch, independently of frequency, using a transposition
 factor (k-rate).
 
 */

@interface AKFSignalFromMonoWithAttackAnalysis : AKFSignal

/// Create a phase vocoder stream or f-signal from a mono audio source and performs attack analysis.
/// @param soundFileSource  Audio to use to generate the f-signal.
/// @param timeScalingRatio Time scaling ratio, <1 stretches, >1 contracts.
/// @param pitchRatio       Grain pitch scaling ratio (1=normal pitch, <1 lower, >1 higher, <0 backwards)
- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFileSource
                 timeScalingRatio:(AKControl *)timeScalingRatio
                       pitchRatio:(AKControl *)pitchRatio;

/// Create a phase vocoder stream or f-signal from a mono audio source and performs attack analysis.
/// @param soundFileSource  Audio to use to generate the f-signal.
/// @param timeScaler      Time scaling ratio, <1 stretches, >1 contracts.
/// @param amplitudeScaler Amplitude scaling ratio.
/// @param pitchScaler     Grain pitch scaling ration (1=normal pitch, <1 lower, >1 higher, <0 backwards)
/// @param fftSize         The FFT size in samples. Need not be a power of two (though these are especially efficient), but must be even. Odd numbers are rounded up internally. fftSize determines the number of analysis bins in the output, as fftSize/2 + 1. For example, where fftSize = 1024, fsig will contain 513 analysis bins, ordered linearly from the fundamental to Nyquist. The fundamental of analysis (which in principle gives the lowest resolvable frequency) is determined as sample rate/fftSize. Thus, for the example just given and assuming sr = 44100, the fundamental of analysis is 43.07Hz. In practice, due to the phase-preserving nature of the phase vocoder, the frequency of any bin can deviate bilaterally, so that DC components are recorded. Given a strongly pitched signal, frequencies in adjacent bins can bunch very closely together, around partials in the source, and the lowest bins may even have negative frequencies.
/// @param overlap         The distance in samples (“hop size”) between overlapping analysis frames. As a rule, this needs to be at least fftSize/4, e.g. 256 for the example above.  overlap determines the underlying analysis rate, as sample rate/overlap. ioverlap does not require to be a simple factor of fftSize; for example a value of 160 would be legal. The choice of ioverlap may be dictated by the degree of pitch modification applied to the fsig, if any. As a rule of thumb, the more extreme the pitch shift, the higher the analysis rate needs to be, and hence the smaller the value for ioverlap. A higher analysis rate can also be advantageous with broadband transient sounds, such as drums (where a small analysis window gives less smearing, but more frequency-related errors).
/// @param tableReadOffset startup read offset into table, in seconds.
/// @param wraparoundFlag  0 or 1, to switch on/off table wrap-around read (default to 1)
/// @param onsetProcessingFlag 0 or 1, to switch onset detection/processing. The onset detector checks for power difference between analysis windows. If more than what has been specified in the dbthresh parameter, an onset is declared. It suspends timescaling momentarily so the onsets are not modified.
/// @param onsetDecibelThreshold Threshold for onset detection, based on dB power spectrum ratio between two successive windows. A detected ratio above it will cancel timescaling momentarily, to avoid smearing (defaults to 1). By default anything more than a 1 dB inter-frame power difference will be detected as an onset.
- (instancetype)initWithSoundFile:(AKFunctionTable *)soundFileSource
                       timeScaler:(AKControl *)timeScaler
                  amplitudeScaler:(AKControl *)amplitudeScaler
                      pitchScaler:(AKControl *)pitchScaler
                          fftSize:(AKConstant *)fftSize
                          overlap:(AKConstant *)overlap
                  tableReadOffset:(AKConstant *)tableReadOffset
            audioSourceWraparound:(AKControl *)wraparoundFlag
                  onsetProcessing:(AKControl *)onsetProcessingFlag
            onsetDecibelThreshold:(AKConstant *)onsetDecibelThreshold;

@end
