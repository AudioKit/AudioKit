//
//  AKNoise.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A noise generator that can do white, pink, or brown noise.

 Implementation is a combination of white noise with IIR Filters.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKNoise : AKAudio
/// Instantiates the noise with all values
/// @param amplitude Amplitude of the output. [Default Value: 1]
/// @param pinkBalance Amount of pink noise to output from 0 to 1 (all pink) [Default Value: 0]
/// @param beta Beta of the low pass filter, in the range -1 to 1, exclusive of the end-points. Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithAmplitude:(AKParameter *)amplitude
                      pinkBalance:(AKParameter *)pinkBalance
                             beta:(AKParameter *)beta;

/// Instantiates the noise with default values
- (instancetype)init;

/// Instantiates the noise with default values
+ (instancetype)noise;


/// Amplitude of the output. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of the output. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// Amount of pink noise to output from 0 to 1 (all pink) [Default Value: 0]
@property (nonatomic) AKParameter *pinkBalance;

/// Set an optional pink balance
/// @param pinkBalance Amount of pink noise to output from 0 to 1 (all pink) [Default Value: 0]
- (void)setOptionalPinkBalance:(AKParameter *)pinkBalance;

/// Beta of the low pass filter, in the range -1 to 1, exclusive of the end-points. [Default Value: 0]
@property (nonatomic) AKParameter *beta;

/// Set an optional beta
/// @param beta Beta of the low pass filter, in the range -1 to 1, exclusive of the end-points. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalBeta:(AKParameter *)beta;



@end
NS_ASSUME_NONNULL_END
