//
//  AKVibes.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model related to the striking of a metal block.

 Audio output is a tone related to the striking of a metal block as found in a vibraphone. The method is a physical model developed from Perry Cook, but re-coded for Csound.
 */

@interface AKVibes : AKAudio

/// Instantiates the vibes with all values
/// @param frequency Frequency of note played.
/// @param maximumDuration Time before end of note when damping is introduced
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param tremoloShapeTable Shape of tremolo, usually a sine table, created by a function
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12
/// @param tremoloAmplitude Amplitude of the tremolo
- (instancetype)initWithFrequency:(AKControl *)frequency
                  maximumDuration:(AKConstant *)maximumDuration
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                tremoloShapeTable:(AKFTable *)tremoloShapeTable
                 tremoloFrequency:(AKControl *)tremoloFrequency
                 tremoloAmplitude:(AKControl *)tremoloAmplitude;

/// Instantiates the vibes with default values
- (instancetype)init;


/// Instantiates the vibes with default values
+ (instancetype)audio;




/// Frequency of note played. [Default Value: 440]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. [Default Value: 440]
- (void)setOptionalFrequency:(AKControl *)frequency;


/// Time before end of note when damping is introduced [Default Value: 0.5]
@property AKConstant *maximumDuration;

/// Set an optional maximum duration
/// @param maximumDuration Time before end of note when damping is introduced [Default Value: 0.5]
- (void)setOptionalMaximumDuration:(AKConstant *)maximumDuration;


/// The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value. [Default Value: 0.5]
@property AKConstant *stickHardness;

/// Set an optional stick hardness
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value. [Default Value: 0.5]
- (void)setOptionalStickHardness:(AKConstant *)stickHardness;


/// Where the block is hit, in the range 0 to 1. [Default Value: 0]
@property AKConstant *strikePosition;

/// Set an optional strike position
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0]
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition;


/// Shape of tremolo, usually a sine table, created by a function [Default Value: sine]
@property AKFTable *tremoloShapeTable;

/// Set an optional tremolo shape table
/// @param tremoloShapeTable Shape of tremolo, usually a sine table, created by a function [Default Value: sine]
- (void)setOptionalTremoloShapeTable:(AKFTable *)tremoloShapeTable;


/// Frequency of tremolo in Hertz. Suggested range is 0 to 12 [Default Value: 6]
@property AKControl *tremoloFrequency;

/// Set an optional tremolo frequency
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12 [Default Value: 6]
- (void)setOptionalTremoloFrequency:(AKControl *)tremoloFrequency;


/// Amplitude of the tremolo [Default Value: 0]
@property AKControl *tremoloAmplitude;

/// Set an optional tremolo amplitude
/// @param tremoloAmplitude Amplitude of the tremolo [Default Value: 0]
- (void)setOptionalTremoloAmplitude:(AKControl *)tremoloAmplitude;


@end
