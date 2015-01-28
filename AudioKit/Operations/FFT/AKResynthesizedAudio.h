//
//  AKAudioFromFSignal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"
#import "AKFSignal.h"

/** Resynthesise phase vocoder data (f-signal) using a FFT overlap-add.
 */

@interface AKAudioFromFSignal : AKAudio

/// Create audio from an f-signal
/// @param source Input f-signal
- (instancetype)initWithSource:(AKFSignal *)source;

@end
