//
//  AKVibes.h
//  AudioKit
//
//  Auto-generated on 3/2/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Physical model related to the striking of a metal block.

 Audio output is a tone related to the striking of a metal block as found in a vibraphone. The method is a physical model developed from Perry Cook, but re-coded for Csound.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKVibes : AKAudio
/// Instantiates the vibes with all values
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 440]
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1.0]
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. 0.5 is a suitable value. [Default Value: 0.5]
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0.2]
/// @param tremoloShape Shape of tremolo, usually a sine table, created by a function [Default Value: sine]
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
/// @param tremoloAmplitude Amplitude of the tremolo Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                    stickHardness:(AKConstant *)stickHardness
                   strikePosition:(AKConstant *)strikePosition
                     tremoloShape:(AKTable *)tremoloShape
                 tremoloFrequency:(AKParameter *)tremoloFrequency
                 tremoloAmplitude:(AKParameter *)tremoloAmplitude;

/// Instantiates the vibes with default values
- (instancetype)init;

/// Instantiates the vibes with default values
+ (instancetype)vibes;

/// Instantiates the vibes with default values
+ (instancetype)presetDefaultVibes;

/// Instantiates the vibes with a tiny, high-picthed sound
+ (instancetype)presetTinyVibes;

/// Instantiates the vibes with a tiny, high-picthed sound
- (instancetype)initWithPresetTinyVibes;

/// Instantiates the vibes with a small, gentle sound
- (instancetype)initWithPresetGentleVibes;

/// Instantiates the vibes with a small, gentle sound
+ (instancetype)presetGentleVibes;

/// Instantiates the vibes with a ringing sound
- (instancetype)initWithPresetRingingVibes;

/// Instantiates the vibes with a ringing sound
+ (instancetype)presetRingingVibes;


/// Frequency of note played. [Default Value: 440]
@property (nonatomic) AKParameter *frequency;

/// Set an optional frequency
/// @param frequency Frequency of note played. Updated at Control-rate. [Default Value: 440]
- (void)setOptionalFrequency:(AKParameter *)frequency;

/// Amplitude of note. [Default Value: 1.0]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of note. Updated at Control-rate. [Default Value: 1.0]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0.5]
@property (nonatomic) AKConstant *stickHardness;

/// Set an optional stick hardness
/// @param stickHardness The hardness of the stick used in the strike. A range of 0 to 1 is used. [Default Value: 0.5]
- (void)setOptionalStickHardness:(AKConstant *)stickHardness;

/// Where the block is hit, in the range 0 to 1. [Default Value: 0.2]
@property (nonatomic) AKConstant *strikePosition;

/// Set an optional strike position
/// @param strikePosition Where the block is hit, in the range 0 to 1. [Default Value: 0.2]
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition;

/// Shape of tremolo, usually a sine table, created by a function [Default Value: sine]
@property (nonatomic) AKTable *tremoloShape;

/// Set an optional tremolo shape
/// @param tremoloShape Shape of tremolo, usually a sine table, created by a function [Default Value: sine]
- (void)setOptionalTremoloShape:(AKTable *)tremoloShape;

/// Frequency of tremolo in Hertz. Suggested range is 0 to 12 [Default Value: 0]
@property (nonatomic) AKParameter *tremoloFrequency;

/// Set an optional tremolo frequency
/// @param tremoloFrequency Frequency of tremolo in Hertz. Suggested range is 0 to 12 Updated at Control-rate. [Default Value: 0]
- (void)setOptionalTremoloFrequency:(AKParameter *)tremoloFrequency;

/// Amplitude of the tremolo [Default Value: 0]
@property (nonatomic) AKParameter *tremoloAmplitude;

/// Set an optional tremolo amplitude
/// @param tremoloAmplitude Amplitude of the tremolo Updated at Control-rate. [Default Value: 0]
- (void)setOptionalTremoloAmplitude:(AKParameter *)tremoloAmplitude;



@end
NS_ASSUME_NONNULL_END
