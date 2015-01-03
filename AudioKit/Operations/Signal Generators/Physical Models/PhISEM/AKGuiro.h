//
//  AKGuiro.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a guiro sound.

 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKGuiro : AKAudio
/// Instantiates the guiro with all values
/// @param count The number of beads/teeth/bells/timbrels/etc. [Default Value: 128]
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2500]
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 4000]
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. Updated at Control-rate. [Default Value: 1.0]
- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
                    amplitude:(AKParameter *)amplitude;

/// Instantiates the guiro with default values
- (instancetype)init;

/// Instantiates the guiro with default values
+ (instancetype)guiro;


/// The number of beads/teeth/bells/timbrels/etc. [Default Value: 128]
@property AKConstant *count;

/// Set an optional count
/// @param count The number of beads/teeth/bells/timbrels/etc. [Default Value: 128]
- (void)setOptionalCount:(AKConstant *)count;

/// The main resonant frequency. [Default Value: 2500]
@property AKConstant *mainResonantFrequency;

/// Set an optional main resonant frequency
/// @param mainResonantFrequency The main resonant frequency. [Default Value: 2500]
- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency;

/// The first resonant frequency. [Default Value: 4000]
@property AKConstant *firstResonantFrequency;

/// Set an optional first resonant frequency
/// @param firstResonantFrequency The first resonant frequency. [Default Value: 4000]
- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// Amplitude of output. Since these instruments are stochastic this is only an approximation. [Default Value: 1.0]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of output. Since these instruments are stochastic this is only an approximation. Updated at Control-rate. [Default Value: 1.0]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
