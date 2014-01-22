//
//  OCSAudioFromFSignal.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"
#import "OCSFSignal.h"

/** Resynthesise phase vocoder data (f-signal) using a FFT overlap-add.
 */

@interface OCSAudioFromFSignal : OCSAudio

/// Create audio from an f-signal
/// @param source Input f-signal
- (instancetype)initWithSource:(OCSFSignal *)source;

@end
