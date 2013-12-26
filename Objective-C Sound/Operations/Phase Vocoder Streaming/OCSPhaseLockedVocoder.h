//
//  OCSPhaseLockedVocoder.h
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Phase-locked vocoder processing.
 
 More detailed description from http://www.csounds.com/manual/html/
 */

@interface OCSPhaseLockedVocoder : OCSAudio

/// Instantiates the phase locked vocoder
/// @param sourceFTable Source signal function table. Only mono audio files work.
/// @param time Time position of current audio sample in secs. Table reading wraps around the ends of the function table.
/// @param scaledPitch Grain pitch scaling (1=normal pitch, < 1 lower, > 1 higher; negative, backwards)
/// @param amplitude Amplitude scaling
- (id)initWithSourceFTable:(OCSControl *)sourceFTable
                      time:(OCSAudio *)time
               scaledPitch:(OCSControl *)scaledPitch
                 amplitude:(OCSControl *)amplitude;


/// Set an optional size of fft
/// @param sizeOfFFT FFT size (power-of-two), defaults to 2048.
- (void)setOptionalSizeOfFFT:(OCSConstant *)sizeOfFFT;

/// Set an optional decimation
/// @param decimation Defaults to 4 (meaning hopsize = fftsize/4)
- (void)setOptionalDecimation:(OCSConstant *)decimation;


@end