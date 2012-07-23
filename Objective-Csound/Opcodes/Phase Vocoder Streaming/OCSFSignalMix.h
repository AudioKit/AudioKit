//
//  OCSFSignalMix.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSFSignal.h"

/** Mix 'seamlessly' two pv signals. This opcode combines the most prominent 
 components of two pvoc streams into a single mixed stream.
 */

@interface OCSFSignalMix : OCSOpcode

@property (nonatomic, strong) OCSFSignal *output;

@property (nonatomic, strong) OCSFSignal *input1;

@property (nonatomic, strong) OCSFSignal *input2;

- (id)initWithInput1:(OCSFSignal *)input1
              input2:(OCSFSignal *)input2;


@end
