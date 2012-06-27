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
 
 @warning *Not fully implemented yet:* Currently it is only mono and no 
 optional parameters are implemented.
 
 @warning *Csound Manual:* This is the manual entry for loscil3
 
 ifn -- function table number, typically denoting an sampled sound segment with prescribed looping points loaded using GEN01. The source file may be mono or stereo.
 
 ibas (optional) -- base frequency in Hz of the recorded sound. This optionally overrides the frequency given in the audio file, but is required if the file did not contain one. The default value is 261.626 Hz, i.e. middle C. (New in Csound 4.03). If this value is not known or not present, use 1 here and in kcps.
 
 imod1, imod2 (optional, default=-1) -- play modes for the sustain and release loops. A value of 1 denotes normal looping, 2 denotes forward & backward looping, 0 denotes no looping. The default value (-1) will defer to the mode and the looping points given in the source file. Make sure you select an appropriate mode if the file does not contain this information.
 
 ibeg1, iend1, ibeg2, iend2 (optional, dependent on mod1, mod2) -- begin and end points of the sustain and release loops. These are measured in sample frames from the beginning of the file, so will look the same whether the sound segment is monaural or stereo. If no loop points are specified, and a looping mode (imod1, imod2) is given, the file will be looped for the whole length.
 
 Performance
 
 ar1, ar2 -- the output at audio-rate. There is just ar1 for mono output. However, there is both ar1 and ar2 for stereo output.
 
 xamp -- the amplitude of the output signal.
 
 kcps -- the frequency of the output signal in cycles per second.
 
 */
// TODO: Add optional params
//ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]

@interface OCSLoopingOscillator : OCSOpcode

///
@property (nonatomic, strong) OCSParam *output1;
@property (nonatomic, strong) OCSParam *output2;

/// Simplest initialization with a given file.
/// @param fileTable Function table of type OCSSoundFileTable.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable;

/// Initialization with a given file and amplitude
/// @param fileTable Function table of type OCSSoundFileTable.
/// @param amplitude Output of the signal in relation to the 0dB full scale amplitude.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
                   Amplitude:(OCSParam *)amplitude;

/// Initialization with a given file and amplitude and scale the frequency.
/// @param fileTable           Function table of type OCSSoundFileTable.
/// @param amplitude           Output of the signal in relation to the 0dB full scale amplitude.
/// @param frequencyMultiplier Relative to a base frequency of 1.
- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
                   Amplitude:(OCSParam *)amplitude
         FrequencyMultiplier:(OCSParamControl *)frequencyMultiplier;
@end
