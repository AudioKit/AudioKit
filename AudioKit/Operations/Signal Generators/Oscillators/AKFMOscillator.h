//
//  AKFMOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/25/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Basic frequency modulated oscillator with linear interpolation.
 
 Classic FM Synthesis audio generation.
 */

@interface AKFMOscillator : AKAudio

/// Instantiates the fm oscillator with all values
/// @param fTable fTable, Function table to use.  Requires a wrap-around guard point.
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency.
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency.
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude.
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude.
/// @param phase Initial phase of waveform in fTable, expressed as a fraction of a cycle (0 to 1).
- (instancetype)initWithFTable:(AKFTable *)fTable
                 baseFrequency:(AKControl *)baseFrequency
             carrierMultiplier:(AKParameter *)carrierMultiplier
          modulatingMultiplier:(AKParameter *)modulatingMultiplier
               modulationIndex:(AKControl *)modulationIndex
                     amplitude:(AKParameter *)amplitude
                         phase:(AKConstant *)phase;

/// Instantiates the fm oscillator with default values
/// @param fTable fTable, Function table to use.  Requires a wrap-around guard point.
- (instancetype)initWithFTable:(AKFTable *)fTable;

/// Instantiates the fm oscillator with default values
/// @param fTable fTable, Function table to use.  Requires a wrap-around guard point.
+ (instancetype)audioWithFTable:(AKFTable *)fTable;




/// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. [Default Value: 440]
@property AKControl *baseFrequency;

/// Set an optional base frequency
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. [Default Value: 440]
- (void)setOptionalBaseFrequency:(AKControl *)baseFrequency;


/// This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
@property AKParameter *carrierMultiplier;

/// Set an optional carrier multiplier
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier;


/// This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
@property AKParameter *modulatingMultiplier;

/// Set an optional modulating multiplier
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier;


/// This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 1]
@property AKControl *modulationIndex;

/// Set an optional modulation index
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 1]
- (void)setOptionalModulationIndex:(AKControl *)modulationIndex;


/// This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;


/// Initial phase of waveform in fTable, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase Initial phase of waveform in fTable, expressed as a fraction of a cycle (0 to 1). [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;


@end
