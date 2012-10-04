//
//  OCSFMOscillator.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//
//  Implementation of Csound's foscili:
// http://www.csounds.com/manual/html/foscili.html
//

#import "OCSFMOscillator.h"

@interface OCSFMOscillator () {
    OCSParameter *amp;
    OCSControl *freq;
    OCSParameter *car;
    OCSParameter *mod;
    OCSControl *modIndex;
    OCSFTable *f;
    OCSConstant *phs;
    OCSParameter *output;
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

- (id)initWithFTable:(OCSFTable *)fTable
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude
               phase:(OCSConstant *)phase;
{
    self = [super init];
    if ( self ) {
        output = [OCSParameter parameterWithString:[self operationName]];
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

- (id)initWithFTable:(OCSFTable *)fTable
       baseFrequency:(OCSControl *)baseFrequency
   carrierMultiplier:(OCSParameter *)carrierMultiplier
modulatingMultiplier:(OCSParameter *)modulatingMultiplier
     modulationIndex:(OCSControl *)modulationIndex
           amplitude:(OCSParameter *)amplitude;
{
    return [self initWithFTable:fTable
                  baseFrequency:baseFrequency
              carrierMultiplier:carrierMultiplier
           modulatingMultiplier:modulatingMultiplier
                modulationIndex:modulationIndex
                      amplitude:amplitude
                          phase:[OCSConstant parameterWithInt:0]];
}

// Csound Prototype: ares foscili xamp, kcps, xcar, xmod, kndx, ifn (, iphs)
- (NSString *)stringForCSD
{
    // Clean up for uninitialized parameters
    if (phs == nil)    phs    = [OCSConstant parameterWithInt:0];
    if (output == nil) output = [OCSParameter parameterWithString:[self operationName]];
    
    
    return[NSString stringWithFormat:
             @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
             output, amp, freq, car, mod, modIndex, f, phs];
}
 
- (NSString *)description {
    return [output parameterString];
}

@end
