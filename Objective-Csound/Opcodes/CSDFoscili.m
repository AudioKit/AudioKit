//
//  CSDFoscili.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDFoscili.h"

@implementation CSDFoscili

@synthesize output;

-(id)initWithAmplitude:(CSDParam *) amp
             Frequency:(CSDParamControl *) cps
               Carrier:(CSDParam *) car
            Modulation:(CSDParam *) mod
              ModIndex:(CSDParamControl *) aModIndex
         FunctionTable:(CSDFunctionTable *) f
      AndOptionalPhase:(CSDParamConstant *) phs
{
    self = [super init];
    if ( self ) {
        output         = [CSDParam paramWithString:[self uniqueName]];
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

-(NSString *)convertToCsd
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

-(NSString *)description {
    return [output parameterString];
}

@end
