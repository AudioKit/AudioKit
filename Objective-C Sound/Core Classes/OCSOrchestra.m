//
//  OCSOrchestra.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOrchestra.h"
#import "OCSInstrument.h"
#import "OCSManager.h"

@interface OCSOrchestra () {
    int sampleRate;
    int samplesPerControlPeriod;
    int numberOfChannels;
    float zeroDBFullScaleValue;
    NSMutableArray *udos;
    NSMutableArray *instruments;
}
@end

@implementation OCSOrchestra

@synthesize zeroDBFullScaleValue;
@synthesize instruments;
@synthesize numberOfChannels;

- (id)init {
    self = [super init];
    if (self) {
        sampleRate = 44100;
        samplesPerControlPeriod = 100;
        numberOfChannels = 2;
        zeroDBFullScaleValue = 1.0f;
        udos = [[NSMutableArray alloc] init];
        instruments = [[NSMutableArray alloc] init];
    }
    return self; 
}

- (void)addInstrument:(OCSInstrument *)newInstrument {
    [instruments addObject:newInstrument];
    [newInstrument joinOrchestra:self];
}

- (void)addUDO:(OCSUserDefinedOpcode *)newUserDefinedOpcode {
    [udos addObject:newUserDefinedOpcode];
}

- (NSString *) stringForCSD {
 
    NSMutableString *s = [NSMutableString stringWithString:@""];
    
    [s appendString:@";=== HEADER ===\n"];
    [s appendString:[NSString stringWithFormat:
                     @"nchnls = %d \n"
                     @"sr     = %d \n"
                     @"0dbfs  = %g \n"
                     @"ksmps  = %d \n"
                     @"kr     = %d \n",
                     numberOfChannels, 
                     sampleRate, 
                     zeroDBFullScaleValue, 
                     samplesPerControlPeriod,
                     sampleRate/samplesPerControlPeriod]];
    [s appendString:@"\n"];
    
    [s appendString:@";=== GLOBAL F-TABLES ===\n"];
    for ( OCSInstrument *i in instruments) {
        for (OCSFTable *fTable in [i fTables]) {
            [s appendString:[fTable fTableStringForCSD]];
            [s appendString:@"\n"];
        } 
    }
    [s appendString:@"\n"];
    
    [s appendString:@";=== USER-DEFINED OPCODES ===\n"];
    for ( OCSInstrument *i in instruments) {
        for (OCSUserDefinedOpcode *udo in [i userDefinedOpcodes]) {
            [s appendString:@"\n"];     
            [s appendString:[OCSManager stringFromFile:[udo udoFile]]];
            [s appendString:@"\n"];
        }
    }
    [s appendString:@"\n"];

    [s appendString:@";=== INSTRUMENTS ===\n"];
    for ( OCSInstrument *i in instruments) {
        [s appendString:[NSString stringWithFormat:@"\n;--- %@ ---\n\n", [i uniqueName] ]];
        [s appendFormat:@"instr %i\n", [i instrumentNumber]];
        [s appendString:[NSString stringWithFormat:@"%@\n",[i stringForCSD]]];
        [s appendString:@"endin\n"];
    }
    [s appendString:@"\n"];
    
    return s;
}


@end
