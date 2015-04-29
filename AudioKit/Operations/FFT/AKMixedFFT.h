//
//  AKMixedFFT.h
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

NS_ASSUME_NONNULL_BEGIN
@interface AKMixedFFT : AKFSignal

/// Create a mixture of two f-signal.
/// @param signal1 The first f-signal.
/// @param signal2 The second f-signal.
- (instancetype)initWithSignal1:(AKFSignal *)signal1
                        signal2:(AKFSignal *)signal2;

@end
NS_ASSUME_NONNULL_END
