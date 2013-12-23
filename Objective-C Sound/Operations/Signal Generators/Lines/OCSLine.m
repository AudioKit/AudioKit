//
//  OCSLine.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSConstant *ia;
    OCSConstant *ib;
    OCSConstant *idur;
}
@end

@implementation OCSLine

- (instancetype)initFromValue:(OCSConstant *)startingValue
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
