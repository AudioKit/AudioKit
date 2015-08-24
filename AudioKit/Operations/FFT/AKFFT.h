//
//  AKFFT.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKFSignal.h"
#import "AKAudio.h"

/** Generate an f-Signal from a mono audio source using phase vocoder overlap-add synthesis.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFFT : AKFSignal

//Type Helpers

/// Hamming Window
+ (AKConstant *)hammingWindow;

/// Hann Window
+ (AKConstant *)hannWindow;

/// Create a phase vocoder stream or f-signal from a mono audio source.
/// @param input        Audio to use to generate the f-signal.
/// @param fftSize      The FFT size in samples. Need not be a power of two (though these are especially efficient), but must be even. Odd numbers are rounded up internally. fftSize determines the number of analysis bins in the output, as fftSize/2 + 1. For example, where fftSize = 1024, fsig will contain 513 analysis bins, ordered linearly from the fundamental to Nyquist. The fundamental of analysis (which in principle gives the lowest resolvable frequency) is determined as sample rate/fftSize. Thus, for the example just given and assuming sr = 44100, the fundamental of analysis is 43.07Hz. In practice, due to the phase-preserving nature of the phase vocoder, the frequency of any bin can deviate bilaterally, so that DC components are recorded. Given a strongly pitched signal, frequencies in adjacent bins can bunch very closely together, around partials in the source, and the lowest bins may even have negative frequencies.
/// @param overlap      The distance in samples (“hop size”) between overlapping analysis frames. As a rule, this needs to be at least fftSize/4, e.g. 256 for the example above.  overlap determines the underlying analysis rate, as sample rate/overlap. ioverlap does not require to be a simple factor of fftSize; for example a value of 160 would be legal. The choice of ioverlap may be dictated by the degree of pitch modification applied to the fsig, if any. As a rule of thumb, the more extreme the pitch shift, the higher the analysis rate needs to be, and hence the smaller the value for ioverlap. A higher analysis rate can also be advantageous with broadband transient sounds, such as drums (where a small analysis window gives less smearing, but more frequency-related errors).
/// @param windowType   Most users will find the Hamming window meets all normal needs, and can be regarded as the default choice.
/// @param windowSize   The size in samples of the analysis window filter (as set by windowType). This must be at least fftSize, and can usefully be larger. Though other proportions are permitted, it is recommended that iwinsize always be an integral multiple of fftSize, e.g. 2048 for the example above. Internally, the analysis window (Hamming, von Hann) is multiplied by a sinc function, so that amplitudes are zero at the boundaries between frames. The larger analysis window size has been found to be especially important for oscillator bank resynthesis (e.g. using pvsadsyn), as it has the effect of increasing the frequency resolution of the analysis, and hence the accuracy of the resynthesis. As noted above, windowSize determines the overall latency of the analysis/resynthesis system. In many cases, and especially in the absence of pitch modifications, it will be found that setting iwinsize=ifftsize works very well, and offers the lowest latency.
- (instancetype)initWithInput:(AKParameter *)input
                      fftSize:(AKConstant *)fftSize
                      overlap:(AKConstant *)overlap
                   windowType:(AKConstant *)windowType
             windowFilterSize:(AKConstant *)windowSize;

@end
NS_ASSUME_NONNULL_END
