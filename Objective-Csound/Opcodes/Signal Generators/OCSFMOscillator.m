//
//  OCSFMOscillator.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "OCSFMOscillator.h"

@interface OCSFMOscillator () {
    OCSParam *amp;
    OCSControlParam *freq;
    OCSParam *car;
    OCSParam *mod;
    OCSControlParam *modIndex;
    OCSFTable *f;
    OCSConstantParam *phs;
    OCSParam *output;
}
@end

@implementation OCSFMOscillator

@synthesize amplitude = amp;
@synthesize baseFrequency = freq;
@synthesize carrierMultiplier = car;
@synthesize modulatingMultiplier = mod;
@synthesize modulationIndex = modIndex;
@synthesize fTable = f;
@synthesize phase = phs;
@synthesize output;

- (id)initWithAmplitude:(OCSParam *)amplitude
          baseFrequency:(OCSControlParam *)baseFrequency
      carrierMultiplier:(OCSParam *)carrierMultiplier
   modulatingMultiplier:(OCSParam *)modulatingMultiplier
        modulationIndex:(OCSControlParam *)modulationIndex
                 fTable:(OCSFTable *)fTable
                  phase:(OCSConstantParam *)phase;
{
    self = [super init];
    if ( self ) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amp  = amplitude;
        freq = baseFrequency;
        car  = carrierMultiplier;
        mod  = modulatingMultiplier;
        modIndex = modulationIndex;
        f = fTable;
        phs = phase;
    }
    return self;
}

- (id)initWithAmplitude:(OCSParam *)amplitude
          baseFrequency:(OCSControlParam *)baseFrequency
      carrierMultiplier:(OCSParam *)carrierMultiplier
   modulatingMultiplier:(OCSParam *)modulatingMultiplier
        modulationIndex:(OCSControlParam *)modulationIndex
                 fTable:(OCSFTable *)fTable;
{
    return [self initWithAmplitude:amplitude
                     baseFrequency:baseFrequency
                 carrierMultiplier:carrierMultiplier
              modulatingMultiplier:modulatingMultiplier
                   modulationIndex:modulationIndex
                     fTable:fTable
                             phase:[OCSConstantParam paramWithInt:0]];
}

/// CSD Representation: ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
- (NSString *)stringForCSD
{
    // Clean up for uninitialized parameters
    if (phs == nil)    phs    = [OCSConstantParam paramWithInt:0];
    if (output == nil) output = [OCSParam paramWithString:[self opcodeName]];
    
    
    return[NSString stringWithFormat:
             @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
             output, amp, freq, car, mod, modIndex, f, phs];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
