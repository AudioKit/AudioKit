//
//  OCSLinearControl.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLinearControl.h"

@interface OCSLinearControl () {
    OCSControl *output;
    
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
    self = [super init];
    
    if (self) {
        output = [OCSControl parameterWithString:[self operationName]];
        
        ia = startingValue;
        ib = endingValue;
        idur = duration;
    }
    return self;
}

//Csound Prototype: (a/k)res linseg ia, idur, ib
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ linseg %@, %@, %@", output, ia, idur, ib];
}

- (NSString *)description {
    return [output parameterString];
}


@end
