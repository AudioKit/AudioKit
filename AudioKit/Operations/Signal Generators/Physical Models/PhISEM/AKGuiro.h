//
//  AKGuiro.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/27/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Semi-physical model of a guiro sound.
 
 This is one of the PhISEM percussion opcodes. PhISEM (Physically Informed Stochastic Event Modeling) is an algorithmic approach for simulating collisions of multiple independent sound producing objects.
 */

@interface AKGuiro : AKAudio

/// Instantiates the guiro with all values
/// @param count The number of beads/teeth/bells/timbrels/etc.
/// @param mainResonantFrequency The main resonant frequency.
/// @param firstResonantFrequency The first resonant frequency.
- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency;

/// Instantiates the guiro with default values
- (instancetype)init;


/// Instantiates the guiro with default values
+ (instancetype)audio;




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


@end
