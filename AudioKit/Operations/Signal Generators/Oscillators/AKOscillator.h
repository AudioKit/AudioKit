//
//  AKOscillator.h
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple oscillator with linear interpolation.

 Reads from the waveform sequentially and repeatedly at given frequency. Linear interpolation is applied for table look up from internal phase values.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKOscillator : AKAudio
/// Instantiates the oscillator with all values
/// @param waveform Requires a wrap-around guard point [Default Value: sine]
/// @param frequency Frequency in cycles per second [Default Value: 440]
/// @param amplitude Amplitude of the output [Default Value: 1]
- (instancetype)initWithWaveform:(AKTable *)waveform
                       frequency:(AKParameter *)frequency
                       amplitude:(AKParameter *)amplitude;

/// Instantiates the oscillator with default values
- (instancetype)init;

/// Instantiates the oscillator with default values
+ (instancetype)oscillator;


/// Requires a wrap-around guard point [Default Value: sine]
@property (nonatomic) AKTable *waveform;

/// Set an optional waveform
/// @param waveform Requires a wrap-around guard point [Default Value: sine]
- (void)setOptionalWaveform:(AKTable *)waveform;

/// Frequency in cycles per second [Default Value: 440]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of the output [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the output [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
