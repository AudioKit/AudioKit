//
//  AKTableLooper.h
//  AudioKit
//
//  Auto-generated on 3/3/15.
//  Customized by Aurelius Prochazka to include types as class methods
//
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Function-table-based crossfading looper.

 This opcode implements a crossfading looper with variable loop parameters and three looping modes. It accepts non-power-of-two tables for its source sounds, such as AKSoundFile Tables.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKTableLooper : AKAudio

//Type Helpers

/// Loop plays foward and repeats from the beginning forever
+ (AKConstant *)loopRepeats;

/// Loop plays backwards repeating from the end when it gets back to the start
+ (AKConstant *)loopPlaysBackwards;

/// Loop first plays forward and then when it reaches the end it plays backwards and then repeats
+ (AKConstant *)loopPlaysForwardAndThenBackwards;

/// Instantiates the table looper with all values
/// @param table Sound source table, generally an AKSoundFile. 
/// @param startTime Loop start point in seconds. Updated at Control-rate. [Default Value: 0]
/// @param endTime Playback end position in seconds.  Defaults to end of table(0). Updated at Control-rate. [Default Value: 0]
/// @param transpositionRatio Pitch control by way of transposition ratio. Updated at Control-rate. [Default Value: 1]
/// @param amplitude Amplitude of loop. Updated at Control-rate. [Default Value: 1]
/// @param crossfadeDuration crossfade length in seconds, updated once per loop cycle and limited to loop length. Updated at Control-rate. [Default Value: 0]
/// @param loopMode Loop modes are forward, backward, and back and forth.
- (instancetype)initWithTable:(AKTable *)table
                    startTime:(AKParameter *)startTime
                      endTime:(AKParameter *)endTime
           transpositionRatio:(AKParameter *)transpositionRatio
                    amplitude:(AKParameter *)amplitude
            crossfadeDuration:(AKParameter *)crossfadeDuration
                     loopMode:(AKConstant *)loopMode;

/// Instantiates the table looper with default values
/// @param table Sound source table, generally an AKSoundFile.
- (instancetype)initWithTable:(AKTable *)table;

/// Instantiates the table looper with default values
/// @param table Sound source table, generally an AKSoundFile.
+ (instancetype)looperWithTable:(AKTable *)table;

/// Loop start point in seconds. [Default Value: 0]
@property (nonatomic) AKParameter *startTime;

/// Set an optional start time
/// @param startTime Loop start point in seconds. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalStartTime:(AKParameter *)startTime;

/// Playback end position in seconds.  Defaults to end of table(0). [Default Value: 0]
@property (nonatomic) AKParameter *endTime;

/// Set an optional end time
/// @param endTime Playback end position in seconds.  Defaults to end of table(0). Updated at Control-rate. [Default Value: 0]
- (void)setOptionalEndTime:(AKParameter *)endTime;

/// Pitch control by way of transposition ratio. [Default Value: 1]
@property (nonatomic) AKParameter *transpositionRatio;

/// Set an optional transposition ratio
/// @param transpositionRatio Pitch control by way of transposition ratio. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalTranspositionRatio:(AKParameter *)transpositionRatio;

/// Amplitude of loop. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of loop. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// crossfade length in seconds, updated once per loop cycle and limited to loop length. [Default Value: 0]
@property (nonatomic) AKParameter *crossfadeDuration;

/// Set an optional crossfade duration
/// @param crossfadeDuration crossfade length in seconds, updated once per loop cycle and limited to loop length. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalCrossfadeDuration:(AKParameter *)crossfadeDuration;

/// Loop modes are forward, backward, and back and forth.
@property (nonatomic) AKConstant *loopMode;

/// Set an optional loop mode
/// @param loopMode Loop modes are forward, backward, and back and forth.
- (void)setOptionalLoopMode:(AKConstant *)loopMode;



@end
NS_ASSUME_NONNULL_END
