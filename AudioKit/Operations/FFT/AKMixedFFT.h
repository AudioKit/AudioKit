//
//  AKFSignalMix.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKFSignal.h"

/** Mix 'seamlessly' two pv signals. This opcode combines the most prominent
 components of two pvoc streams into a single mixed stream.
 */

@interface AKFSignalMix : AKFSignal

/// Create a mixture of two f-signal.
/// @param input1 The first f-signal.
/// @param input2 The second f-signal.
- (instancetype)initWithInput1:(AKFSignal *)input1
                        input2:(AKFSignal *)input2;


@end
