//
//  OCSFMOscillator.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSFMOscillator.h"

@interface OCSFMOscillator () {
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

@implementation OCSFMOscillator

@synthesize amplitude = amp;
@synthesize baseFrequency = freq;
@synthesize carrierMultiplier = car;
@synthesize modulatingMultiplier = mod;
@synthesize modulationIndex = modIndex;
@synthesize functionTable = f;
@synthesize phase = phs;
@synthesize output;

- (id)initWithAmplitude:(OCSParam *)amplitude
          baseFrequency:(OCSParamControl *)baseFrequency
      carrierMultiplier:(OCSParam *)carrierMultiplier
   modulatingMultiplier:(OCSParam *)modulatingMultiplier
        modulationIndex:(OCSParamControl *)modulationIndex
          functionTable:(OCSFunctionTable *)functionTable
                  phase:(OCSParamConstant *)phase;
{
    self = [super init];
    if ( self ) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amp  = amplitude;
        freq = baseFrequency;
        car  = carrierMultiplier;
        mod  = modulatingMultiplier;
        modIndex = modulationIndex;
        f = functionTable;
        phs = phase;
    }
    return self;
}

- (id)initWithAmplitude:(OCSParam *)amplitude
          baseFrequency:(OCSParamControl *)baseFrequency
      carrierMultiplier:(OCSParam *)carrierMultiplier
   modulatingMultiplier:(OCSParam *)modulatingMultiplier
        modulationIndex:(OCSParamControl *)modulationIndex
          functionTable:(OCSFunctionTable *)functionTable;
{
    return [self initWithAmplitude:amplitude
                     baseFrequency:baseFrequency
                 carrierMultiplier:carrierMultiplier
              modulatingMultiplier:modulatingMultiplier
                   modulationIndex:modulationIndex
                     functionTable:functionTable
                             phase:[OCSParamConstant paramWithInt:0]];
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

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
