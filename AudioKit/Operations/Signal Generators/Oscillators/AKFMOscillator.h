//
//  AKFMOscillator.h
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Basic frequency modulated oscillator with linear interpolation.

 Classic FM Synthesis audio generation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFMOscillator : AKAudio
/// Instantiates the fm oscillator with all values
/// @param waveform Waveform table to use.  Requires a wrap-around guard point. [Default Value: sine]
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
- (instancetype)initWithWaveform:(AKTable *)waveform
                   baseFrequency:(AKParameter *)baseFrequency
               carrierMultiplier:(AKParameter *)carrierMultiplier
            modulatingMultiplier:(AKParameter *)modulatingMultiplier
                 modulationIndex:(AKParameter *)modulationIndex
                       amplitude:(AKParameter *)amplitude;

/// Instantiates the fm oscillator with default values
- (instancetype)init;

/// Instantiates the fm oscillator with default values
+ (instancetype)oscillator;

/// Instantiates the oscillator with default values
+ (instancetype)presetDefaultOscillator;

/// Instantiates the oscillator with 'stun-ray' type values
- (instancetype)initWithPresetStunRay;

/// Instantiates the oscillator with 'stun-ray' type values
+ (instancetype)presetStunRay;

/// Instantiates the oscillator with 'wobble' type values
- (instancetype)initWithPresetWobble;

/// Instantiates the oscillator with 'wobble' type values
+ (instancetype)presetWobble;

/// Instantiates the oscillator with 'space-wobble' type values
- (instancetype)initWithPresetSpaceWobble;

/// Instantiates the oscillator with 'space-wobble' type values
+ (instancetype)presetSpaceWobble;

/// Instantiates the oscillator with 'foghorn' type values
- (instancetype)initWithPresetFogHorn;

/// Instantiates the oscillator with 'foghorn' type values
+ (instancetype)presetFogHorn;

/// Instantiates the oscillator with 'buzzer' type values
- (instancetype)initWithPresetBuzzer;

/// Instantiates the oscillator with 'buzzer' type values
+ (instancetype)presetBuzzer;

/// Instantiates the oscillator with 'spiral' type values
- (instancetype)initWithPresetSpiral;

/// Instantiates the oscillator with 'spiral' type values
+ (instancetype)presetSpiral;


/// Waveform table to use.  Requires a wrap-around guard point. [Default Value: sine]
@property (nonatomic) AKTable *waveform;

/// Set an optional waveform
/// @param waveform Waveform table to use.  Requires a wrap-around guard point. [Default Value: sine]
- (void)setOptionalWaveform:(AKTable *)waveform;

/// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. [Default Value: 440]
@property (nonatomic) AKParameter *baseFrequency;

/// Set an optional base frequency
/// @param baseFrequency In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies. Updated at Control-rate. [Default Value: 440]
- (void)setOptionalBaseFrequency:(AKParameter *)baseFrequency;

/// This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
@property (nonatomic) AKParameter *carrierMultiplier;

/// Set an optional carrier multiplier
/// @param carrierMultiplier This multiplied by the baseFrequency gives the carrier frequency. [Default Value: 1]
- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier;

/// This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
@property (nonatomic) AKParameter *modulatingMultiplier;

/// Set an optional modulating multiplier
/// @param modulatingMultiplier This multiplied by the baseFrequency gives the modulating frequency. [Default Value: 1]
- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier;

/// This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 1]
@property (nonatomic) AKParameter *modulationIndex;

/// Set an optional modulation index
/// @param modulationIndex This multiplied by the modulating frequency gives the modulation amplitude. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalModulationIndex:(AKParameter *)modulationIndex;

/// This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude This multiplied by the modulating frequency gives the modulation amplitude. [Default Value: 0.5]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
NS_ASSUME_NONNULL_END
