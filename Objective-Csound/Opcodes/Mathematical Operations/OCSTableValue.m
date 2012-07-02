//
//  OCSTableValue.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 7/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTableValue.h"

@interface OCSTableValue () {
    OCSParam *output;
    OCSParamConstant *ifn;
    OCSParam *index;
}
@end

@implementation OCSTableValue

@synthesize output;
@synthesize index;
@synthesize fTable = ifn;
@synthesize normalizeResult = ixmode;
@synthesize offset = ixoff;
@synthesize wrapData = iwrap;

- (id)initWithFTable:(OCSParamConstant *)fTable;
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

- (id)initWithFTable:(OCSParamConstant *)fTable
    atAudioRateIndex:(OCSParam *)audioRateIndex
{
    
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSParam paramWithString:[self opcodeName]];   
        index = audioRateIndex;
    }
    return self; 

}

- (id)initWithFTable:(OCSParamConstant *)fTable
atControlRateIndex:(OCSParamControl *)controlRateIndex
{ 
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];   
        index = controlRateIndex;
    }
    return self; 
}

- (id)initWithFTable:(OCSParamConstant *)fTable
     atConstantIndex:(OCSParamConstant *)constantIndex
{
    self = [self initWithFTable:fTable];
    
    if (self) {
        output = [OCSParamConstant paramWithString:[self opcodeName]];   
        index = constantIndex;
    }
    return self; 
}

/// CSD Representation: kscl scale kinput, kmax, kmin
- (NSString *)stringForCSD 
{
    int mode = ixmode ? 0:1;
    int wrap = iwrap  ? 0:1;
    return [NSString stringWithFormat:@"%@ tablei %@, %@, %@, %i, %@, %i", output, index, ifn, mode, ixoff, wrap];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}



@end
