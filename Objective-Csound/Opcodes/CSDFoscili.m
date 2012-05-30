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
@synthesize amplitude;
@synthesize pitch;
@synthesize carrier;
@synthesize modulation;
@synthesize modIndex;
@synthesize functionTable;
@synthesize phase;

-(id)initWithOutput:(NSString *)out Amplitude:(NSString *)amp Pitch:(NSString *)pch Carrier:(NSString *)car Modulation:(NSString *)mod ModIndex:(NSString *)modIndx FunctionTable:(CSDFunctionStatement *)f AndOptionalPhase:(NSString *)phs
{
    if(( self = [super init])) {
        opcode = @"foscili";
        output = out;
        amplitude = amp;
        pitch = pch;
        carrier = car;
        modulation = mod;
        modIndex = modIndx;
        functionTable = f;
        phase = phs;
    }
    return self;
}

-(NSString *) textWithPValue:(int) p; {
    if ( @"p" == amplitude ) { 
        amplitude = [NSString stringWithFormat:@"p%i", p++];
    }
    if ( @"p" == pitch ) { 
        pitch = [NSString stringWithFormat:@"p%i", p++]; 
    }
    if ( @"p" == carrier ) { 
        carrier = [NSString stringWithFormat:@"p%i", p++];
    }
    if ( @"p" == modulation ) { 
        modulation = [NSString stringWithFormat:@"p%i", p++];
    }
    if ( @"p" == modIndex ) { 
        modIndex = [NSString stringWithFormat:@"p%i", p++];
    }
    return [NSString stringWithFormat:@"%@ %@ %@, %@, %@, %@, %@, %i\n",
            output, opcode, amplitude, pitch, carrier, modulation, modIndex, [functionTable integerIdentifier]];
    
}

@end
