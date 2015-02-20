//
//  AKMixedFFT.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKMixedFFT.h"

@implementation AKMixedFFT
{
    AKFSignal *fSigIn1;
    AKFSignal *fSigIn2;
}

- (instancetype)initWithSignal1:(AKFSignal *)signal1
                        signal2:(AKFSignal *)signal2;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fSigIn1 = signal1;
        fSigIn2 = signal2;
        self.state = @"connectable";
        self.dependencies = @[fSigIn1, fSigIn2];

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
