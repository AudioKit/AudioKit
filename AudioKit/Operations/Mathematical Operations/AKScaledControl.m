//
//  AKScaledControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKScaledControl.h"

@interface AKScaledControl () {
    AKControl *kin;
    AKControl *kmax;
    AKControl *kmin;
}
@end

@implementation AKScaledControl

- (instancetype)initWithControl:(AKControl *)inputControl
                  minimumOutput:(AKControl *)minimumOutput
                  maximumOutput:(AKControl *)maximumOutput;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kin  = inputControl;
        kmax = maximumOutput;
        kmin = minimumOutput;
    }
    return self;
}

// Csound Prototype: kscl scale kinput, kmax, kmin
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ scale %@, %@, %@",
            self, kin, kmax, kmin];
}

@end

