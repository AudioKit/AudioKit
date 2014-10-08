//
//  AKLoopingStereoOscillator.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"
#import "AKSoundFileTable.h"

#import "AKLoopingOscillatorConstants.h"

/** Read sampled stereo sound from a table, with
 optional sustain and release looping, using cubic interpolation.
 
 @warning *Not fully implemented yet:* Currently no
 optional parameters are implemented.
 */

@interface AKLoopingStereoOscillator : AKStereoAudio

/// Simplest initialization with a given file.
/// @param fileTable Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable;

/// Initialization with a given file and amplitude
/// @param fileTable Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param amplitude Output of the signal in relation to the 0dB full scale amplitude.
- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable
                             amplitude:(AKParameter *)amplitude;

/// Initialization with a given file and amplitude and scale the frequency.
/// @param fileTable           Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param amplitude           Output of the signal in relation to the 0dB full scale amplitude.
/// @param frequencyMultiplier Relative to a base frequency of 1.
- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable
                   frequencyMultiplier:(AKControl *)frequencyMultiplier
                             amplitude:(AKParameter *)amplitude;

/// Initialization with a given file and amplitude and scale the frequency.
/// @param fileTable           Typically sampled sound segment with prescribed looping points. The source file may be mono or stereo.
/// @param frequencyMultiplier Relative to a base frequency of 1.
/// @param amplitude           Output of the signal in relation to the 0dB full scale amplitude.
/// @param type                Behavior of the loop, no loop, normal, or forward and back
- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable
                   frequencyMultiplier:(AKControl *)frequencyMultiplier
                             amplitude:(AKParameter *)amplitude
                                  type:(LoopingOscillatorType)type;

/// Set start and finish loop points
/// @param startingSample        Starting point of loop segment in samples.
/// @param endingSample          Endpoing of loop in samples.
/// @param releaseStartingSample Release loop startpoint in samples.
/// @param releaseEndingSample   Release loop endpoing in samples.
-(void)setLoopPointStart:(int)startingSample
                     end:(int)endingSample
            releaseStart:(int)releaseStartingSample
              releaseEnd:(int)releaseEndingSample;

@end
