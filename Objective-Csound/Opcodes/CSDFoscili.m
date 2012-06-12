//
//  CSDFoscili.m
//
//  Created by Adam Boulanger on 5/29/12.
//  Copyright (c) 2012 MIT Media Lab. All rights reserved.
//

#import "CSDFoscili.h"

@implementation CSDFoscili
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
@synthesize output;
@synthesize amplitude;
@synthesize pitch;
@synthesize carrier;
@synthesize modulation;
@synthesize modIndex;
@synthesize functionTable;
@synthesize phase;

//H4Y - ARB: probably need to set output in the init
-(id)initFMOscillatorWithAmplitude:(CSDParam *)amp
                             Pitch:(CSDParamControl *)cps
                           Carrier:(CSDParam *)car
                        Modulation:(CSDParam *)mod
                          ModIndex:(CSDParamControl *)aModIndex
                     FunctionTable:(CSDFunctionTable *)f
                  AndOptionalPhase:(CSDParamConstant *)phs
{
    self = [super init];
    if ( self ) {
        /*create text for instrument assignment 
           (text retrieved by CSDManager from array of added instruments
         */
        output         = [CSDParam paramWithString:[self uniqueName]];
        amplitude      = amp;
        pitch          = cps;
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
                       output,
                       amplitude, 
                       pitch, 
                       carrier, 
                       modulation, 
                       modIndex, 
                       [functionTable output]];
    } else{
        s = [NSString stringWithFormat:
                       @"%@ foscili %@, %@, %@, %@, %@, %@, %@\n",
                       output,
                       amplitude, 
                       pitch, 
                       carrier, 
                       modulation, 
                       modIndex, 
                       [functionTable output], 
                       phase];

    }
    NSLog(@"Foscil csdRepresentation created:%@", s);
    return s;
}

-(NSString *) description {
    return [output parameterString];
}

@end
