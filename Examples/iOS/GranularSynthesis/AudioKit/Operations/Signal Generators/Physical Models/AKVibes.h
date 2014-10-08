//
//  AKVibes.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/3/12.
//  Improved from database version by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model related to the striking of a metal block.
 
 Audio output is a tone related to the striking of a metal block as found in a vibraphone. The method is a physical model developed from Perry Cook.
 */

@interface AKVibes : AKAudio

/// Instantiates the vibes
/// @param frequency Frequency of note played.
/// @param maximumDuration Time before end of note when damping is introduced
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param amplitude Amplitude of note.
/// @param tremoloShapeTable Shape of tremolo, usually a sine table, created by a function
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12
/// @param tremoloAmplitude Amplitude of the tremolo
- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                        amplitude:(AKControl *)amplitude
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKControl *)tremoloFrequency
                 tremoloAmplitude:(AKControl *)tremoloAmplitude;

@end