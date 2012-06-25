//
//  OCSOutputStereo.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Writes stereo audio data to an external device or stream.
 
 Sends stereo audio samples to an accumulating output buffer 
 (created at the beginning of performance) which serves to 
 collect the output of all active instruments before the 
 sound is written to disk. There can be any number of these 
 output units in an instrument.
 
 */
@interface OCSOutputStereo : OCSOpcode {
    OCSParam *inputLeft;
    OCSParam *inputRight;
}

/// Helper function to send both channels the same monoSignal
- (id)initWithMonoInput:(OCSParam *) monoSignal;

/// Initialization Statement
- (id)initWithLeftInput:(OCSParam *) leftInput
             RightInput:(OCSParam *) rightInput;

@end
