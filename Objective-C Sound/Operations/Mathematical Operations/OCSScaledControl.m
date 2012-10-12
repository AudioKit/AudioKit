//
//  OCSScaledControl.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSScaledControl.h"  

@interface OCSScaledControl () {
    OCSControl *kin;
    OCSControl *kmax;
    OCSControl *kmin;
}
@end

@implementation OCSScaledControl

- (id)initWithInput:(OCSControl *)input
      minimumOutput:(OCSControl *)minimumOutput
      maximumOutput:(OCSControl *)maximumOutput;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kin  = input;
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

