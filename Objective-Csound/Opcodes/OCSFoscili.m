//
//  OCSFoscili.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSFoscili.h"

@interface OCSFoscili () {
    OCSParam *amplitude;
    OCSParamControl *frequency;
    OCSParam *carrier;
    OCSParam *modulation;
    OCSParamControl *modIndex;
    OCSFunctionTable *functionTable;
    OCSParamConstant *phase;
    OCSParam *output;
}
@end

@implementation OCSFoscili

@synthesize output;

- (id)initWithAmplitude:(OCSParam *)amp
             Frequency:(OCSParamControl *)cps
               Carrier:(OCSParam *)car
            Modulation:(OCSParam *)mod
              ModIndex:(OCSParamControl *)aModIndex
         FunctionTable:(OCSFunctionTable *)f
      AndOptionalPhase:(OCSParamConstant *)phs
{
    self = [super init];
    if ( self ) {
        output         = [OCSParam paramWithString:[self opcodeName]];
        amplitude      = amp;
        frequency      = cps;
        carrier        = car;
        modulation     = mod;
        modIndex       = aModIndex;
        functionTable  = f;
        phase          = phs;
    }
    return self;
}

- (NSString *)stringForCSD
{
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    NSString *s;
    if ( phase == nil) {
        s = [NSString stringWithFormat:
             @"%@ foscili %@, %@, %@, %@, %@, %@\n",
             output, amplitude, frequency, carrier, modulation, modIndex, functionTable];
    } else{
        s = [NSString stringWithFormat:
             @"%@ foscili %@, %@, %@, %@, %@, %@, %@\n",
             output, amplitude, frequency, carrier, modulation, modIndex, functionTable, phase];
        
    }
    return s;
}

- (NSString *)description {
    return [output parameterString];
}

@end
