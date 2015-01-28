//
//  AKFSignalMix.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignalMix.h"

@implementation AKFSignalMix
{
    AKFSignal *fSigIn1;
    AKFSignal *fSigIn2;
}

- (instancetype)initWithInput1:(AKFSignal *)input1
                        input2:(AKFSignal *)input2;
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
