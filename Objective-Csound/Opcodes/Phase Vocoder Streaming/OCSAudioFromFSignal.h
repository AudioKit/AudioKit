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

@property (nonatomic, strong) OCSParameter *output;

@property (nonatomic, strong) OCSFSignal *source;

- (id)initWithSource:(OCSFSignal *)source;

@end
