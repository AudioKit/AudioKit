//
//  OCSMarimba.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Physical model related to the striking of a wooden block.
 
 Audio output is a tone related to the striking of a wooden block as found in a marimba. The method is a physical model developed from Perry Cook but re-coded for Csound.
 */

@interface OCSMarimba : OCSAudio

/// Instantiates the marimba
/// @param hardnesss The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param position Where the block is hit, in the range 0 to 1.
/// @param decayTime Time before end of note when damping is introduced
/// @param strikeImpulseTable Table of the strike impulses. The file marmstk1.wav is a suitable function from measurements and can be loaded with a GEN01 table. It is also available at ftp://ftp.cs.bath.ac.uk/pub/dream/documentation/sounds/modelling/.
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function
/// @param frequency Frequency of note played.
/// @param amplitude Amplitude of note.
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12
/// @param vibratoAmplitude Amplitude of the vibrato
- (id)initWithHardnesss:(OCSConstant *)hardnesss
               position:(OCSConstant *)position
              decayTime:(OCSConstant *)decayTime
     strikeImpulseTable:(OCSConstant *)strikeImpulseTable
      vibratoShapeTable:(OCSConstant *)vibratoShapeTable
              frequency:(OCSControl *)frequency
              amplitude:(OCSControl *)amplitude
       vibratoFrequency:(OCSControl *)vibratoFrequency
       vibratoAmplitude:(OCSControl *)vibratoAmplitude;


/// Set an optional double strike percentage
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%.
- (void)setDoubleStrikePercentage:(OCSConstant *)doubleStrikePercentage;

/// Set an optional triple strike percentage
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%.
- (void)setTripleStrikePercentage:(OCSConstant *)tripleStrikePercentage;


@end