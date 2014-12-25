//
//  AKLinearControlEnvelope.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** One line title / summary for the operation.

 More detailed description from http://www.csounds.com/manual/html/
 */

@interface AKLinearControlEnvelope : AKControl
/// Instantiates the linear control envelope with all values
/// @param riseTime Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
/// @param decayTime Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
/// @param totalDuration Overall duration in seconds. [Default Value: 1]
/// @param amplitude mplitude to rise to and decay from. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithRiseTime:(AKConstant *)riseTime
                       decayTime:(AKConstant *)decayTime
                   totalDuration:(AKConstant *)totalDuration
                       amplitude:(AKParameter *)amplitude;

/// Instantiates the linear control envelope with default values
- (instancetype)init;

/// Instantiates the linear control envelope with default values
+ (instancetype)control;


/// Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
@property AKConstant *riseTime;

/// Set an optional rise time
/// @param riseTime Rise time in seconds. A zero or negative value signifies no rise modification. [Default Value: 0.33]
- (void)setOptionalRiseTime:(AKConstant *)riseTime;

/// Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
@property AKConstant *decayTime;

/// Set an optional decay time
/// @param decayTime Decay time in seconds. Zero means no decay. If it is greater than the total duration, it will cause a truncated decay. [Default Value: 0.33]
- (void)setOptionalDecayTime:(AKConstant *)decayTime;

/// Overall duration in seconds. [Default Value: 1]
@property AKConstant *totalDuration;

/// Set an optional total duration
/// @param totalDuration Overall duration in seconds. [Default Value: 1]
- (void)setOptionalTotalDuration:(AKConstant *)totalDuration;

/// mplitude to rise to and decay from. [Default Value: 1]
@property AKParameter *amplitude;

/// Set an optional amplitude
/// @param amplitude mplitude to rise to and decay from. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalAmplitude:(AKParameter *)amplitude;



@end
