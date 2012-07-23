//
//  OCSAudioFromFSignal.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSFSignal.h"

/** Resynthesise phase vocoder data (f-signal) using a FFT overlap-add.
 */

@interface OCSAudioFromFSignal : OCSOpcode

/// @name Properties

/// Audio resynthesized from an f-signal
@property (nonatomic, strong) OCSParameter *output;

/// Input f-signal
@property (nonatomic, strong) OCSFSignal *source;

/// @name Initialization

/// Create audio from an f-signal
/// @param source Input f-signal
- (id)initWithSource:(OCSFSignal *)source;

@end
