//
//  OCSFSignalMix.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSFSignal.h"

/** Mix 'seamlessly' two pv signals. This opcode combines the most prominent 
 components of two pvoc streams into a single mixed stream.
 */

@interface OCSFSignalMix : OCSParameter

/// @name Properties

/// The mixed f-signal
@property (nonatomic, strong) OCSFSignal *output;

/// The first f-signal
@property (nonatomic, strong) OCSFSignal *input1;

/// The second f-signal
@property (nonatomic, strong) OCSFSignal *input2;

/// @name Initialization

/// Create a mixture of two f-signal.
/// @param input1 The first f-signal.
/// @param input2 The second f-signal.
- (id)initWithInput1:(OCSFSignal *)input1
              input2:(OCSFSignal *)input2;


@end
