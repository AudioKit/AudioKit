//
//  CSDFoscili.m
//  Missilez
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDFoscili.h"

@implementation CSDFoscili
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@synthesize output;
@synthesize opcode;
@synthesize xAmplitude;
@synthesize kPitch;
@synthesize xCarrier;
@synthesize xModulation;
@synthesize kModIndex;
@synthesize functionTable;
@synthesize iPhase;

//H4Y - ARB: probably need to set output in the init
-(id)initFMOscillatorWithAmplitude:(CSDParam *)amp
                            kPitch:(CSDParam *)cps
                          kCarrier:(CSDParam *)car
                       xModulation:(CSDParam *)mod
                         kModIndex:(CSDParam *)modIndex
                     FunctionTable:(CSDFunctionStatement *)f
                  AndOptionalPhase:(CSDParam *)phs
{
    self = [super init];
    if ( self ) {
        /*create text for instrument assignment 
           (text retrieved by CSDManager from array of added instruments
         */
        xAmplitude      = amp;
        kPitch          = cps;
        xCarrier        = car;
        xModulation     = mod;
        kModIndex       = modIndex;
        functionTable   = f;
        iPhase          = phs;
    }
    return self;
}

-(NSString *)convertToCsd
{
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    NSString *s;
    if ( iPhase == nil) {
        s = [NSString stringWithFormat:
                       @"%@ foscili %@, %@, %@, %@, %@, %@\n",
                       output,
                       [xAmplitude parameterString], 
                       [kPitch parameterString], 
                       [xCarrier parameterString], 
                       [xModulation parameterString], 
                       [kModIndex parameterString], 
                       [functionTable output], 
                       [iPhase parameterString]];
    } else{
        s = [NSString stringWithFormat:
                       @"%@ foscili %@, %@, %@, %@, %@, %@, %@\n",
                       output,
                       [xAmplitude parameterString], 
                       [kPitch parameterString], 
                       [xCarrier parameterString], 
                       [xModulation parameterString], 
                       [kModIndex parameterString], 
                       [functionTable output], 
                       [iPhase parameterString]];

    }
    NSLog(@"Foscil csdRepresentation created:%@", s);
    return s;
}

@end
