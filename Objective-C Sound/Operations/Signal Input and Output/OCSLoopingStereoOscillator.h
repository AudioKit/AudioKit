//
//  OCSLoopingStereoOscillator.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"
#import "OCSParameter+Operation.h"
#import "OCSSoundFileTable.h"

/** Read sampled stereo sound from a table, with
 optional sustain and release looping, using cubic interpolation.
 
 @warning *Not fully implemented yet:* Currently no
 optional parameters are implemented.
 */

@interface OCSLoopingStereoOscillator : OCSStereoAudio

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

typedef enum {
    kLoopingOscillatorNoLoop=0,
    kLoopingOscillatorNormal=1,
    kLoopingOscillatorForwardAndBack=2
} LoopingOscillatorType;

/// Initialization with a given file and amplitude and scale the frequency.
/// @param fileTable           Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param frequencyMultiplier Relative to a base frequency of 1.
/// @param amplitude           Output of the signal in relation to the 0dB full scale amplitude.
/// @param type                Behavior of the loop, no loop, normal, or forward and back
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude
                        type:(LoopingOscillatorType)type;

/// Set start and finish loop points
/// @param startingSample       starting point of loop segment in samples.
/// @param endingSample         endpoing of loop in samples.
/// @param releaseStart         release loop startpoint in samples.
/// @param releaseEnd         release loop endpoing in samples.
-(void)setLoopPointStart:(int)startingSample end:(int)endingSample releaseStart:(int)releaseStart releaseEnd:(int)releaseEndingSample;

@end
