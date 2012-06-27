//
//  OCSFoscili.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSFoscili.h"

@interface OCSFoscili () {
    OCSParam *amp;
    OCSParamControl *freq;
    OCSParam *car;
    OCSParam *mod;
    OCSParamControl *modIndex;
    OCSFunctionTable *f;
    OCSParamConstant *phs;
    OCSParam *output;
}
@end

@implementation OCSFoscili

@synthesize amplitude = amp;
@synthesize baseFrequency = freq;
@synthesize carrierMultiplier = car;
@synthesize modulatingMultiplier = mod;
@synthesize modulationIndex = modIndex;
@synthesize functionTable = f;
@synthesize phase = phs;
@synthesize output;

- (id)initWithAmplitude:(OCSParam *)amplitude
          BaseFrequency:(OCSParamControl *)baseFrequency
      CarrierMultiplier:(OCSParam *)carrierMutliplier
   ModulatingMultiplier:(OCSParam *)modulatingMultiplier
        ModulationIndex:(OCSParamControl *)modulationIndex
          FunctionTable:(OCSFunctionTable *)functionTable
                  Phase:(OCSParamConstant *)phase;
{
    self = [super init];
    if ( self ) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amp  = amplitude;
        freq = baseFrequency;
        car  = carrierMutliplier;
        mod  = modulatingMultiplier;
        modIndex = modulationIndex;
        f = functionTable;
        phs = phase;
    }
    return self;
}

- (id)initWithAmplitude:(OCSParam *)amplitude
          BaseFrequency:(OCSParamControl *)baseFrequency
      CarrierMultiplier:(OCSParam *)carrierMutliplier
   ModulatingMultiplier:(OCSParam *)modulatingMultiplier
        ModulationIndex:(OCSParamControl *)modulationIndex
          FunctionTable:(OCSFunctionTable *)functionTable;
{
    return [self initWithAmplitude:amplitude
                     BaseFrequency:baseFrequency
                 CarrierMultiplier:carrierMutliplier
              ModulatingMultiplier:modulatingMultiplier
                   ModulationIndex:modulationIndex
                     FunctionTable:functionTable
                             Phase:[OCSParamConstant paramWithInt:0]];
}

- (NSString *)stringForCSD
{
    // Clean up for uninitialized parameters
    if (phs == nil)    phs    = [OCSParamConstant paramWithInt:0];
    if (output == nil) output = [OCSParam paramWithString:[self opcodeName]];
    
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    return[NSString stringWithFormat:
             @"%@ foscili %@, %@, %@, %@, %@, %@, %@\n",
             output, amp, freq, car, mod, modIndex, f, phs];
}

- (NSString *)description {
    return [output parameterString];
}

@end
