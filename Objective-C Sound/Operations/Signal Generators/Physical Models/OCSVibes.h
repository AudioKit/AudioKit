//
//  OCSVibes.h
//  Objective-C Sound
//
//  Auto-generated from database on 11/3/12.
//  Improved from database version by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Physical model related to the striking of a metal block.
 
 Audio output is a tone related to the striking of a metal block as found in a vibraphone. The method is a physical model developed from Perry Cook, but re-coded for Csound.
 */

@interface OCSVibes : OCSAudio

/// Instantiates the vibes
/// @param frequency Frequency of note played.
/// @param maximumDuration Time before end of note when damping is introduced
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param amplitude Amplitude of note.
/// @param tremoloShapeTable Shape of tremolo, usually a sine table, created by a function
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12
/// @param tremoloAmplitude Amplitude of the tremolo
- (instancetype)initWithFrequency:(OCSControl *)frequency
                  maximumDuration:(OCSConstant *)maximumDuration
                    stickHardness:(OCSConstant *)stickHardness
                   strikePosition:(OCSConstant *)strikePosition
                        amplitude:(OCSControl *)amplitude
                tremoloShapeTable:(OCSFTable *)tremoloShapeTable
                 tremoloFrequency:(OCSControl *)tremoloFrequency
                 tremoloAmplitude:(OCSControl *)tremoloAmplitude;

@end