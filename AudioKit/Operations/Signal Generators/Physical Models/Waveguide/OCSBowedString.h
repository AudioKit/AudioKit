//
//  OCSBowedString.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Creates a tone similar to a bowed string.
 
 Audio output is a tone similar to a bowed string, using a physical model developed from Perry Cook, but recoded for Csound.
 */

@interface OCSBowedString : OCSAudio

/// Instantiates the bowed string
/// @param frequency Frequency of the note played, note that this will be lowest allowable frequency unless the optional minimum frequency is set.
/// @param pressure Parameter controlling the pressure of the bow on the string. Values should be about 3. The useful range is approximately 1 to 5.
/// @param position Position of the bow along the string. Usual playing is about 0.127236. The suggested range is 0.025 to 0.23.
/// @param amplitude Amplitude of the note played.
/// @param vibratoShapeTable Table shape of vibrato, usually a sine table.
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12.
/// @param vibratoAmplitude Amplitude of the vibrato.
- (instancetype)initWithFrequency:(OCSControl *)frequency
                         pressure:(OCSControl *)pressure
                         position:(OCSControl *)position
                        amplitude:(OCSControl *)amplitude
                vibratoShapeTable:(OCSFTable *)vibratoShapeTable
                 vibratoFrequency:(OCSControl *)vibratoFrequency
                 vibratoAmplitude:(OCSControl *)vibratoAmplitude;


/// Set an optional minimum frequency
/// @param minimumFrequency Lowest frequency at which the instrument will play.
- (void)setOptionalMinimumFrequency:(OCSConstant *)minimumFrequency;


@end