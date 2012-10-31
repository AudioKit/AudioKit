//
//  OCSVibes.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/31/12.
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
/// @param strikeImpulseTable Table of the strike impulses. The file marmstk1.wav is a suitable function from measurements and can be loaded with a GEN01 table. It is also available at ftp://ftp.cs.bath.ac.uk/pub/dream/documentation/sounds/modelling/.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param amplitude Amplitude of note.
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12
/// @param vibratoAmplitude Amplitude of the vibrato
- (id)initWithFrequency:(OCSControl *)frequency
        maximumDuration:(OCSConstant *)maximumDuration
          stickHardness:(OCSConstant *)stickHardness
     strikeImpulseTable:(OCSFTable *)strikeImpulseTable
         strikePosition:(OCSConstant *)strikePosition
              amplitude:(OCSControl *)amplitude
      vibratoShapeTable:(OCSFTable *)vibratoShapeTable
       vibratoFrequency:(OCSControl *)vibratoFrequency
       vibratoAmplitude:(OCSControl *)vibratoAmplitude;

@end