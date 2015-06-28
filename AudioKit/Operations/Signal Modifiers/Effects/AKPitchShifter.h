//
//  AKPitchShifter.h
//  AudioKit
//
//  Auto-generated on 6/26/15.
//  Customized by Aurelius Prochazka on 6/26/15 to add type helpers.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Shifts the pitch of a signal by a given pitch scaling ratio.

 
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKPitchShifter : AKAudio

//Type Helpers

/// No Formant Retain Method
+ (AKConstant *)noFormantRetainMethod;

/// Liftered Cepstrum Formant Retain Method
+ (AKConstant *)lifteredCepstrumFormantRetainMethod;

/// True Envelope Formant Retain Method
+ (AKConstant *)trueEnvelopeFormantRetainMethod;


/// Instantiates the pitch shifter with all values
/// @param input Input signal, usually audio. [Default Value: ]
/// @param frequencyRatio The frequency scaling ratio, 0.5 for an octave down, 2.0 for an octave up. Updated at Control-rate. [Default Value: 1]
/// @param formantRetainMethod Whether to retain formants or not, and which method to use.  Default none. Updated at Control-rate. [Default Value: 0]
/// @param fftSize  The FFT size in samples. Need not be a power of two (though these are especially efficient), but must be even. [Default Value: 1024]
- (instancetype)initWithInput:(AKParameter *)input
               frequencyRatio:(AKParameter *)frequencyRatio
          formantRetainMethod:(AKConstant *)formantRetainMethod
                      fftSize:(AKConstant *)fftSize;

/// Instantiates the pitch shifter with default values
/// @param input Input signal, usually audio.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the pitch shifter with default values
/// @param input Input signal, usually audio.
+ (instancetype)pitchShifterWithInput:(AKParameter *)input;

/// The frequency scaling ratio, 0.5 for an octave down, 2.0 for an octave up. [Default Value: 1]
@property (nonatomic) AKParameter *frequencyRatio;

/// Set an optional frequency ratio
/// @param frequencyRatio The frequency scaling ratio, 0.5 for an octave down, 2.0 for an octave up. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalFrequencyRatio:(AKParameter *)frequencyRatio;

/// Whether to retain formants or not, and which method to use.  Default none. [Default Value: 0]
@property (nonatomic) AKParameter *formantRetainMethod;

/// Set an optional formant retain method
/// @param formantRetainMethod Whether to retain formants or not, and which method to use.  Default none. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFormantRetainMethod:(AKConstant *)formantRetainMethod;

///  The FFT size in samples. Need not be a power of two (though these are especially efficient), but must be even. [Default Value: 1024]
@property (nonatomic) AKConstant *fftSize;

/// Set an optional fft size
/// @param fftSize  The FFT size in samples. Need not be a power of two (though these are especially efficient), but must be even. [Default Value: 1024]
- (void)setOptionalFftSize:(AKConstant *)fftSize;



@end
NS_ASSUME_NONNULL_END

