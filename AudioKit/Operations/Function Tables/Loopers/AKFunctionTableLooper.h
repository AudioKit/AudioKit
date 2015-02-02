//
//  AKFunctionTableLooper.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Function-table-based crossfading looper.

 This opcode implements a crossfading looper with variable loop parameters and three looping modes. It accepts non-power-of-two tables for its source sounds, such as AKSoundFile Tables.
 */

@interface AKFunctionTableLooper : AKAudio

///Type Helpers
+ (AKConstant *)loopRepeats;
+ (AKConstant *)loopPlaysBackwards;
+ (AKConstant *)loopPlaysForwardAndThenBackwards;

/// Instantiates the function table looper with all values
/// @param functionTable Sound source function table, generally an AKSoundFile. [Default Value: ]
/// @param startTime Loop start point in seconds. Updated at Control-rate. [Default Value: 0]
/// @param endTime Playback end position in seconds.  Defaults to end of function table(0). Updated at Control-rate. [Default Value: 0]
/// @param transpositionRatio Pitch control by way of transposition ratio. Updated at Control-rate. [Default Value: 1]
/// @param amplitude Amplitude of loop. Updated at Control-rate. [Default Value: 1]
/// @param crossfadeDuration crossfade length in seconds, updated once per loop cycle and limited to loop length. Updated at Control-rate. [Default Value: 0]
/// @param loopMode Loop modes are forward, backward, and back and forth. [Default Value: AKFunctionTableLooperModeNormal]
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable
                            startTime:(AKParameter *)startTime
                              endTime:(AKParameter *)endTime
                   transpositionRatio:(AKParameter *)transpositionRatio
                            amplitude:(AKParameter *)amplitude
                    crossfadeDuration:(AKParameter *)crossfadeDuration
                             loopMode:(AKConstant *)loopMode;

/// Instantiates the function table looper with default values
/// @param functionTable Sound source function table, generally an AKSoundFile.
- (instancetype)initWithFunctionTable:(AKFunctionTable *)functionTable;

/// Instantiates the function table looper with default values
/// @param functionTable Sound source function table, generally an AKSoundFile.
+ (instancetype)looperWithFunctionTable:(AKFunctionTable *)functionTable;

/// Loop start point in seconds. [Default Value: 0]
@property AKParameter *startTime;

/// Set an optional start time
/// @param startTime Loop start point in seconds. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalStartTime:(AKParameter *)startTime;

/// Playback end position in seconds.  Defaults to end of function table(0). [Default Value: 0]
@property AKParameter *endTime;

/// Set an optional end time
/// @param endTime Playback end position in seconds.  Defaults to end of function table(0). Updated at Control-rate. [Default Value: 0]
- (void)setOptionalEndTime:(AKParameter *)endTime;

/// Pitch control by way of transposition ratio. [Default Value: 1]
@property AKParameter *transpositionRatio;

/// Set an optional transposition ratio
/// @param transpositionRatio Pitch control by way of transposition ratio. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalTranspositionRatio:(AKParameter *)transpositionRatio;

/// Amplitude of loop. [Default Value: 1]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude of loop. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

/// crossfade length in seconds, updated once per loop cycle and limited to loop length. [Default Value: 0]
@property AKParameter *crossfadeDuration;

/// Set an optional crossfade duration
/// @param crossfadeDuration crossfade length in seconds, updated once per loop cycle and limited to loop length. Updated at Control-rate. [Default Value: 0]
- (void)setOptionalCrossfadeDuration:(AKParameter *)crossfadeDuration;

/// Loop modes are forward, backward, and back and forth. [Default Value: AKFunctionTableLooperModeNormal]
@property AKConstant *loopMode;

/// Set an optional loop mode
/// @param loopMode Loop modes are forward, backward, and back and forth. [Default Value: AKFunctionTableLooperModeNormal]
- (void)setOptionalLoopMode:(AKConstant *)loopMode;



@end
