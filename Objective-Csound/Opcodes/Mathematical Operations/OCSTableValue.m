//
//  OCSTableValue.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValue.h"

@interface OCSTableValue () {
    OCSParameter *output;
    OCSConstant *ifn;
    OCSParameter *index;
}
@end

@implementation OCSTableValue

@synthesize output;
@synthesize index;
@synthesize fTable = ifn;
@synthesize normalizeResult = ixmode;
@synthesize offset = ixoff;
@synthesize wrapData = iwrap;

- (id)initWithFTable:(OCSConstant *)fTable;
{
    self = [super init];
    if (self) {
        ifn  = fTable;
        ixmode = NO;
        ixoff = 0;
        iwrap = NO;
    }
    return self; 
    
}

- (id)initWithFTable:(OCSConstant *)fTable
    atAudioRateIndex:(OCSParameter *)audioRateIndex
{
    
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSParameter parameterWithString:[self opcodeName]];   
        index = audioRateIndex;
    }
    return self; 

}

- (id)initWithFTable:(OCSConstant *)fTable
atControlRateIndex:(OCSControl *)controlRateIndex
{ 
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSControl parameterWithString:[self opcodeName]];   
        index = controlRateIndex;
    }
    return self; 
}

- (id)initWithFTable:(OCSConstant *)fTable
     atConstantIndex:(OCSConstant *)constantIndex
{
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSConstant parameterWithString:[self opcodeName]];   
        index = constantIndex;
    }
    return self; 
}

// Csound Prototype: kscl scale kinput, kmax, kmin
- (NSString *)stringForCSD 
{
    int mode = ixmode ? 0:1;
    int wrap = iwrap  ? 0:1;
    return [NSString stringWithFormat:@"%@ tablei %@, %@, %@, %i, %@, %i", output, index, ifn, mode, ixoff, wrap];
}
- (NSString *)description {
    return [output parameterString];
}



@end
