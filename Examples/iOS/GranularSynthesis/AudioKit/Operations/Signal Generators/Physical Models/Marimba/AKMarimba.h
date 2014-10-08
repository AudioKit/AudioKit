//
//  AKMarimba.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"
#import "AKSoundFileTable.h"

/** Physical model related to the striking of a wooden block.
 
 Audio output is a tone related to the striking of a wooden block as found in a marimba. The method is a physical model developed from Perry Cook.
 */

@interface AKMarimba : AKAudio

/// Instantiates the marimba
/// @param frequency Frequency of note played.
/// @param maximumDuration Time before end of note when damping is introduced
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param amplitude Amplitude of note.
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12
/// @param vibratoAmplitude Amplitude of the vibrato
- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                        amplitude:(AKControl *)amplitude
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKControl *)vibratoFrequency
                 vibratoAmplitude:(AKControl *)vibratoAmplitude;


/// Set an optional double strike percentage
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%.
- (void)setOptionalDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage;

/// Set an optional triple strike percentage
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%.
- (void)setOptionalTripleStrikePercentage:(AKConstant *)tripleStrikePercentage;

/// Set an optional custom strike impulse table
/// @param strikeImpulseTable Sound file table for the desired impulse response
- (void)setOptionalStrikeImpulseTable:(AKSoundFileTable *)strikeImpulseTable;


@end