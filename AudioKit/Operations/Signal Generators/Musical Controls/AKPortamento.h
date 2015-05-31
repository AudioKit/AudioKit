//
//  AKPortamento.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Applies portamento to a step-valued control signal.

 Applies portamento to a step-valued control signal. At each new step value, the output is low-pass filtered to move towards that value at a rate determined by halfTime. halfTime is the “half-time” of the function (in seconds), during which the curve will traverse half the distance towards the new value, then half as much again, etc., theoretically never reaching its asymptote.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKPortamento : AKControl
/// Instantiates the portamento with all values
/// @param input The input signal at control-rate. Updated at Control-rate. 
/// @param halfTime Half-time of the function in seconds. Updated at Control-rate. [Default Value: 1]
- (instancetype)initWithInput:(AKParameter *)input
                     halfTime:(AKParameter *)halfTime;

/// Instantiates the portamento with default values
/// @param input The input signal at control-rate.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the portamento with default values
/// @param input The input signal at control-rate.
+ (instancetype)portamentoWithInput:(AKParameter *)input;

/// Half-time of the function in seconds. [Default Value: 1]
@property (nonatomic) AKParameter *halfTime;

/// Set an optional half time
/// @param halfTime Half-time of the function in seconds. Updated at Control-rate. [Default Value: 1]
- (void)setOptionalHalfTime:(AKParameter *)halfTime;



@end
NS_ASSUME_NONNULL_END
