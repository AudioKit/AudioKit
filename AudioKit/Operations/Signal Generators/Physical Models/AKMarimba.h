//
//  AKMarimba.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model related to the striking of a wooden block.

 Audio output is a tone related to the striking of a wooden block as found in a marimba. The method is a physical model developed from Perry Cook but re-coded for Csound.
 */

@interface AKMarimba : AKAudio
/// Instantiates the marimba with all values
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 220]
/// @param amplitude Amplitude of note. [Default Value: 1]
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0]
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0.5]
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function [Default Value: sine]
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
/// @param vibratoAmplitude Amplitude of the vibrato Updated at Control-rate. [Default Value: 0]
/// @param doubleStrikePercentage Percentage of double strikes. Default is 40%. [Default Value: 40]
/// @param tripleStrikePercentage Percentage of triple strikes. Default is 20%. [Default Value: 20]
- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKConstant *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                vibratoShapeTable:(AKFunctionTable *)vibratoShapeTable
                 vibratoFrequency:(AKParameter *)vibratoFrequency
                 vibratoAmplitude:(AKParameter *)vibratoAmplitude
           doubleStrikePercentage:(AKConstant *)doubleStrikePercentage
           tripleStrikePercentage:(AKConstant *)tripleStrikePercentage;

/// Instantiates the marimba with default values
- (instancetype)init;

/// Instantiates the marimba with default values
+ (instancetype)marimba;


/// Frequency of note played. [Default Value: 220]
@property AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 220]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of note. [Default Value: 1]
@property AKConstant *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of note. [Default Value: 1]
- (void)setOptionalAmplitude:(AKConstant *)amplitude;

/// The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0]
@property AKConstant *stickHardness;

/// Set an optional stick hardness
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0]
- (void)setOptionalStickHardness:(AKConstant *)stickHardness;

/// Where the block is hit, in the range 0 to 1. [Default Value: 0.5]
@property AKConstant *strikePosition;

/// Set an optional strike position
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0.5]
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition;

/// Shape of vibrato, usually a sine table, created by a function [Default Value: sine]
@property AKFunctionTable *vibratoShapeTable;

/// Set an optional vibrato shape table
/// @param vibratoShapeTable Shape of vibrato, usually a sine table, created by a function [Default Value: sine]
- (void)setOptionalVibratoShapeTable:(AKFunctionTable *)vibratoShapeTable;

/// Frequency of vibrato in Hertz. Suggested range is 0 to 12 [Default Value: 0]
@property AKParameter *vibratoFrequency;

/// Set an optional vibrato frequency
/// @param vibratoFrequency Frequency of vibrato in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoFrequency:(AKParameter *)vibratoFrequency;

/// Amplitude of the vibrato [Default Value: 0]
@property AKParameter *vibratoAmplitude;

/// Set an optional vibrato amplitude
/// @param vibratoAmplitude Amplitude of the vibrato Updated at Control-rate. [Default Value: 0]
- (void)setOptionalVibratoAmplitude:(AKParameter *)vibratoAmplitude;

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
