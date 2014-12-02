//
//  AKSineOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple, fast sine oscillator

 Simple, fast sine oscillator, that uses only one multiply, and two add operations to generate one sample of output, and does not require a function table.
 */

@interface AKSineOscillator : AKAudio

/// Instantiates the sine oscillator with all values
/// @param frequency Frequency in cycles per second.
/// @param phase comment
- (instancetype)initWithFrequency:(AKConstant *)frequency
                            phase:(AKConstant *)phase;

/// Instantiates the sine oscillator with default values
- (instancetype)init;


/// Instantiates the sine oscillator with default values
+ (instancetype)audio;




/// Frequency in cycles per second. [Default Value: 440]
@property AKConstant *frequency;

/// Set an optional frequency
/// @param frequency Frequency in cycles per second. [Default Value: 440]
- (void)setOptionalFrequency:(AKConstant *)frequency;


/// comment [Default Value: 0]
@property AKConstant *phase;

/// Set an optional phase
/// @param phase comment [Default Value: 0]
- (void)setOptionalPhase:(AKConstant *)phase;


@end
