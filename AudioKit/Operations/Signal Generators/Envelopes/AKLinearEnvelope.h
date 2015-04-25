//
//  AKLinearEnvelope.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Applies a straight line rise and decay pattern to an input amp signal.

 Rise modifications are applied for the first irise seconds, and decay from time totalDuration - decayTime. If these periods are separated in time there will be a steady state during which amp will be unmodified. If linen rise and decay periods overlap then both modifications will be in effect for that time. If the overall duration is exceeded in performance, the final decay will continue on in the same direction, going negative.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKLinearEnvelope : AKAudio
/// Instantiates the linear envelope with all values
/// @param riseTime Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
/// @param decayTime Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
/// @param totalDuration Overall duration in seconds. [Default Value: 1]
/// @param amplitude Amplitude to rise to and decay from. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithRiseTime:(AKConstant *)riseTime
                       decayTime:(AKConstant *)decayTime
                   totalDuration:(AKConstant *)totalDuration
                       amplitude:(AKParameter *)amplitude;

/// Instantiates the linear envelope with default values
- (instancetype)init;

/// Instantiates the linear envelope with default values
+ (instancetype)envelope;


/// Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
@property (nonatomic) AKConstant *riseTime;

/// Set an optional rise time
/// @param riseTime Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
- (void)setOptionalRiseTime:(AKConstant *)riseTime;

/// Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
@property (nonatomic) AKConstant *decayTime;

/// Set an optional decay time
/// @param decayTime Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
- (void)setOptionalDecayTime:(AKConstant *)decayTime;

/// Overall duration in seconds. [Default Value: 1]
@property (nonatomic) AKConstant *totalDuration;

/// Set an optional total duration
/// @param totalDuration Overall duration in seconds. [Default Value: 1]
- (void)setOptionalTotalDuration:(AKConstant *)totalDuration;

/// Amplitude to rise to and decay from. [Default Value: 1]
@property (nonatomic) AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude Amplitude to rise to and decay from. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;

@end
NS_ASSUME_NONNULL_END
