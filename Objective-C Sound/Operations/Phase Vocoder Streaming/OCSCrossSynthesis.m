//
//  OCSCrossSynthesis.m
//  Objective-C Sound
//
//  Auto-generated from database on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pvscross:
//  http://www.csounds.com/manual/html/pvscross.html
//

#import "OCSCrossSynthesis.h"

@interface OCSCrossSynthesis () {
    OCSFSignal *fsrc;
    OCSFSignal *fdest;
    OCSControl *kamp1;
    OCSControl *kamp2;
}
@end

@implementation OCSCrossSynthesis

- (id)initWithSignal1:(OCSFSignal *)signal1
              signal2:(OCSFSignal *)signal2
           amplitude1:(OCSControl *)amplitude1
           amplitude2:(OCSControl *)amplitude2
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