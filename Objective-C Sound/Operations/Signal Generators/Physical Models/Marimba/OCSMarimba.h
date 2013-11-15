//
//  OCSMarimba.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/31/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"
#import "OCSSoundFileTable.h"

/** Physical model related to the striking of a wooden block.
 
 Audio output is a tone related to the striking of a wooden block as found in a marimba. The method is a physical model developed from Perry Cook but re-coded for Csound.
 */

@interface OCSMarimba : OCSAudio

/// Instantiates the marimba
/// @param frequency Frequency of note played.
/// @param maximumDuration Time before end of note when damping is introduced
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param amplitude Amplitude of note.
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12
/// @param vibratoAmplitude Amplitude of the vibrato
- (instancetype)initWithFrequency:(OCSControl *)frequency
        maximumDuration:(OCSConstant *)maximumDuration
          stickHardness:(OCSConstant *)stickHardness
         strikePosition:(OCSConstant *)strikePosition
              amplitude:(OCSControl *)amplitude
      vibratoShapeTable:(OCSFTable *)vibratoShapeTable
       vibratoFrequency:(OCSControl *)vibratoFrequency
       vibratoAmplitude:(OCSControl *)vibratoAmplitude;


/// Set an optional double strike percentage
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%.
- (void)setOptionalDoubleStrikePercentage:(OCSConstant *)doubleStrikePercentage;

/// Set an optional triple strike percentage
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%.
- (void)setOptionalTripleStrikePercentage:(OCSConstant *)tripleStrikePercentage;

/// Set an optional custom strike impulse table
/// @param strikeImpulseTable Sound file table for the desired impulse response
- (void)setOptionalStrikeImpulseTable:(OCSSoundFileTable *)strikeImpulseTable;


@end