//
//  AKSineOscillator.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A simple, fast sine oscillator
 
 Simple, fast sine oscillator, that uses only one multiply, and two add operations to generate one sample of output, and does not require a function table.
 */

@interface AKSineOscillator : AKAudio

/// Instantiates the sine oscillator
/// @param frequency comment
/// @param amplitude comment
- (instancetype)initWithFrequency:(AKConstant *)frequency
                        amplitude:(AKConstant *)amplitude;


/// Set an optional phase
/// @param phase comment
- (void)setOptionalPhase:(AKConstant *)phase;


@end