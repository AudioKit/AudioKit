//
//  AKCrossSynthesis.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pvscross:
//  http://www.csounds.com/manual/html/pvscross.html
//

#import "AKCrossSynthesis.h"

@implementation AKCrossSynthesis
{
    AKFSignal *fsrc;
    AKFSignal *fdest;
    AKControl *kamp1;
    AKControl *kamp2;
}

- (instancetype)initWithSignal1:(AKFSignal *)signal1
                        signal2:(AKFSignal *)signal2
                     amplitude1:(AKControl *)amplitude1
                     amplitude2:(AKControl *)amplitude2
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fsrc = signal1;
        fdest = signal2;
        kamp1 = amplitude1;
        kamp2 = amplitude2;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvscross %@, %@, %@, %@",
            self, fsrc, fdest, kamp1, kamp2];
}

@end