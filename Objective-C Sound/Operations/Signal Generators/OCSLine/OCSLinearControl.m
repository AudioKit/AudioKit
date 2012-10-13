//
//  OCSLinearControl.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLinearControl.h"

@interface OCSLinearControl () {
    OCSConstant *ia;
    OCSConstant *ib;
    OCSConstant *idur;
}
@end

@implementation OCSLinearControl

- (id)initFromValue:(OCSConstant *)startingValue
            toValue:(OCSConstant *)endingValue
           duration:(OCSConstant *)duration
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ia = startingValue;
        ib = endingValue;
        idur = duration;
    }
    return self;
}

//Csound Prototype: (a/k)res linseg ia, idur, ib
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ linseg %@, %@, %@",
            self, ia, idur, ib];
}

@end
