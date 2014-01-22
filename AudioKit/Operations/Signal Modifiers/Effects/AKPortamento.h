//
//  AKPortamento.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/14/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Applies portamento to a step-valued control signal.
 
 applies portamento to a step-valued control signal. At each new step value, the output is low-pass filtered to move towards that value at a rate determined by halfTime. halfTime is the “half-time” of the function (in seconds), during which the curve will traverse half the distance towards the new value, then half as much again, etc., theoretically never reaching its asymptote.
 */

@interface AKPortamento : AKControl

/// Instantiates the portamento
/// @param controlSource The input signal at control-rate.
/// @param halfTime Half-time of the function in seconds.
- (instancetype)initWithControlSource:(AKControl *)controlSource
                             halfTime:(AKControl *)halfTime;

-(void)setOptionalFeedbackAmount:(AKConstant *)feedback;

@end