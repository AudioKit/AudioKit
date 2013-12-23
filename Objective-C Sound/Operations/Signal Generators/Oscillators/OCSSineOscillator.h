//
//  OCSSineOscillator.h
//  Objective-C Sound
//
//  Auto-generated from database on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A simple, fast sine oscillator
 
 Simple, fast sine oscillator, that uses only one multiply, and two add operations to generate one sample of output, and does not require a function table.
 */

@interface OCSSineOscillator : OCSAudio

/// Instantiates the sine oscillator
/// @param frequency comment
/// @param amplitude comment
- (instancetype)initWithFrequency:(OCSConstant *)frequency
                        amplitude:(OCSConstant *)amplitude;


/// Set an optional phase
/// @param phase comment
- (void)setOptionalPhase:(OCSConstant *)phase;


@end