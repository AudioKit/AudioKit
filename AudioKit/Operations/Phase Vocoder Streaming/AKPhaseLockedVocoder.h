//
//  AKPhaseLockedVocoder.h
//  AudioKit
//
//  Auto-generated on 12/25/13.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Phase-locked vocoder processing.
 
 More detailed description from http://www.csounds.com/manual/html/mincer.html
 */

@interface AKPhaseLockedVocoder : AKAudio

/// Instantiates the phase locked vocoder
/// @param functionTable Source signal function table. Only mono audio files work.
/// @param time Time position of current audio sample in secs. Table reading wraps around the ends of the function table.
/// @param scaledPitch Grain pitch scaling (1=normal pitch, < 1 lower, > 1 higher; negative, backwards)
/// @param amplitude Amplitude scaling
- (instancetype)initWithFunctionTable:(AKControl *)functionTable
                                 time:(AKAudio *)time
                          scaledPitch:(AKControl *)scaledPitch
                            amplitude:(AKControl *)amplitude;


/// Set an optional size of fft
/// @param sizeOfFFT FFT size (power-of-two), defaults to 2048.
- (void)setOptionalSizeOfFFT:(AKConstant *)sizeOfFFT;

/// Set an optional decimation
/// @param decimation Defaults to 4 (meaning hopsize = fftsize/4)
- (void)setOptionalDecimation:(AKConstant *)decimation;


@end