//
//  AKFMOscillator.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Basic frequency modulated oscillator with linear interpolation.

 Classic FM Synthesis audio generation.
 */

@interface AKFMOscillator : AKAudio
/// Instantiates the fm oscillator with all values
/// @param functionTable Function table to use.  Requires a wrap-around guard point. [Default Value: sine]
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                        baseFrequency:(AKParameter *)baseFrequency
                    carrierMultiplier:(AKParameter *)carrierMultiplier
                 modulatingMultiplier:(AKParameter *)modulatingMultiplier
                      modulationIndex:(AKParameter *)modulationIndex
                            amplitude:(AKParameter *)amplitude;

/// Instantiates the fm oscillator with default values
- (instancetype)init;

/// Instantiates the fm oscillator with default values
+ (instancetype)oscillator;


/// Function table to use.  Requires a wrap-around guard point. [Default Value: sine]
@property AKFunctionTable *functionTable;

/// Set an optional function table
/// @param functionTable Function table to use.  Requires a wrap-around guard point. [Default Value: sine]
- (void)setOptionalFunctionTable:(AKFunctionTable *)functionTable;

/// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. [Default Value: 440]
@property AKParameter *baseFrequency;

/// Set an optional base frequency
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
- (void)setOptionalBaseFrequency:(AKParameter *)baseFrequency;

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
@property AKParameter *modulationIndex;

/// Set an optional modulation index
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalModulationIndex:(AKParameter *)modulationIndex;

/// This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
