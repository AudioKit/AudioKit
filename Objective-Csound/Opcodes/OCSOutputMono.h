//
//  OCSOutputMono.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Writes mono audio data to an external device or stream.
 
 Sends mono audio samples to an accumulating output buffer 
 (created at the beginning of performance) which serves to collect the 
 output of all active instruments before the sound is written to disk. 
 There can be any number of these output units in an instrument.
 */

@interface OCSOutputMono : OCSOpcode 

/// Create the mono audio output.
/// @param monoSignal The audio that should be played.
- (id)initWithInput:(OCSParam *)monoSignal;

@end
