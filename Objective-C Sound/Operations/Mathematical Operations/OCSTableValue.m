//
//  OCSTableValue.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValue.h"

@interface OCSTableValue () {
    OCSParameter *res;
    OCSConstant *ifn;
    OCSParameter *index;
    OCSParameter *ixoff;
    BOOL normalizeResult;
    BOOL wrapData;
}
@end

@implementation OCSTableValue

@synthesize output=res;
@synthesize index;
@synthesize fTable = ifn;
@synthesize normalizeResult;
@synthesize offset = ixoff;
@synthesize wrapData;

- (id)initWithFTable:(OCSConstant *)fTable;
{
    self = [super init];
    if (self) {
        ifn  = fTable;
        normalizeResult = NO;
        ixoff = [OCSConstant parameterWithInt:0];
        wrapData = NO;
    }
    return self; 
    
}

- (id)initWithFTable:(OCSConstant *)fTable
    atAudioRateIndex:(OCSParameter *)audioRateIndex
{
    
    self = [self initWithFTable:fTable];
    
    if (self) {
        res = [OCSParameter parameterWithString:[self operationName]];
        index = audioRateIndex;
    }
    return self; 

}

- (id)initWithFTable:(OCSConstant *)fTable
atControlRateIndex:(OCSControl *)controlRateIndex
{ 
    self = [self initWithFTable:fTable];
    
    if (self) {
        res = [OCSControl parameterWithString:[self operationName]];
        index = controlRateIndex;
    }
    return self; 
}

- (id)initWithFTable:(OCSConstant *)fTable
     atConstantIndex:(OCSConstant *)constantIndex
{
    self = [self initWithFTable:fTable];
    
    if (self) {
        res = [OCSConstant parameterWithString:[self operationName]];
        index = constantIndex;
    }
    return self; 
}

- (NSString *)stringForCSD 
{
    int ixmode = normalizeResult ? 0:1;
    int iwrap = wrapData ? 0:1;
    return [NSString stringWithFormat:@"%@ tablei %@, %@, %i, %@, %i", res, index, ifn, ixmode, ixoff, iwrap];
}
- (NSString *)description {
    return [res parameterString];
}



@end
