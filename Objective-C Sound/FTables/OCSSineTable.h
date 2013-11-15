//
//  OCSSineTable.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFTable.h"

/// Generates composite waveforms made up of weighted sums of simple sinusoids.
@interface OCSSineTable : OCSFTable

/// Creates a pure sine table with a default size of 4096.
- (instancetype)init;

/// Creates a sine table with an array of partial strengths
/// @param tableSize             Number of points in the table. Must be a power of 2 or power-of-2 plus 1.
/// @param partialStrengthsArray Relative strengths of the fixed harmonic partial numbers 1,2,3, etc. Partials not required should be given a strength of zero.
- (instancetype)initWithSize:(int)tableSize 
  partialStrengths:(OCSArray *)partialStrengthsArray;



@end
