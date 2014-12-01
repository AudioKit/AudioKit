//
//  AKMarimba.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model related to the striking of a wooden block.

 Audio output is a tone related to the striking of a wooden block as found in a marimba. The method is a physical model developed from Perry Cook but re-coded for Csound.
 */

@interface AKMarimba : AKAudio

/// Instantiates the marimba with all values
/// @param frequency Frequency of note played.
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used.
/// @param strikePosition Where the block is hit, in the range 0 to 1.
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12
/// @param vibratoAmplitude Amplitude of the vibrato
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%.
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%.
- (instancetype)initWithFrequency:(AKControl *)frequency
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                vibratoShapeTable:(AKFTable *)vibratoShapeTable
                 vibratoFrequency:(AKControl *)vibratoFrequency
                 vibratoAmplitude:(AKControl *)vibratoAmplitude
           doubleStrikePercentage:(AKConstant *)doubleStrikePercentage
           tripleStrikePercentage:(AKConstant *)tripleStrikePercentage;

/// Instantiates the marimba with default values
- (instancetype)init;


/// Instantiates the marimba with default values
+ (instancetype)audio;




/// Frequency of note played. [Default Value: 220]
@property AKControl *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. [Default Value: 220]
- (void)setOptionalFrequency:(AKControl *)frequency;


/// The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0.5]
@property AKConstant *stickHardness;

/// Set an optional stick hardness
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0.5]
- (void)setOptionalStickHardness:(AKConstant *)stickHardness;


/// Where the block is hit, in the range 0 to 1. [Default Value: 0.5]
@property AKConstant *strikePosition;

/// Set an optional strike position
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0.5]
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition;


/// Shape of vibrato, usually a sine table, created by a function [Default Value: sine]
@property AKFTable *vibratoShapeTable;

/// Set an optional vibrato shape table
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function [Default Value: sine]
- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable;


/// Frequency of vibrato in Hertz. Suggested range is 0 to 12 [Default Value: 0]
@property AKControl *vibratoFrequency;

/// Set an optional vibrato frequency
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12 [Default Value: 0]
- (void)setOptionalVibratoFrequency:(AKControl *)vibratoFrequency;


/// Amplitude of the vibrato [Default Value: 0]
@property AKControl *vibratoAmplitude;

/// Set an optional vibrato amplitude
/// @param vibratoAmplitude Amplitude of the vibrato [Default Value: 0]
- (void)setOptionalVibratoAmplitude:(AKControl *)vibratoAmplitude;


/// Percentage of double strikes. Default is 40%. [Default Value: 40]
@property AKConstant *doubleStrikePercentage;

/// Set an optional double strike percentage
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%. [Default Value: 40]
- (void)setOptionalDoubleStrikePercentage:(AKConstant *)doubleStrikePercentage;


/// Percentage of triple strikes. Default is 20%. [Default Value: 20]
@property AKConstant *tripleStrikePercentage;

/// Set an optional triple strike percentage
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%. [Default Value: 20]
- (void)setOptionalTripleStrikePercentage:(AKConstant *)tripleStrikePercentage;


@end
