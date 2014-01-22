//
//  OCSFSignalMix.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignalMix.h"

@interface OCSFSignalMix () {
    OCSFSignal *fSigIn1;
    OCSFSignal *fSigIn2;
}
@end

@implementation OCSFSignalMix

- (instancetype)initWithInput1:(OCSFSignal *)input1
                        input2:(OCSFSignal *)input2;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fSigIn1 = input1;
        fSigIn2 = input2;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pvsmix %@, %@",
            self, fSigIn1, fSigIn2];
}

@end
