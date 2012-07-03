//
//  OCSLoopingOscillator.h
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSSoundFileTable.h"

/** Read sampled sound (mono or stereo) from a table, with 
 optional sustain and release looping, using cubic interpolation.
 
 @warning *Not fully implemented yet:* Currently no 
 optional parameters are implemented.
 */
// TODO: Add optional params

@interface OCSLoopingOscillator : OCSOpcode

/// This is the output for a mono sound file table input.
@property (nonatomic, strong) OCSParameter *output;
/// This is the output to the left channel if stereo.
@property (nonatomic, strong) OCSParameter *leftOutput;
/// This is the output to the right channel if stereo.
@property (nonatomic, strong) OCSParameter *rightOutput;

/// Simplest initialization with a given file.
/// @param fileTable Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable;

/// Initialization with a given file and amplitude
/// @param fileTable Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param amplitude Output of the signal in relation to the 0dB full scale amplitude.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
                   amplitude:(OCSParameter *)amplitude;

/// Initialization with a given file and amplitude and scale the frequency.
/// @param fileTable           Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param amplitude           Output of the signal in relation to the 0dB full scale amplitude.
/// @param frequencyMultiplier Relative to a base frequency of 1.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude;
@end
