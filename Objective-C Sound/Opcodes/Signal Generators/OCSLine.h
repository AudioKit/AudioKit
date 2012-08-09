//
//  OCSLine.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**
 Creates a line that extends from a starting to a second point over the given 
 time duration.  After that duration, the line continues at the same slope until
 the note event ends.  Can be an audio signal or control rate parameter.
 
 Csound Prototype:
 
    ares line ia, idur, ib
    kres line ia, idur, ib
 */

@interface OCSLine : OCSOpcode

/// @name Properties

/// This is the audio signal.
@property (nonatomic, strong) OCSParameter *audio;

/// This is the control parameter.
@property (nonatomic, strong) OCSControl *control;

/// The output is the audio signal or the control.
@property (nonatomic, strong) OCSParameter *output;

/// @name Initialization

/// Initialize a linear transition from one value to another over specified time.
/// @param startingValue Value to start the line from.
/// @param endingValue   Value to end the line at.
/// @param duration      Duration of linear transition in seconds.
/// @return An opcode to perform a linear transition over a given duration.
- (id)initFromValue:(OCSConstant *)startingValue
            toValue:(OCSConstant *)endingValue
           duration:(OCSConstant *)duration;
    

@end
