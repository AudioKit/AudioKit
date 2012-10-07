//
//  OCSLine.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSParameter *ares;
    OCSControl *kres;
    OCSParameter *res;
    
    OCSConstant *ia;
    OCSConstant *ib;
    OCSConstant *idur;
}
@end

@implementation OCSLine

@synthesize audio = ares;
@synthesize control = kres;
@synthesize output = res;

- (id)initFromValue:(OCSConstant *)startingValue
            toValue:(OCSConstant *)endingValue
           duration:(OCSConstant *)duration
{
    self = [super init];

    if (self) {
        ares   = [OCSParameter parameterWithString:[self operationName]];
        kres = [OCSControl parameterWithString:[self operationName]];
        res  =  ares;
        
        ia = startingValue;
        ib = endingValue;
        idur = duration;
    }
    return self; 
}

//Csound Prototype: (a/k)res linseg ia, idur, ib
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ linseg %@, %@, %@", res, ia, idur, ib];
}

- (NSString *)description {
    return [res parameterString];
}

@end
