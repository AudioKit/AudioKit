//
//  AKLine.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKLine.h"

@interface AKLine () {
    AKConstant *ia;
    AKConstant *ib;
    AKConstant *idur;
}
@end

@implementation AKLine

- (instancetype)initFromValue:(AKConstant *)startingValue
                      toValue:(AKConstant *)endingValue
                     duration:(AKConstant *)duration
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
